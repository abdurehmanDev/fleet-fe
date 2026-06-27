// ─── API Endpoints ────────────────────────────────────────────────────────────
// Centralized API endpoint constants — all 50 endpoints
// ─────────────────────────────────────────────────────────────────────────────

class ApiEndpoints {
  ApiEndpoints._();

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  static const String me = '/auth/me';

  // ── Profile ───────────────────────────────────────────────────────────────
  static const String profileMe = '/profiles/me';

  // ── Drivers ───────────────────────────────────────────────────────────────
  static const String drivers = '/drivers';
  static const String driversSearch = '/drivers/search';
  static String driverById(String id) => '/drivers/$id';
  static String driverAnalytics(String id) => '/drivers/$id/analytics';

  // ── Vehicles ──────────────────────────────────────────────────────────────
  static const String vehicles = '/vehicles';
  static const String vehiclesSearch = '/vehicles/search';
  static String vehicleById(String id) => '/vehicles/$id';
  static String vehicleStatus(String id) => '/vehicles/$id/status';

  // ── Weekly Earnings ───────────────────────────────────────────────────────
  static const String weeklyEarnings = '/weekly-earnings';
  static const String weeklyEarningsWeek = '/weekly-earnings/week';
  static const String weeklyEarningsAnalytics = '/weekly-earnings/analytics';
  static String weeklyEarningsById(String id) => '/weekly-earnings/$id';
  static String weeklyEarningsByDriver(String driverId) =>
      '/weekly-earnings/driver/$driverId';

  // ── Company Earnings ──────────────────────────────────────────────────────
  static const String companyEarnings = '/company-earnings';
  static const String companyEarningsWeek = '/company-earnings/week';
  static const String companyEarningsAnalytics = '/company-earnings/analytics';

  // ── Dashboard ─────────────────────────────────────────────────────────────
  static const String dashboardSummary = '/dashboard/summary';
  static const String dashboardWeeklyOverview = '/dashboard/weekly-overview';
  static const String dashboardStats = '/dashboard/stats';

  // ── Analytics ─────────────────────────────────────────────────────────────
  static const String analyticsOverview = '/analytics/overview';
  static const String analyticsTrend = '/analytics/trend';
  static const String analyticsDriverRankings = '/analytics/driver-rankings';
  static const String analyticsVehicleStats = '/analytics/vehicle-stats';

  // ── Notifications ─────────────────────────────────────────────────────────
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static const String notificationsReadAll = '/notifications/read-all';
  static String notificationById(String id) => '/notifications/$id';
  static String notificationRead(String id) => '/notifications/$id/read';

  // ── Uploads ───────────────────────────────────────────────────────────────
  static const String uploadSingle = '/uploads/single';
  static const String uploadMultiple = '/uploads/multiple';
  static String uploadDelete(String publicId) => '/uploads/$publicId';

  // ── Health ────────────────────────────────────────────────────────────────
  static const String health = '/health';
}
