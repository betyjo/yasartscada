import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: ListView(
        children: [
          const SizedBox(height: 20),
          Text(
            'SCADA System Overview',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'This water distribution SCADA system is designed by YASART Engineering PLC to remotely monitor, control, and analyze real-time performance of pumps, valves, water levels, and pressure readings across a supply grid. It supports billing, role-based access, and Modbus RTU integration.',
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurface,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.black12,
            ),
            child: Center(
              child: Text(
                'Video or Image will appear here',
                style: TextStyle(color: theme.colorScheme.secondary),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Developed with reliability, visualization, and remote accessibility at its core.',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 15,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
