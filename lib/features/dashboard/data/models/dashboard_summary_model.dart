// ─── Dashboard Summary Model ──────────────────────────────────────────────────
class DashboardSummaryModel {
  final int totalDrivers;
  final int activeDrivers;
  final int totalVehicles;
  final int activeVehicles;
  final int maintenanceVehicles;
  final int completedTrips;
  final double totalPayouts;
  final double estimatedOperatingCosts;
  final String selectedWeekLabel;

  const DashboardSummaryModel({
    required this.totalDrivers,
    required this.activeDrivers,
    required this.totalVehicles,
    required this.activeVehicles,
    required this.maintenanceVehicles,
    required this.completedTrips,
    required this.totalPayouts,
    required this.estimatedOperatingCosts,
    this.selectedWeekLabel = '',
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    final selectedWeekJson = json['selected_week'] as Map<String, dynamic>?;
    final totalDrivers = int.tryParse(json['total_drivers']?.toString() ?? json['totalDrivers']?.toString() ?? '') ?? 0;
    final totalVehicles = int.tryParse(json['total_vehicles']?.toString() ?? json['totalVehicles']?.toString() ?? '') ?? 0;
    final weeklyEarningsCount = int.tryParse(json['weekly_earnings_count']?.toString() ?? json['completedTrips']?.toString() ?? '') ?? 0;

    return DashboardSummaryModel(
      totalDrivers: totalDrivers,
      activeDrivers: totalDrivers,
      totalVehicles: totalVehicles,
      activeVehicles: totalVehicles,
      maintenanceVehicles: 0,
      completedTrips: weeklyEarningsCount,
      totalPayouts: 0.0,
      estimatedOperatingCosts: 0.0,
      selectedWeekLabel: selectedWeekJson?['label']?.toString() ?? '',
    );
  }
}

class WeeklyOverviewModel {
  final String week;
  final double companyEarning;
  final double totalDriverPayouts;
  final double ownerEarning;
  final int driverEarningsCount;
  final int activeVehicles;

  const WeeklyOverviewModel({
    required this.week,
    required this.companyEarning,
    required this.totalDriverPayouts,
    required this.ownerEarning,
    required this.driverEarningsCount,
    required this.activeVehicles,
  });

  factory WeeklyOverviewModel.fromJson(Map<String, dynamic> json) {
    return WeeklyOverviewModel(
      week: json['week']?.toString() ?? '',
      companyEarning: double.tryParse(json['companyEarning']?.toString() ?? json['company_earning']?.toString() ?? json['revenue']?.toString() ?? '') ?? 0.0,
      totalDriverPayouts: double.tryParse(json['totalDriverPayouts']?.toString() ?? json['total_driver_payouts']?.toString() ?? json['driver_payouts']?.toString() ?? '') ?? 0.0,
      ownerEarning: double.tryParse(json['ownerEarning']?.toString() ?? json['owner_earning']?.toString() ?? json['owner_share']?.toString() ?? '') ?? 0.0,
      driverEarningsCount: int.tryParse(json['driverEarningsCount']?.toString() ?? json['driver_earnings_count']?.toString() ?? '') ?? 0,
      activeVehicles: int.tryParse(json['activeVehicles']?.toString() ?? json['active_vehicles']?.toString() ?? '') ?? 0,
    );
  }
}
