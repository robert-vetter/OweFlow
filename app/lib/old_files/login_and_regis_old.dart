import 'package:flutter/material.dart';
import '../pages/auth/forgot_password.dart';
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

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isChecking = false;
  bool _isOtpSent = false;
  bool _isVerifyingOtp = false;

  Future<void> _sendOtp() async {
    String email = _inputController.text.trim();

    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}")
        .hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    setState(() => _isChecking = true);

    try {
      await Supabase.instance.client.auth.signInWithOtp(email: email);
      setState(() {
        _isOtpSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent to your email')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send OTP: $e')),
      );
    } finally {
      setState(() => _isChecking = false);
    }
  }

  Future<bool> verifyEmailWithToken(
    String email,
    String? token,
  ) async {
    // Add your function code here!
    // instantiate Supabase client
    final supabase = Supabase.instance.client;

    try {
      // call the supabase verifyOTP function
      // if successful, a response with the user and session is returned
      final AuthResponse res = await supabase.auth.verifyOTP(
        type: OtpType.signup,
        token: token ?? " ",
        email: email,
      );

      // return true if session is not null (i.e. user has signed in)
      return res.session != null;
    } on AuthException catch (e) {
      // catch any authenticatino errors and print them to the console
      print('Error de autenticación: ${e.message}');
      return false;
    } catch (error) {
      // catch any other errors
      print(error);
      return false;
    }
  }

  Future<void> _verifyOtp() async {
    String email = _inputController.text.trim();
    String otp = _otpController.text.trim();

    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the OTP')),
      );
      return;
    }

    setState(() => _isVerifyingOtp = true);

    final supabase = Supabase.instance.client;

    try {
      final response = await supabase.auth.verifyOTP(
        type: OtpType.email,
        token: otp,
        email: email,
      );

      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP verified successfully')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SuccessScreen()),
        );
      } else {
        throw Exception('Verification failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to verify OTP: $e')),
      );
    } finally {
      setState(() => _isVerifyingOtp = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verification'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _inputController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (!_isOtpSent)
              ElevatedButton(
                onPressed: _isChecking ? null : _sendOtp,
                child: const Text('Send OTP'),
              ),
            if (_isOtpSent) ...[
              TextField(
                controller: _otpController,
                decoration: const InputDecoration(
                  labelText: 'Enter OTP',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isVerifyingOtp ? null : _verifyOtp,
                child: const Text('Verify OTP'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Success'),
      ),
      body: Center(
        child: const Text('You are now logged in!'),
      ),
    );
  }
}
