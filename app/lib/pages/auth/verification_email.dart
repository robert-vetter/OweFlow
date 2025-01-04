import 'package:flutter/material.dart';
import 'pin_code_fields/pin_code_fields.dart';
import 'package:app/pages/auth/auth_service.dart';
import 'package:app/pages/home.dart';

class EmailVerifyPageWidget extends StatefulWidget {
  const EmailVerifyPageWidget({
    super.key,
    required this.email,
    required this.password,
    required this.redirectToPhoneVerify,
    this.phoneNumber,
  });

  final String? email;
  final String? password;
  final bool? redirectToPhoneVerify;
  final String? phoneNumber;

  @override
  State<EmailVerifyPageWidget> createState() => _EmailVerifyPageWidgetState();
}

class _EmailVerifyPageWidgetState extends State<EmailVerifyPageWidget> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late TextEditingController _pinCodeController;
  bool? _isVerified;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pinCodeController = TextEditingController();
  }

  Future<void> _confirm() async {
    setState(() => _isLoading = true);

    try {
      _isVerified = await verifyEmailWithToken(
        widget.email!,
        _pinCodeController.text,
      );

      if (_isVerified == true) {
        _showSuccessAnimation();
        await Future.delayed(const Duration(seconds: 1));

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        _showErrorDialog();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showSuccessAnimation() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Verification Successful!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Verification Failed'),
          ],
        ),
        content: const Text(
          'The verification code you entered is incorrect. Please try again.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pinCodeController.clear();
            },
            child: const Text('OK', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pinCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildVerificationForm(),
                  const SizedBox(height: 40),
                  _buildResendSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.shade100.withOpacity(0.3),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Icon(
            Icons.mail_outline_rounded,
            size: 80,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Verify Your Email',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          'We\'ve sent a verification code to',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.black54,
              ),
        ),
        Text(
          widget.email ?? '',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
        ),
      ],
    );
  }

  Widget _buildVerificationForm() {
    return Column(
      children: [
        PinCodeTextField(
          appContext: context,
          length: 6,
          textStyle: const TextStyle(
            fontFamily: 'Readex Pro',
            fontSize: 18,
          ),
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          enableActiveFill: false,
          autoFocus: true,
          enablePinAutofill: false,
          showCursor: true,
          cursorColor: Theme.of(context).primaryColor,
          keyboardType: TextInputType.number,
          pinTheme: PinTheme(
            fieldHeight: 50,
            fieldWidth: 45,
            borderWidth: 2,
            borderRadius: BorderRadius.circular(8),
            shape: PinCodeFieldShape.box,
            activeColor: Theme.of(context).primaryColor,
            inactiveColor: Colors.grey.shade300,
            selectedColor: Theme.of(context).primaryColor,
          ),
          controller: _pinCodeController,
          onChanged: (value) {},
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _confirm,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Verify',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildResendSection() {
    return Column(
      children: [
        Text(
          'Didn\'t receive the code?',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.black54,
              ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () async {
            await signUpWithEmail(widget.email!, widget.password!);
          },
          child: Text(
            'Resend Code',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
