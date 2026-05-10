import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rangrej_fleet/app/routes.dart';
import 'package:rangrej_fleet/core/themes/app_theme.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(AppRoutes.home) || location.startsWith(AppRoutes.dashboard) || location.startsWith(AppRoutes.vehicles) || location.startsWith('/edit-vehicle')) {
      return 0;
    }
    if (location.startsWith(AppRoutes.drivers) || location.startsWith('/edit-driver') || location.startsWith('/driver-earnings')) {
      return 1;
    }
    if (location.startsWith(AppRoutes.calendar)) {
      return 2;
    }
    if (location.startsWith(AppRoutes.analytics)) {
      return 3;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.drivers);
        break;
      case 2:
        context.go(AppRoutes.calendar);
        break;
      case 3:
        context.go(AppRoutes.analytics);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: _buildDrawer(context),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey600,
        backgroundColor: AppColors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.local_taxi), label: 'Fleet'),
          BottomNavigationBarItem(icon: Icon(Icons.person_pin), label: 'Drivers'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_view_week), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'Reports'),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.white,
                  radius: 30,
                  child: Icon(Icons.local_shipping, size: 30, color: AppColors.primary),
                ),
                SizedBox(height: AppDimensions.md),
                Text('Fleet Manager', style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Rangrej Fleet Admin', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.dashboard);
            },
          ),
          ListTile(
            leading: const Icon(Icons.build),
            title: const Text('Maintenance Logs'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.ev_station),
            title: const Text('Fuel Tracking'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Owner Settings'),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }
}
