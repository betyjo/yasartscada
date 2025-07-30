// File: screens/billing.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  bool _loading = true;
  List<BillingRecord> billingRecords = [];
  String _errorMessage = '';

  Future<void> fetchBilling() async {
    setState(() {
      _loading = true;
      _errorMessage = '';
    });
    try {
      final response =
          await http.get(Uri.parse('http://127.0.0.1:8000/billing'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          billingRecords = data.map((e) => BillingRecord.fromJson(e)).toList();
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch billing data';
        });
      }
    } catch (_) {
      setState(() {
        _errorMessage = 'Could not connect to server';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBilling();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 84, 64, 69),
      appBar: AppBar(title: const Text('Billing')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 149, 122, 122),
                        fontSize: 18),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: billingRecords.length,
                  itemBuilder: (context, index) {
                    final record = billingRecords[index];
                    return Card(
                      color: const Color(0xFF101010),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      child: ListTile(
                        title: Text(
                          record.username,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Water Used: ${record.waterUsed.toStringAsFixed(2)} m³\n'
                          'Amount Due: \$${record.amountDue.toStringAsFixed(2)}\n'
                          'Billing Date: ${record.billingDate}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class BillingRecord {
  final String username;
  final double waterUsed;
  final double amountDue;
  final String billingDate;

  BillingRecord({
    required this.username,
    required this.waterUsed,
    required this.amountDue,
    required this.billingDate,
  });

  factory BillingRecord.fromJson(Map<String, dynamic> json) {
    return BillingRecord(
      username: json['username'],
      waterUsed: (json['water_used'] as num).toDouble(),
      amountDue: (json['amount_due'] as num).toDouble(),
      billingDate: json['billing_date'],
    );
  }
}
