// app.dart
import 'package:flutter/material.dart';
import 'pages/home.dart'; // Import the home.dart file

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Name',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(), // Set HomePage as the starting point of the app
    );
  }
}
