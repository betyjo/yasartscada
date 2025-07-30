import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import your screens here - make sure these files exist and define the classes below
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/connect_screen.dart';
import 'screens/add_user_screen.dart';
import 'screens/bill_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/status_screen.dart';
import 'screens/about_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const YasartSCADAApp());
}

class YasartSCADAApp extends StatelessWidget {
  const YasartSCADAApp({super.key});

  static final ThemeData appTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color.fromARGB(255, 100, 102, 105),
    scaffoldBackgroundColor: Colors.black,
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YASART SCADA',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/connect': (context) => const ConnectScreen(),
        '/add_user': (context) =>
            const AddUserScreen(), // from add_user_screen.dart
        '/billing': (context) =>
            const BillingScreen(), // from billing_screen.dart (ensure class name matches)
        '/dashboard': (context) =>
            DashboardScreen(username: '', role: '', pressureTransducerId: ''),
        '/status': (context) => StatusScreen(
          pump1Level: 0,
          pump2Level: 0,
          pump3Level: 0,
          pressureReading: 0.0,
          pump1On: false,
          pump2On: false,
          pump3On: false,
          valveStates: const {},
          onLogout: () {
            Navigator.of(context).pushReplacementNamed('/login');
          },
          onNavigate: (route) {
            Navigator.of(context).pushReplacementNamed(route);
          },
        ),
        '/about': (context) => const AboutScreen(),
      },
    );
  }
}

///
/// BaseScreen class to use for all main pages with drawer and consistent UI.
/// Each screen can wrap its content in this BaseScreen to get the drawer and appbar.
///
class BaseScreen extends StatelessWidget {
  final String title;
  final Widget body;

  const BaseScreen({super.key, required this.title, required this.body});

  void _handleLogout(BuildContext context) {
    // TODO: Implement your real logout logic here (e.g., FirebaseAuth.instance.signOut())
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _navigate(BuildContext context, String route) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute != route) {
      Navigator.of(context).pushReplacementNamed(route);
    }
    Navigator.of(context).pop(); // close drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'Open navigation menu',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF121212),
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Center(
                child: Text(
                  'YASART SCADA',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(context, Icons.home, 'Home', '/home'),
                  _buildDrawerItem(context, Icons.usb, 'Connect', '/connect'),
                  _buildDrawerItem(
                    context,
                    Icons.dashboard,
                    'Dashboard',
                    '/dashboard',
                  ),
                  _buildDrawerItem(
                    context,
                    Icons.person_add,
                    'Add User',
                    '/add_user',
                  ),
                  _buildDrawerItem(
                    context,
                    Icons.payment,
                    'Billing',
                    '/billing',
                  ),
                  _buildDrawerItem(
                    context,
                    Icons.monitor_heart,
                    'Status',
                    '/status',
                  ),
                  _buildDrawerItem(context, Icons.info, 'About', '/about'),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onTap: () => _handleLogout(context),
              ),
            ),
          ],
        ),
      ),
      body: body,
    );
  }

  ListTile _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    String routeName,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.lightBlueAccent),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () => _navigate(context, routeName),
    );
  }
}
