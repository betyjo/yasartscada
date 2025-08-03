// ignore_for_file: no_wildcard_variable_uses

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/connect_screen.dart';
import 'screens/add_user_screen.dart';
import 'screens/bill_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/status_screen.dart';
import 'screens/about_screen.dart';
import 'screens/user_screen.dart';
import 'screens/base_screen.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const YasartSCADAApp());
}

class YasartSCADAApp extends StatelessWidget {
  const YasartSCADAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YASART SCADA',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const RoleLoaderScreen(),
    );
  }

  static final ThemeData appTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    primaryColor: const Color.fromARGB(255, 100, 102, 105),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      foregroundColor: Colors.lightBlueAccent,
      elevation: 2,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.lightBlueAccent,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      iconTheme: IconThemeData(color: Colors.lightBlueAccent),
    ),
    colorScheme: const ColorScheme.dark().copyWith(
      primary: Colors.blueAccent,
      secondary: Colors.grey,
      onPrimary: Colors.white,
      onSecondary: Colors.white70,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: Colors.lightBlueAccent,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      bodyLarge: TextStyle(color: Colors.white70),
      bodyMedium: TextStyle(color: Colors.white54),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    iconTheme: const IconThemeData(color: Colors.lightBlueAccent),
  );
}

class RoleLoaderScreen extends StatefulWidget {
  const RoleLoaderScreen({super.key});

  @override
  State<RoleLoaderScreen> createState() => _RoleLoaderScreenState();
}

class _RoleLoaderScreenState extends State<RoleLoaderScreen> {
  String? role;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchRole();
  }

  Future<void> fetchRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');

      if (username != null) {
        final res = await http.get(
            Uri.parse('http://127.0.0.1:8000/user-role?username=$username'));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          setState(() {
            role = data['role'] ?? 'viewer';
            loading = false;
          });
        } else {
          setState(() {
            role = 'viewer';
            loading = false;
          });
        }
      } else {
        setState(() {
          role = 'viewer';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        role = 'viewer';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return MainRouter(role: role!); // Safe, since role is resolved
  }
}

class MainRouter extends StatelessWidget {
  final String role;

  const MainRouter({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: YasartSCADAApp.appTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return _wrap(const SplashScreen(), 'Splash');
          case '/login':
            return _wrap(const LoginScreen(), 'Login');
          case '/home':
            return _wrap(const HomeScreen(), 'Home');
          case '/connect':
            return _wrap(const ConnectScreen(), 'Connect');
          case '/dashboard':
            return _wrap(
              DashboardScreen(
                  username: '', role: role, pressureTransducerId: ''),
              'Dashboard',
            );
          case '/status':
            return MaterialPageRoute(
              builder: (_) => StatusScreen(
                onLogout: () => Navigator.of(_)
                    .pushNamedAndRemoveUntil('/login', (r) => false),
                onNavigate: (route) =>
                    Navigator.of(_).pushReplacementNamed(route),
              ),
            );
          case '/about':
            return _wrap(const AboutScreen(), 'About');
          case '/billing':
            return _wrap(const BillingScreen(),
                role == 'admin' ? 'Billing' : 'My Billing');
          case '/add_user':
            return role == 'admin'
                ? _wrap(const AddUserScreen(), 'Add User')
                : _unauthorized();
          case '/user':
            return role == 'admin'
                ? _wrap(const AdminUserListScreen(), 'User List')
                : _unauthorized();
          default:
            return _notFound();
        }
      },
    );
  }

  MaterialPageRoute _wrap(Widget body, String title) {
    return MaterialPageRoute(
      builder: (_) => BaseScreen(title: title, body: body, role: role),
    );
  }

  MaterialPageRoute _unauthorized() {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(child: Text('You are not authorized to view this page')),
      ),
    );
  }

  MaterialPageRoute _notFound() {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(child: Text('404 - Page not found')),
      ),
    );
  }
}
