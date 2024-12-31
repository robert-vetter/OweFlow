import 'package:flutter/material.dart';

class BiometricAuthScreen extends StatelessWidget {
  const BiometricAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Biometric Authentication'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Authenticate to Continue',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Icon(Icons.fingerprint, size: 80, color: Colors.blue),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Use Biometric Authentication'),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Enter Code Instead'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
