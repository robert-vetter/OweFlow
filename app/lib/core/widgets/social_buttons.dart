import 'package:flutter/material.dart';

class SocialButtons extends StatelessWidget {
  final VoidCallback onFacebookPressed;
  final VoidCallback onGooglePressed;

  const SocialButtons({
    super.key,
    required this.onFacebookPressed,
    required this.onGooglePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.facebook, color: Colors.blue),
          iconSize: 40,
          onPressed: onFacebookPressed,
        ),
        IconButton(
          icon: const Icon(Icons.g_mobiledata, color: Colors.red),
          iconSize: 40,
          onPressed: onGooglePressed,
        ),
      ],
    );
  }
}
