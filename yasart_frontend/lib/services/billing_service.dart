// File: services/billing_ser.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../screens/bill_screen.dart'; // For BillingRecord

class BillingService {
  final String baseUrl;

  BillingService({this.baseUrl = 'http://127.0.0.1:8000'});

  Future<List<BillingRecord>> fetchBilling() async {
    final response = await http.get(Uri.parse('$baseUrl/billing'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => BillingRecord.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load billing data');
    }
  }
}
