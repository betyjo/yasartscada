import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({super.key});

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  List<Map<String, dynamic>> users = [];
  bool loading = true;
  String error = '';

  Future<void> fetchUsers() async {
    try {
      final res = await http.get(Uri.parse('http://127.0.0.1:8000/users/all'));

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        setState(() {
          users = data.cast<Map<String, dynamic>>();
          loading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load users';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Connection error: $e';
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Registered Users'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(
                  child: Text(error,
                      style: const TextStyle(color: Colors.redAccent)))
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      color: Colors.grey[900],
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(
                          user['username'],
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Role: ${user['role']}\nTransducer ID: ${user['pressure_transducer_id'] ?? 'N/A'}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
