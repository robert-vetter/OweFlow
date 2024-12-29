import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

import 'auth_service.dart'; // Enthält die implementierte AuthService-Klasse

class EmailCheckScreen extends StatefulWidget {
  const EmailCheckScreen({super.key});

  @override
  State<EmailCheckScreen> createState() => _EmailCheckScreenState();
}

class _EmailCheckScreenState extends State<EmailCheckScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();

  final _authService = AuthService(Supabase.instance.client);

  bool _isChecking = false;
  bool _emailExists = false;
  bool _showPasswordField = false;
  bool _isRegistering = false;
  bool _showContinueButton = true;
  bool _loginRedirect = false;

  String? _inputError;
  String? _passwordError;

  Future<void> _checkInput() async {
    final input = _inputController.text.trim();

    if (input.isEmpty) {
      setState(() {
        _inputError = 'Please enter your email, username, or phone number';
      });
      return;
    }

    setState(() {
      _isChecking = true;
      _inputError = null;
    });

    try {
      final emailUsed = await _authService.isEmailUsed(input);
      final phoneUsed = await _authService.isPhoneUsed(input);
      final usernameUsed = await _authService.isUsernameUsed(input);

      if (emailUsed || phoneUsed || usernameUsed) {
        setState(() {
          _emailExists = true;
          _showPasswordField = true;
          _isRegistering = false;
          _showContinueButton = false;
        });
      } else {
        setState(() {
          _emailExists = false;
          _showPasswordField = false;
          _isRegistering = true;
          _showContinueButton = false;

          if (input.contains('@')) {
            _emailController.text = input;
          } else if (RegExp(r'^\d+$').hasMatch(input)) {
            _phoneController.text = input;
          } else {
            _usernameController.text = input;
          }
        });
      }
    } catch (e) {
      setState(() {
        _inputError = 'Error checking input: $e';
      });
    } finally {
      setState(() => _isChecking = false);
    }
  }

  Future<void> _onLoginInputBlur() async {
    if (_showPasswordField && !_isChecking) {
      final input = _inputController.text.trim();
      try {
        final emailUsed = await _authService.isEmailUsed(input);
        final phoneUsed = await _authService.isPhoneUsed(input);
        final usernameUsed = await _authService.isUsernameUsed(input);

        if (!emailUsed && !phoneUsed && !usernameUsed) {
          setState(() {
            _loginRedirect = true;
            _showPasswordField = false;
          });
        } else {
          setState(() {
            _loginRedirect = false;
          });
        }
      } catch (e) {
        setState(() {
          _inputError = 'Error checking input: $e';
        });
      }
    }
  }

  Future<void> _login() async {
    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordError = 'Password cannot be empty';
      });
      return;
    }

    final emailOrPhone = _emailController.text.isNotEmpty
        ? _emailController.text
        : _phoneController.text;

    try {
      await _authService.login(emailOrPhone, _passwordController.text);
      _showMessage('Logged in successfully!');
      Navigator.popUntil(context, ModalRoute.withName('/'));
    } catch (e) {
      setState(() {
        _passwordError = e.toString();
      });
    }
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final username = _usernameController.text.trim();
    final phone = _phoneController.text.trim();
    final fullName = _fullNameController.text.trim();

    try {
      await _authService.register(
        email: email,
        password: password,
        username: username,
        fullName: fullName,
        phone: phone.isNotEmpty ? phone : null,
      );

      _showMessage('Registration successful!');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => EmailVerificationScreen(email: email)),
      );
    } catch (e) {
      _showMessage(e.toString());
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegistering ? 'Sign Up' : 'Login'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isRegistering || _showContinueButton) ...[
              // Gemischtes Feld mit Eingabe (Email, Benutzername, oder Telefonnummer)
              TextField(
                controller: _inputController,
                decoration: InputDecoration(
                  labelText: 'Email, Username, or Phone',
                  border: const OutlineInputBorder(),
                  errorText: _inputError,
                ),
                onEditingComplete: _onLoginInputBlur,
              ),
              const SizedBox(height: 16),
              if (_showContinueButton)
                ElevatedButton(
                  onPressed: _checkInput,
                  child: const Text('Continue'),
                ),
            ],
            if (_showPasswordField) ...[
              // Passwortfeld (immer sichtbar)
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  errorText: _passwordError,
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              // Der Login/Registrierungs Button
              ElevatedButton(
                onPressed: _loginRedirect
                    ? () {
                        // Weiterleitung zur Registrierungsseite
                        setState(() {
                          _isRegistering = true;
                          _showContinueButton = false;
                          _inputController.clear();
                        });
                      }
                    : _login,
                child: Text(_loginRedirect ? 'Back to Registration' : 'Login'),
              ),
              if (!_loginRedirect)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text('Forgot Password?'),
                ),
            ],
            if (_isRegistering) ...[
              // Registrierungsformular (wird angezeigt, wenn der Benutzer zur Registrierung wechselt)
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _register,
                child: const Text('Register'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isRegistering = false;
                    _showContinueButton = true;
                    _inputController.clear();
                  });
                },
                child: const Text('Back to Login'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final VoidCallback? onVerificationComplete;

  const EmailVerificationScreen({
    super.key,
    required this.email,
    this.onVerificationComplete,
  });

  @override
  _EmailVerificationScreenState createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  late final AuthService _authService;

  bool _isChecking = false;
  bool _isOtpSent = false;
  bool _isVerifyingOtp = false;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(Supabase.instance.client);
    _sendOtp();
  }

  Future<void> _sendOtp() async {
    setState(() => _isChecking = true);

    final success = await _authService.sendEmailVerification(widget.email);
    if (success) {
      setState(() => _isOtpSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent to your email')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send OTP')),
      );
    }

    setState(() => _isChecking = false);
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();

    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the OTP')),
      );
      return;
    }

    setState(() => _isVerifyingOtp = true);

    final success = await _authService.verifyEmailOtp(widget.email, otp);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email verified successfully')));
      if (widget.onVerificationComplete != null) {
        widget.onVerificationComplete!();
      } else {
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to verify OTP')),
      );
    }

    setState(() => _isVerifyingOtp = false);
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
            ] else ...[
              const Text(
                'Sending OTP to your email...',
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PhoneVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const PhoneVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  _PhoneVerificationScreenState createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  late final AuthService _authService;

  bool _isChecking = false;
  bool _isOtpSent = false;
  bool _isVerifyingOtp = false;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(Supabase.instance.client);
    _sendOtp();
  }

  Future<void> _sendOtp() async {
    setState(() => _isChecking = true);

    final success =
        await _authService.sendPhoneVerification(widget.phoneNumber);
    if (success) {
      setState(() => _isOtpSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent to your phone')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send OTP')),
      );
    }

    setState(() => _isChecking = false);
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();

    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the OTP')),
      );
      return;
    }

    setState(() => _isVerifyingOtp = true);

    final success = await _authService.verifyPhoneOtp(widget.phoneNumber, otp);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phone verified successfully')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to verify OTP')),
      );
    }

    setState(() => _isVerifyingOtp = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Verification'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            ] else ...[
              const Text(
                'Sending OTP to your phone...',
                textAlign: TextAlign.center,
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

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _authService = AuthService(Supabase.instance.client);

  String? _errorMessage;
  bool _isProcessing = false;

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email address';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      await _authService.sendPasswordResetEmail(email);
      _showMessage('Password reset email sent. Please check your inbox.');
      Navigator.pop(context); // Zurück zum Login-Bildschirm
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send password reset email: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Enter your email address',
                border: const OutlineInputBorder(),
                errorText: _errorMessage,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isProcessing ? null : _resetPassword,
              child: _isProcessing
                  ? const CircularProgressIndicator()
                  : const Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}
