import 'package:flutter/material.dart';
import 'landing_page.dart'; // You'll create this file next

// Main entry point - from MONDARES.pdf and Speirs-Midterm-Takeaway.pdf
void main() {
  runApp(FitnessApp()); // [attached_file:2][attached_file:3]
}

// Root widget - structure from Speirs-Midterm-Takeaway.pdf
class FitnessApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // [attached_file:3]
      debugShowCheckedModeBanner: false, // [attached_file:2]
      title: 'Fitness Wellness App', // [attached_file:3]
      theme: ThemeData(
        primarySwatch: Colors.blue, // [attached_file:3]
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ), // [attached_file:1]
      ),
      home: LandingPage(), // Start with your landing page [attached_file:3]
    );
  }
}
