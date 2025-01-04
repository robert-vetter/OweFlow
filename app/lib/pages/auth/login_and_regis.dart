import 'package:app/pages/auth/verification_email.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'dart:io';

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

  final FocusNode _focusNodeMixedField = FocusNode();

  bool _isChecking = false;
  bool _emailExists = false;
  bool _showPasswordField = false;
  bool _isRegistering = false;
  bool _isLogin = false;
  bool _showContinueButton = true;
  bool _loginRedirect = false;
  bool _isFocusLostMixedField = true; // Flag, um den Fokusverlust zu verfolgen

  String? _inputError;
  String? _passwordError;

  // Functions to handle focus loss (on focus change) of the mixed Input field
  @override
  void initState() {
    super.initState();
    _focusNodeMixedField.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNodeMixedField.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNodeMixedField.hasFocus) {
      // Wenn der Fokus verloren geht und die Funktion noch nicht aufgerufen wurde
      if (!_isFocusLostMixedField) {
        _isFocusLostMixedField = true; // Setze das Flag
        _onLoginInputBlur(); // Funktion aufrufen
      }
    } else {
      // Wenn der Fokus wieder erlangt wird, setzen Sie das Flag zurück
      _isFocusLostMixedField = false;
    }
  }

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
      final emailUsed = await isEmailUsed(input);
      final phoneUsed = await isPhoneUsed(input);
      final usernameUsed = await isUsernameUsed(input);

      if (emailUsed || phoneUsed || usernameUsed) {
        setState(() {
          _emailExists = true;
          _showPasswordField = true;
          _isLogin = true;
          _isRegistering = false;
          _showContinueButton = false;
        });
      } else {
        setState(() {
          _emailExists = false;
          _showPasswordField = false;
          _isLogin = false;
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
        final emailUsed = await isEmailUsed(input);
        final phoneUsed = await isPhoneUsed(input);
        final usernameUsed = await isUsernameUsed(input);

        if (!emailUsed && !phoneUsed && !usernameUsed) {
          setState(() {
            _loginRedirect = true;
            _showPasswordField = false;
          });
        } else {
          setState(() {
            _loginRedirect = false;
            _showPasswordField = true;
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

    final logInput = _inputController.text.trim();

    try {
      if (logInput.contains('@')) {
        await loginWithEmail(logInput, _passwordController.text);
      } else if (RegExp(r'^\d+$').hasMatch(logInput)) {
        await loginWithPhone(logInput, _passwordController.text);
      } else {
        await loginWithUsername(logInput, _passwordController.text);
      }

      _showMessage('Logged in successfully!');
      Navigator.pop(context, true); // Rückgabe: true für erfolgreichen Login
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
    final verfifyPhone = phone.isEmpty ? false : true;

    try {
      await register(
        email: email,
        password: password,
        username: username,
        fullName: fullName,
        phone: phone.isNotEmpty ? phone : null,
      );

      _showMessage('Registration successful!');
      Navigator.pop(context, true); // Rückgabe: true für erfolgreichen Login
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(

              //builder: (context) => EmailVerificationScreen(email: email)),
              builder: (context) => EmailVerifyPageWidget(
                    email: email,
                    password: password,
                    redirectToPhoneVerify: verfifyPhone,
                    phoneNumber: phone,
                  )) //(email: email)),
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
        title: Text(_isRegistering
            ? 'Sign Up'
            : _isLogin
                ? 'Login'
                : 'Welcome - Please enter your Data'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child:
            // Wrap(
            //  direction:
            //      Axis.vertical, // Vertikale Ausrichtung, ein Element pro Zeile
            //  spacing: 0, // Kein horizontaler Abstand
            //  runSpacing: 10, // Vertikaler Abstand, anpassbar je nach Bedarf

            Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isRegistering && !_isLogin) ...[
              // Gemischtes Feld mit Eingabe (Email, Benutzername, oder Telefonnummer)
              TextField(
                controller: _inputController,
                focusNode: _focusNodeMixedField,
                decoration: InputDecoration(
                  labelText: 'Email, Username, or Phone',
                  border: const OutlineInputBorder(),
                  errorText: _inputError,
                ),
                autocorrect: false,
                onEditingComplete: _onLoginInputBlur,
              ),
              const SizedBox(height: 16),
              if (_showContinueButton)
                ElevatedButton(
                  onPressed: _checkInput,
                  child: const Text('Continue'),
                ),
            ],
            // Der Login/Registrierungs Button
            if (_isLogin) ...[
              TextField(
                controller: _inputController,
                focusNode: _focusNodeMixedField,
                decoration: InputDecoration(
                  labelText: 'Email, Username, or Phone',
                  border: const OutlineInputBorder(),
                  errorText: _inputError,
                ),
                autocorrect: false,
                onEditingComplete: _onLoginInputBlur,
              ),
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
              ],
              ElevatedButton(
                onPressed: _loginRedirect
                    ? () {
                        // Weiterleitung zur Registrierungsseite
                        setState(() {
                          _showPasswordField = false;
                          _isRegistering = true;
                          _showContinueButton = false;
                          _isLogin = false;
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

            SocialMediaLoginBar(
              onLogin: (provider) async {
                switch (provider) {
                  case "Google":
                    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
                      try {
                        return nativeGoogleSignIn();
                      } catch (e) {
                        _showMessage(
                            "Login with Google failed: " + e.toString());
                      }
                    }
                    await Supabase.instance.client.auth
                        .signInWithOAuth(OAuthProvider.google);
                  default:
                    print("Login with $provider ");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SocialMediaLoginBar extends StatelessWidget {
  final Function(String provider) onLogin;

  /// Parameter, um anzugeben, welche Anbieter angezeigt werden sollen
  final bool showGoogle;
  final bool showMicrosoft;
  final bool showLinkedIn;
  final bool showFacebook;
  final bool showApple;

  const SocialMediaLoginBar({
    Key? key,
    required this.onLogin,
    this.showGoogle = true,
    this.showMicrosoft = true,
    this.showLinkedIn = true,
    this.showFacebook = true,
    this.showApple = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showGoogle)
          _buildSocialButton(
            icon: FontAwesomeIcons.google,
            color: Colors.red,
            onTap: () => onLogin("Google"),
          ),
        if (showMicrosoft)
          _buildSocialButton(
            icon: FontAwesomeIcons.microsoft,
            color: Colors.blueGrey,
            onTap: () => onLogin("Microsoft"),
          ),
        if (showLinkedIn)
          _buildSocialButton(
            icon: FontAwesomeIcons.linkedin,
            color: Colors.blue,
            onTap: () => onLogin("LinkedIn"),
          ),
        if (showFacebook)
          _buildSocialButton(
            icon: FontAwesomeIcons.facebook,
            color: Colors.indigo,
            onTap: () => onLogin("Facebook"),
          ),
        if (showApple)
          _buildSocialButton(
            icon: FontAwesomeIcons.apple,
            color: Colors.black,
            onTap: () => onLogin("Apple"),
          ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: _HoverableIcon(
          icon: icon,
          color: color,
        ),
      ),
    );
  }
}

class _HoverableIcon extends StatefulWidget {
  final IconData icon;
  final Color color;

  const _HoverableIcon({
    Key? key,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  __HoverableIconState createState() => __HoverableIconState();
}

class __HoverableIconState extends State<_HoverableIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 60,
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isHovered
              ? widget.color.withOpacity(0.15)
              : Colors.white.withOpacity(0.0),
        ),
        child: Icon(
          widget.icon,
          color: widget.color,
          size: 30,
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
      await sendPasswordResetEmail(email);
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
