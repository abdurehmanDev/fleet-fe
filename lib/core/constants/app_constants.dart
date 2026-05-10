// ─── App Constants ───────────────────────────────────────────────────────────
// All app-wide constant values (strings, durations, sizes, etc.)
// ─────────────────────────────────────────────────────────────────────────────

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Rangrej Fleet';
  static const String appVersion = '1.0.0';

  // API Timeouts
  static const int connectTimeout = 30000; // ms
  static const int receiveTimeout = 30000; // ms
  static const int sendTimeout = 30000;    // ms

  // Pagination
  static const int defaultPageSize = 20;
  static const int defaultPage = 1;

  // Token Keys (Secure Storage)
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';

  // SharedPreferences Keys
  static const String onboardingKey = 'onboarding_completed';
  static const String themeKey = 'app_theme';
  static const String localeKey = 'app_locale';

  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String timeFormat = 'HH:mm';

  // Durations
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 2);
}
