import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/auth/auth_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _register() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registration Successful!')),
    );
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const EmailVerificationScreen(
                email: "test",
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Register'),
            ),
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
