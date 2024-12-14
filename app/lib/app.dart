import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // const für Tests wichtig

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schuldenmanagement',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Einfaches Theme
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Willkommen'), // Titel der App
        ),
        body: const Center(
          child: Text(
            'Hallo, Welt!', // Einfache Nachricht
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
