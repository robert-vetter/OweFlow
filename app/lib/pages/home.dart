import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Willkommen'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Hallo, Welt!',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20), // Abstand
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            child: const Text('Zu den Einstellungen'),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              // Andere Aktion
            },
            child: const Text('Anderer Button'),
          ),
        ],
      ),
    );
  }
}
