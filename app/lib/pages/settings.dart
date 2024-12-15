import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: const Center(
        child: Text(
          'Hier kannst du deine Einstellungen ändern.',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
