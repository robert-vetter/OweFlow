import 'dart:ui';
import 'package:app/pages/auth/auth_service.dart';
import 'package:app/pages/home.dart';
import 'package:flutter/scheduler.dart'; // Import for SchedulerBinding

import 'pin_code_fields/pin_code_fields.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();

    // Initialize the controller
    _pinCodeController = TextEditingController();
  }

  // On page load action
  Future<void> _confirm() async {
    if (_isVerified == true) {
      if (widget.redirectToPhoneVerify!) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage()), // Navigate to home page
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage()), // Navigate to home page
        );
      }
    } else {
      await showDialog(
        context: context,
        builder: (alertDialogContext) {
          return AlertDialog(
            title: const Text('Wrong Token'),
            content: const Text('Please try again'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(alertDialogContext),
                child: const Text('Ok'),
              ),
            ],
          );
        },
      );
      setState(() {
        _pinCodeController.clear();
      });
    }
  }

  @override
  void dispose() {
    _pinCodeController.dispose(); // Dispose of the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(0xFF3985EF);
    final primaryTextColor = Colors.black;
    final secondaryTextColor = Colors.grey;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: Icon(
                    Icons.email_outlined,
                    color: primaryColor,
                    size: 120,
                  ),
                ),
                Text(
                  'Verify Your Email',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    color: primaryTextColor,
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Please check your inbox and click on the verification link sent to your emial address.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Readex Pro',
                    color: secondaryTextColor,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 24),
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  textStyle: TextStyle(
                    fontFamily: 'Readex Pro',
                    fontSize: 18,
                  ),
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  enableActiveFill: false,
                  autoFocus: true,
                  enablePinAutofill: false,
                  errorTextSpace: 16,
                  showCursor: true,
                  cursorColor: primaryColor,
                  keyboardType: TextInputType.number,
                  pinTheme: PinTheme(
                    fieldHeight: 40,
                    fieldWidth: 40,
                    borderWidth: 2,
                    borderRadius: BorderRadius.circular(8),
                    shape: PinCodeFieldShape.box,
                    activeColor: primaryTextColor,
                    inactiveColor: secondaryTextColor,
                    selectedColor: primaryColor,
                  ),
                  controller: _pinCodeController,
                  onChanged: (value) {},
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Confirm OTP',
                    style: TextStyle(
                      fontFamily: 'Readex Pro',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                Text(
                  'Didn\'t receive the email?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Readex Pro',
                    color: secondaryTextColor,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    await signUpWithEmail(
                      widget.email!,
                      widget.password!,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Resend email',
                    style: TextStyle(
                      fontFamily: 'Readex Pro',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
