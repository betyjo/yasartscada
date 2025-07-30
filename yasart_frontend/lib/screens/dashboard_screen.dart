import 'package:flutter/material.dart';
import 'base_screen.dart'; // Adjust the import path as needed

class DashboardScreen extends StatelessWidget {
  final String username;
  final String role;
  final String pressureTransducerId;

  const DashboardScreen({
    super.key,
    required this.username,
    required this.role,
    required this.pressureTransducerId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseScreen(
      title: 'Dashboard',
      body: Center(
        child: Text(
          'Welcome to Dashboard, $username.\nRole: $role\nPressure Transducer ID: $pressureTransducerId',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
        ),
      ),
    );
  }
}
