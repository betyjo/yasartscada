import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StatusScreen extends StatefulWidget {
  final VoidCallback onLogout;
  final Function(String routeName) onNavigate;

  const StatusScreen({
    super.key,
    required this.onLogout,
    required this.onNavigate,
  });

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  int pump1Level = 0;
  int pump2Level = 0;
  int pump3Level = 0;
  double pressureReading = 0.0;
  bool pump1On = false;
  bool pump2On = false;
  bool pump3On = false;
  Map<String, bool> valveStates = {};

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    fetchStatus();
    _refreshTimer =
        Timer.periodic(const Duration(seconds: 5), (_) => fetchStatus());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchStatus() async {
    try {
      final res = await http.get(Uri.parse('http://localhost:8000/status'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          pump1Level = data['pump1_level'];
          pump2Level = data['pump2_level'];
          pump3Level = data['pump3_level'];
          pressureReading = data['pressure'];
          pump1On = data['pump1_on'];
          pump2On = data['pump2_on'];
          pump3On = data['pump3_on'];
          valveStates = Map<String, bool>.from(data['valves']);
        });
      }
    } catch (e) {
      debugPrint('Failed to fetch status: $e');
    }
  }

  Future<void> togglePump(String pumpId) async {
    try {
      await http.post(Uri.parse('http://localhost:8000/toggle_pump'),
          body: jsonEncode({'pump_id': pumpId}),
          headers: {'Content-Type': 'application/json'});
      fetchStatus(); // Refresh after toggling
    } catch (e) {
      debugPrint('Toggle pump error: $e');
    }
  }

  Widget buildPumpControl(String label, bool isOn, String id) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        Switch(
          value: isOn,
          onChanged: (_) => togglePump(id),
          activeColor: Colors.greenAccent,
          inactiveThumbColor: Colors.redAccent,
        ),
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

  Widget buildBucket(String label, int level) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
            height: 120,
            width: 50,
            child: CustomPaint(painter: BucketLevelPainter(level))),
        Text("$level%", style: const TextStyle(color: Colors.white70)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Status Overview"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: widget.onLogout,
          ),
        ],
      ),
      // No drawer here
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text("Water Levels",
                style: TextStyle(color: Colors.white, fontSize: 18)),
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
            const Text("Pump Status",
                style: TextStyle(color: Colors.white, fontSize: 18)),
            buildPumpControl("Submersible Pump 1", pump1On, "pump1"),
            buildPumpControl("Booster Pump 2", pump2On, "pump2"),
            buildPumpControl("Submersible Pump 3", pump3On, "pump3"),
            const SizedBox(height: 30),
            const Text("Valve Status",
                style: TextStyle(color: Colors.white, fontSize: 18)),
            ...valveStates.entries.map((e) => buildValveStatus(e.key, e.value)),
            const SizedBox(height: 30),
            Text("Pressure: $pressureReading bar",
                style: const TextStyle(color: Colors.cyanAccent, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  // Removed drawer-related method as drawer is removed
}

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
    final waterRect =
        Rect.fromLTWH(0, size.height - waterHeight, size.width, waterHeight);
    canvas.drawRect(waterRect, fillPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
