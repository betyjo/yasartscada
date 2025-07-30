import 'package:flutter/material.dart';
import 'base_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScreen(
      title: 'About',
      body: Center(
        child: Text(
          "🏗️ About YASART Engineering",
          style: TextStyle(
            color: Colors.amberAccent,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
