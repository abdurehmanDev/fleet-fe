// ─── App Router ───────────────────────────────────────────────────────────────
// go_router navigation configuration — all routes defined here
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rangrej_fleet/features/analytics/presentation/views/analytics_screen.dart';
import 'package:rangrej_fleet/features/auth/presentation/views/login_screen.dart';
import 'package:rangrej_fleet/features/auth/presentation/views/forgot_password_screen.dart';
import 'package:rangrej_fleet/features/dashboard/presentation/views/dashboard_screen.dart';
import 'package:rangrej_fleet/features/splash/presentation/views/splash_screen.dart';
import 'package:rangrej_fleet/shared/views/not_found_screen.dart';
import 'package:rangrej_fleet/features/drivers/presentation/views/add_driver_screen.dart';
import 'package:rangrej_fleet/features/drivers/presentation/views/drivers_list_screen.dart';
import 'package:rangrej_fleet/features/drivers/presentation/views/edit_driver_screen.dart';
import 'package:rangrej_fleet/features/earnings/presentation/views/company_earnings_screen.dart';
import 'package:rangrej_fleet/features/earnings/presentation/views/driver_earnings_screen.dart';
import 'package:rangrej_fleet/features/home/presentation/views/home_screen.dart';
import 'package:rangrej_fleet/features/vehicles/presentation/views/add_vehicle_screen.dart';
import 'package:rangrej_fleet/features/vehicles/presentation/views/edit_vehicle_screen.dart';
import 'package:rangrej_fleet/features/vehicles/presentation/views/vehicles_list_screen.dart';
import 'package:rangrej_fleet/features/calendar/presentation/views/calendar_screen.dart';
import 'package:rangrej_fleet/features/notifications/presentation/views/notifications_screen.dart';
import 'package:rangrej_fleet/features/profile/presentation/views/profile_screen.dart';
import 'package:rangrej_fleet/shared/views/main_layout.dart';

// Route name constants
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String drivers = '/drivers';
  static const String driverDetail = '/drivers/:id';
  static const String addDriver = '/drivers/add';
  static const String vehicles = '/vehicles';
  static const String vehicleDetail = '/vehicles/:id';
  static const String addVehicle = '/vehicles/add';
  static const String analytics = '/analytics';
  static const String earnings = '/earnings';
  static const String calendar = '/calendar';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String notFound = '/404';
}

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      // ── Splash ────────────────────────────────────────────────────────────
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // ── Auth ──────────────────────────────────────────────────────────────
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // ── Shell Layout (Bottom Nav & Drawer) ────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainLayout(navigationShell: navigationShell),
        branches: [
          // Branch 0 - Fleet
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
              GoRoute(
                path: AppRoutes.dashboard,
                name: 'dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
              GoRoute(
                path: AppRoutes.vehicles,
                name: 'vehicles',
                builder: (context, state) => const VehiclesListScreen(),
              ),
              GoRoute(
                path: '/edit-vehicle/:id',
                name: 'editVehicle',
                builder: (context, state) => EditVehicleScreen(id: state.pathParameters['id']!),
              ),
            ],
          ),
          // Branch 1 - Drivers
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.drivers,
                name: 'drivers',
                builder: (context, state) => const DriversListScreen(),
              ),
              GoRoute(
                path: '/edit-driver/:id',
                name: 'editDriver',
                builder: (context, state) => EditDriverScreen(id: state.pathParameters['id']!),
              ),
              GoRoute(
                path: '/driver-earnings/:id',
                name: 'driverDetail',
                builder: (context, state) => DriverEarningsScreen(id: state.pathParameters['id']!),
              ),
            ],
          ),
          // Branch 2 - Calendar
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.calendar,
                name: 'calendar',
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),
          // Branch 3 - Reports
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.analytics,
                name: 'analytics',
                builder: (context, state) => const AnalyticsScreen(),
              ),
            ],
          ),
        ],
      ),

      // ── Other Screens (No Bottom Nav) ─────────────────────────────────────
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.addDriver,
        name: 'addDriver',
        builder: (context, state) => const AddDriverScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.addVehicle,
        name: 'addVehicle',
        builder: (context, state) => const AddVehicleScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.earnings,
        name: 'earnings',
        builder: (context, state) => const CompanyEarningsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // ── Not Found ─────────────────────────────────────────────────────────
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.notFound,
        name: '404',
        builder: (context, state) => const NotFoundScreen(),
      ),
    ],
  );
}
