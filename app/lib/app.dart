import 'package:flutter/material.dart';
import 'pages/home.dart'; // Import the home.dart file

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OweFlow',
      home: const HomePage(),
    );
  }
}
