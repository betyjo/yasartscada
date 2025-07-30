import 'package:flutter/material.dart';

class StatusScreen extends StatelessWidget {
  final int pump1Level;
  final int pump2Level;
  final int pump3Level;
  final double pressureReading;
  final bool pump1On;
  final bool pump2On;
  final bool pump3On;
  final Map<String, bool> valveStates;

  const StatusScreen({
    super.key,
    required this.pump1Level,
    required this.pump2Level,
    required this.pump3Level,
    required this.pressureReading,
    required this.pump1On,
    required this.pump2On,
    required this.pump3On,
    required this.valveStates,
  });

  Widget buildBucket(String label, int level) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          width: 50,
          child: CustomPaint(painter: BucketLevelPainter(level)),
        ),
        Text("$level%", style: const TextStyle(color: Colors.white70)),
      ],
    );
  }

  Widget buildPumpStatus(String label, bool isOn) {
    return Row(
      children: [
        Icon(
          isOn ? Icons.power : Icons.power_off,
          color: isOn ? Colors.greenAccent : Colors.redAccent,
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget buildValveStatus(String valve, bool state) {
    return ListTile(
      title: Text(valve, style: const TextStyle(color: Colors.white)),
      trailing: Icon(
        state ? Icons.check_circle : Icons.cancel,
        color: state ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Status Overview")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              "Water Levels",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildBucket("Pump 1", pump1Level),
                buildBucket("Pump 2", pump2Level),
                buildBucket("Pump 3", pump3Level),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              "Pump Status",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 10),
            buildPumpStatus("Submersible Pump 1", pump1On),
            buildPumpStatus("Booster Pump 2", pump2On),
            buildPumpStatus("Submersible Pump 3", pump3On),
            const SizedBox(height: 30),
            const Text(
              "Valve Status",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            ...valveStates.entries.map(
              (entry) => buildValveStatus(entry.key, entry.value),
            ),
            const SizedBox(height: 30),
            Text(
              "Pressure: $pressureReading bar",
              style: const TextStyle(color: Colors.cyanAccent, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

// Replace with your bucket painter implementation
class BucketLevelPainter extends CustomPainter {
  final int levelPercent;
  BucketLevelPainter(this.levelPercent);

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final fillPaint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.fill;

    final bucketRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(bucketRect, borderPaint);

    final waterHeight = (levelPercent.clamp(0, 100) / 100.0) * size.height;
    final waterRect = Rect.fromLTWH(
      0,
      size.height - waterHeight,
      size.width,
      waterHeight,
    );
    canvas.drawRect(waterRect, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
