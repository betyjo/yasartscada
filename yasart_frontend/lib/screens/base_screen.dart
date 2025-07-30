import 'package:flutter/material.dart';

class BaseScreen extends StatelessWidget {
  final String title;
  final Widget body;

  const BaseScreen({super.key, required this.title, required this.body});

  void _navigate(BuildContext context, String route) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute != route) {
      Navigator.of(context).pushReplacementNamed(route);
    }
    // Close the drawer after navigating or if already on the same page
    Navigator.of(context).pop();
  }

  void _handleLogout(BuildContext context) {
    // TODO: Implement your logout logic here (e.g., FirebaseAuth.instance.signOut())
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'Open navigation menu',
          ),
        ),
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
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _drawerItem(
                    context,
                    icon: Icons.home,
                    text: 'Home',
                    route: '/home',
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.usb,
                    text: 'Connect',
                    route: '/connect',
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.dashboard,
                    text: 'Dashboard',
                    route: '/dashboard',
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.person_add,
                    text: 'Add User',
                    route: '/add_user',
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.receipt,
                    text: 'Billing',
                    route: '/billing',
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.bar_chart,
                    text: 'Status',
                    route: '/status',
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.info_outline,
                    text: 'About',
                    route: '/about',
                  ),
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
      title: Text(text, style: const TextStyle(color: Colors.white)),
      onTap: () => _navigate(context, route),
    );
  }
}
