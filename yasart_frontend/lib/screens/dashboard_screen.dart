// dashboard_screen.dart
import 'package:flutter/material.dart';

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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: ListView(
        children: [
          Text(
            'Dashboard',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          Text(
            'Welcome, $username!',
            style: const TextStyle(fontSize: 22, color: Colors.white70),
          ),
          const SizedBox(height: 10),
          Text(
            'Role: $role',
            style: const TextStyle(fontSize: 18, color: Colors.white54),
          ),
          const SizedBox(height: 10),
          Text(
            'Pressure Transducer ID: $pressureTransducerId',
            style: const TextStyle(fontSize: 18, color: Colors.white54),
          ),
          const SizedBox(height: 30),

          // Add your dashboard widgets here

          Card(
            color: Colors.blueGrey[900],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Pump Status',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlueAccent),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Pump 1: ON\nPump 2: OFF\nPump 3: ON',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Card(
            color: Colors.blueGrey[900],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Valve Status',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlueAccent),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Valve 1: CLOSED\nValve 2: OPEN\nValve 3: CLOSED',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
