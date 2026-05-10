// ─── API Endpoints ────────────────────────────────────────────────────────────
// Centralized API endpoint constants
// ─────────────────────────────────────────────────────────────────────────────

class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Drivers
  static const String drivers = '/drivers';
  static String driverById(String id) => '/drivers/$id';
  static const String driverEarnings = '/drivers/earnings';

  // Vehicles
  static const String vehicles = '/vehicles';
  static String vehicleById(String id) => '/vehicles/$id';

  // Analytics
  static const String analytics = '/analytics';
  static const String companyEarnings = '/analytics/earnings';
  static const String weeklyEarnings = '/analytics/weekly';
}
