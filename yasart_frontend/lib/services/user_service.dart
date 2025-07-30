// File: services/user_ser.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl;

  UserService({this.baseUrl = 'http://127.0.0.1:8000'});

  Future<bool> addUser({
    required String username,
    required String password,
    required String role,
    required String pressureTransducerId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'role': role,
        'pressure_transducer_id': pressureTransducerId,
      }),
    );
    return response.statusCode == 200;
  }
}
