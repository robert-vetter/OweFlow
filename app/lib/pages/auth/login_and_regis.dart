import 'package:flutter/material.dart';
import 'forgot_password.dart';
import 'verification_email.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmailCheckScreen extends StatefulWidget {
  const EmailCheckScreen({super.key});

  @override
  State<EmailCheckScreen> createState() => _EmailCheckScreenState();
}

class _EmailCheckScreenState extends State<EmailCheckScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();

  // Dummy-Variable zur Simulation von Datenbank-Abfragen
  final bool existsInDB = false;

  bool _emailChecked = false; // E-Mail wurde geprüft?
  bool _emailExists = false; // E-Mail existiert in der Datenbank?
  bool _showPasswordField = false; // Passwortfeld anzeigen?

  /// Prüft, ob die E-Mail in der Datenbank existiert
  void _checkEmail() {
    String email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }

    // Dummy-Logik zur E-Mail-Prüfung
    setState(() {
      _emailChecked = true;
      _emailExists = existsInDB; // Hier simuliert
      _showPasswordField =
          _emailExists; // Passwortfeld anzeigen bei existierender E-Mail
    });
  }

  /// Login-Logik
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

  /// Registrierung
  Future<void> _register() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String firstName = _firstNameController.text.trim();

    if (email.isEmpty || password.isEmpty || firstName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields')),
      );
      return;
    }

    try {
      final response = await Supabase.instance.client.auth
          .signUp(email: email, password: password, data: {
        'first_name': firstName,
      });

      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const EmailVerificationScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    }
  }

  /// Widget für die E-Mail-Eingabe und Weiter-Button
  Widget _buildEmailInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Enter your email to continue',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
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
        ElevatedButton(
          onPressed: _checkEmail,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('Continue'),
        ),
      ],
    );
  }

  /// Widget für das Login-Formular
  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Login to your account',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
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
          onPressed: _login,
          child: const Text('Login'),
        ),
        TextButton(
          onPressed: _forgotPassword,
          child: const Text('Forgot Password?'),
        ),
      ],
    );
  }

  /// Widget für das Registrierungs-Formular
  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Create a new account',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _firstNameController,
          decoration: const InputDecoration(
            labelText: 'First Name',
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
    );
  }

  /// Widget für Social Media Login
  Widget _buildSocialLogin() {
    return Column(
      children: [
        const SizedBox(height: 24),
        const Text(
          'Or continue with:',
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
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
              icon: const Icon(Icons.alternate_email, color: Colors.blueAccent),
              iconSize: 36,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _emailChecked ? (_emailExists ? 'Login' : 'Sign Up') : 'Get Started',
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // E-Mail-Feld bleibt immer sichtbar
            const Text(
              'Enter your email to continue',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
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

            // Weiter-Button nur sichtbar, wenn E-Mail noch nicht geprüft wurde
            if (!_emailChecked)
              ElevatedButton(
                onPressed: _checkEmail,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Continue'),
              ),

            // Login-Formular sichtbar, wenn E-Mail existiert
            if (_emailChecked && _emailExists) _buildLoginForm(),

            // Registrierungsformular sichtbar, wenn E-Mail nicht existiert
            if (_emailChecked && !_emailExists) _buildRegisterForm(),

            // Social Media Login Optionen nur sichtbar, wenn E-Mail nicht geprüft wurde
            if (!_emailChecked) _buildSocialLogin(),
          ],
        ),
      ),
    );
  }
}
