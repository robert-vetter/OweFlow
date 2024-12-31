import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../pages/auth/forgot_password.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isBiometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
  }

  /// Prüft, ob biometrische Authentifizierung verfügbar ist
  Future<void> _checkBiometricSupport() async {
    bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
    bool isDeviceSupported = await _localAuth.isDeviceSupported();

    if (canCheckBiometrics && isDeviceSupported) {
      setState(() {
        _isBiometricAvailable = true;
      });
      _authenticateWithBiometrics();
    }
  }

  /// Startet die biometrische Authentifizierung
  Future<void> _authenticateWithBiometrics() async {
    try {
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your account',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful via Biometric!')),
        );
        Navigator.popUntil(context, ModalRoute.withName('/'));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Biometric authentication failed: $e')),
      );
    }
  }

  /// Fallback-Login mit Passwort
  void _loginWithPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged in successfully with Password!')),
    );
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  /// Navigiert zur "Forgot Password"-Seite
  void _forgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter your password to continue',
              style: TextStyle(fontSize: 18),
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loginWithPassword,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Login with Password'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _forgotPassword,
              child: const Text('Forgot Password?'),
            ),
            if (_isBiometricAvailable)
              Column(
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Or use your fingerprint/face to log in:',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: const Icon(Icons.fingerprint,
                        size: 50, color: Colors.blue),
                    onPressed: _authenticateWithBiometrics,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
