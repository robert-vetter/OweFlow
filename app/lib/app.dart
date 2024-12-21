import 'package:flutter/material.dart';
import 'pages/home.dart'; // Import the home.dart file
import 'pages/groups.dart'; // New file for Groups
import 'pages/statistics.dart'; // New file for Statistics
import 'pages/payments.dart'; // New file for Payments

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Name',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}
