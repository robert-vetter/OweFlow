import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'forgot_password.dart';
import 'verification_email.dart';

class EmailCheckScreen extends StatefulWidget {
  const EmailCheckScreen({super.key});

  @override
  State<EmailCheckScreen> createState() => _EmailCheckScreenState();
}

class _EmailCheckScreenState extends State<EmailCheckScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();

  // ---------------------------
  final bool login = true;
  // ---------------------------

  bool _emailChecked = false; // Wurde die E-Mail geprüft?
  bool _emailExists = false; // Existiert die E-Mail bereits?
  bool _isBiometricAvailable = false; // Ist Biometrie verfügbar?
  bool _showPasswordField = false; // Soll das Passwortfeld angezeigt werden?

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
  }

  /// Prüft, ob biometrische Authentifizierung verfügbar ist
  Future<void> _checkBiometricSupport() async {
    bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
    bool isDeviceSupported = await _localAuth.isDeviceSupported();

    setState(() {
      _isBiometricAvailable = canCheckBiometrics && isDeviceSupported;
    });
  }

  /// Überprüft, ob die E-Mail bereits registriert ist
  void _checkEmail() {
    String email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }

    // Dummy-Logik zur E-Mail-Existenzprüfung
    setState(() {
      _emailChecked = true;
      _emailExists = login; // Beispielprüfung
      _showPasswordField =
          _emailExists; // Passwortfeld nur bei bestehender E-Mail
    });

    if (_emailExists && _isBiometricAvailable) {
      _authenticateWithBiometrics();
    }
  }

  /// Automatische biometrische Authentifizierung
  Future<void> _authenticateWithBiometrics() async {
    try {
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to continue',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (authenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful via Biometric!')),
        );
        Navigator.popUntil(context, ModalRoute.withName('/'));
      } else {
        setState(() {
          _showPasswordField = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Biometric authentication failed: $e')),
      );
      setState(() {
        _showPasswordField = true;
      });
    }
  }

  /// Login-Prozess mit Passwort
  void _login() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged in successfully!')),
    );
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  /// Passwort zurücksetzen
  void _forgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
    );
  }

  /// Registrierung-Prozess
  void _register() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registration Successful!')),
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EmailVerificationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get Started'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Enter your email to continue',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // E-Mail Feld bleibt immer sichtbar
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            if (!_emailChecked) ...[
              ElevatedButton(
                onPressed: _checkEmail,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Continue'),
              ),
              const SizedBox(height: 24),
              const Text('Or sign in with:',
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.facebook, color: Colors.blue),
                    iconSize: 36,
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.g_mobiledata, color: Colors.red),
                    iconSize: 36,
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.alternate_email,
                        color: Colors.blueAccent),
                    iconSize: 36,
                    onPressed: () {},
                  ),
                ],
              ),
            ] else if (_emailChecked && _emailExists && _showPasswordField) ...[
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Login'),
              ),
              TextButton(
                onPressed: _forgotPassword,
                child: const Text('Forgot Password?'),
              ),
            ] else if (_emailChecked && !_emailExists) ...[
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _register,
                child: const Text('Register'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
