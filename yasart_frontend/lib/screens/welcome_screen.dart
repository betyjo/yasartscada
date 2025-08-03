import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  final String username;
  final String role;
  final String pressureTransducerId;

  const WelcomeScreen({
    super.key,
    required this.username,
    required this.role,
    required this.pressureTransducerId,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.waves, color: Colors.white, size: 60),
            const SizedBox(height: 24),
            Text(
              'Welcome, $username!',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'You’ve successfully logged in to the YASART SCADA System.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(
                  '/dashboard',
                  arguments: {
                    'username': username,
                    'role': role,
                    'pressureTransducerId': pressureTransducerId,
                  },
                );
              },
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
