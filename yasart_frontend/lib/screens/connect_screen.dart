import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

enum ConnectionStatus { disconnected, connecting, connected, error }

class _ConnectScreenState extends State<ConnectScreen> {
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  String _errorMessage = '';

  final String _backendUrl = 'http://127.0.0.1:8000/modbus';

  Future<bool> _connectToModbus() async {
    final url = Uri.parse(_backendUrl);

    final Map<String, dynamic> requestBody = {
      "method": "rtu",
      "com_port": "COM4",
      "baudrate": 9600,
      "unit": 1,
      "address": 0,
      "write": false,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        jsonDecode(response.body);
        return true;
      } else {
        setState(() {
          _errorMessage = 'Backend error: ${response.body}';
        });
        return false;
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
      });
      return false;
    }
  }

  Future<void> _disconnectFromModbus() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _toggleConnection() async {
    if (_connectionStatus == ConnectionStatus.connected ||
        _connectionStatus == ConnectionStatus.connecting) {
      setState(() {
        _connectionStatus = ConnectionStatus.connecting;
        _errorMessage = '';
      });

      try {
        await _disconnectFromModbus();
        setState(() {
          _connectionStatus = ConnectionStatus.disconnected;
          _errorMessage = '';
        });
      } catch (e) {
        setState(() {
          _connectionStatus = ConnectionStatus.error;
          _errorMessage = 'Disconnect failed: ${e.toString()}';
        });
      }

      return;
    }

    setState(() {
      _connectionStatus = ConnectionStatus.connecting;
      _errorMessage = '';
    });

    try {
      final success = await _connectToModbus();

      if (success) {
        setState(() {
          _connectionStatus = ConnectionStatus.connected;
          _errorMessage = '';
        });
      } else {
        setState(() {
          _connectionStatus = ConnectionStatus.error;
        });
      }
    } catch (e) {
      setState(() {
        _connectionStatus = ConnectionStatus.error;
        _errorMessage = 'Connection error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    switch (_connectionStatus) {
      case ConnectionStatus.connected:
        statusColor = Colors.greenAccent.shade400;
        statusText = 'Connected';
        break;
      case ConnectionStatus.connecting:
        statusColor = Colors.amberAccent.shade400;
        statusText = 'Connecting...';
        break;
      case ConnectionStatus.error:
        statusColor = Colors.redAccent.shade400;
        statusText = 'Connection Failed';
        break;
      case ConnectionStatus.disconnected:
        statusColor = Colors.grey.shade500;
        statusText = 'Disconnected';
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.usb, size: 80, color: statusColor),
            const SizedBox(height: 20),
            Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            if (_connectionStatus == ConnectionStatus.error &&
                _errorMessage.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _connectionStatus == ConnectionStatus.connecting
                  ? null
                  : _toggleConnection,
              icon: _connectionStatus == ConnectionStatus.connecting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      _connectionStatus == ConnectionStatus.connected
                          ? Icons.usb_off
                          : Icons.usb,
                      color: Colors.black,
                    ),
              label: Text(
                _connectionStatus == ConnectionStatus.connected
                    ? 'Disconnect'
                    : 'Connect',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _connectionStatus == ConnectionStatus.connected
                    ? Colors.redAccent
                    : Colors.amberAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
