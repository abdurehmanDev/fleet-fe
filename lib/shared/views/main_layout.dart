import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rangrej_fleet/app/routes.dart';
import 'package:rangrej_fleet/core/di/injector.dart';
import 'package:rangrej_fleet/core/themes/app_theme.dart';
import 'package:rangrej_fleet/features/auth/domain/repositories/auth_repository.dart';
import 'package:rangrej_fleet/shared/helpers/ui_helper.dart';

class MainLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({super.key, required this.navigationShell});

  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  String _userName = 'Fleet Manager';
  String _userEmail = 'admin@rangrejfleet.com';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final (user, _) = await sl<AuthRepository>().getMe();
    if (user != null) {
      setState(() {
        _userName = user.name;
        _userEmail = user.email;
      });
    }
  }

  void _onItemTapped(int index, BuildContext context) {
    widget.navigationShell.goBranch(
      index,
      // A common pattern when using bottom navigation bars is to support
      // navigating to the initial location when tapping the item that is
      // already active. This example demonstrates how to support this behavior,
      // using the initialLocation parameter of goBranch.
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  Future<void> _onLogout(BuildContext context) async {
    final confirmed = await UIHelper.showConfirmDialog(
      context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out of your Rangrej Fleet account?',
      confirmText: 'Sign Out',
      isDangerous: true,
    );

    if (confirmed == true) {
      await sl<AuthRepository>().logout();
      if (mounted) {
        context.go(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: MainLayout.scaffoldKey,
      drawer: _buildDrawer(context),
      body: widget.navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.navigationShell.currentIndex,
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
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.white,
                  radius: 30,
                  child: Text(
                    _userName.isNotEmpty ? _userName[0].toUpperCase() : 'M',
                    style: AppTextStyles.heading1.copyWith(color: AppColors.primary, fontSize: 24),
                  ),
                ),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  _userName,
                  style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _userEmail,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.dashboard);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('My Profile'),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.profile);
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.notifications);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
            onTap: () {
              Navigator.pop(context);
              _onLogout(context);
            },
          ),
        ],
      ),
    );
  }
}
