import 'package:flutter/material.dart';

class BaseScreen extends StatelessWidget {
  final String title;
  final Widget body;
  final String? role; // Role to control drawer items visibility

  const BaseScreen({
    super.key,
    required this.title,
    required this.body,
    this.role,
  });

  void _navigate(BuildContext context, String route) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    Navigator.of(context).pop(); // Close drawer first
    if (currentRoute != route) {
      Navigator.of(context).pushReplacementNamed(route);
    }
  }

  void _handleLogout(BuildContext context) {
    // Clear navigation stack and go to login screen
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.lightBlueAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF121212),
        elevation: 2,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.lightBlueAccent),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'Open navigation menu',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
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
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Center(
                child: Text(
                  'YASART SCADA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _drawerItem(context,
                      icon: Icons.home, text: 'Home', route: '/home'),
                  _drawerItem(context,
                      icon: Icons.usb, text: 'Connect', route: '/connect'),
                  _drawerItem(context,
                      icon: Icons.dashboard,
                      text: 'Dashboard',
                      route: '/dashboard'),

                  // Add User and List Users only for admin
                  if (role == 'admin') ...[
                    _drawerItem(context,
                        icon: Icons.person_add,
                        text: 'Add User',
                        route: '/add_user'),
                    _drawerItem(context,
                        icon: Icons.view_list,
                        text: 'List Users',
                        route: '/user'),
                    _drawerItem(context,
                        icon: Icons.receipt,
                        text: 'Billing (All Users)',
                        route: '/billing'),
                  ] else
                    // For non-admins, only show own billing
                    _drawerItem(context,
                        icon: Icons.receipt,
                        text: 'Billing',
                        route: '/billing'),

                  _drawerItem(context,
                      icon: Icons.bar_chart, text: 'Status', route: '/status'),
                  _drawerItem(context,
                      icon: Icons.info_outline, text: 'About', route: '/about'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
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

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.lightBlueAccent),
      title: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: () => _navigate(context, route),
    );
  }
}
