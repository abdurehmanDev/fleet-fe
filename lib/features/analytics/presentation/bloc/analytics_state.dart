part of 'analytics_bloc.dart';

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();
  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading();
}

class AnalyticsLoaded extends AnalyticsState {
  final List<DriverEntity> drivers;
  final Map<String, dynamic> overviewStats;
  final List<Map<String, dynamic>> companyPerformance;
  final List<Map<String, dynamic>>? driverPerformance;
  final String selectedDriver;

  const AnalyticsLoaded({
    required this.drivers,
    required this.overviewStats,
    required this.companyPerformance,
    this.driverPerformance,
    required this.selectedDriver,
  });

  AnalyticsLoaded copyWith({
    List<DriverEntity>? drivers,
    Map<String, dynamic>? overviewStats,
    List<Map<String, dynamic>>? companyPerformance,
    List<Map<String, dynamic>>? driverPerformance,
    String? selectedDriver,
  }) {
    return AnalyticsLoaded(
      drivers: drivers ?? this.drivers,
      overviewStats: overviewStats ?? this.overviewStats,
      companyPerformance: companyPerformance ?? this.companyPerformance,
      driverPerformance: driverPerformance ?? this.driverPerformance,
      selectedDriver: selectedDriver ?? this.selectedDriver,
    );
  }

  @override
  List<Object?> get props => [
        drivers,
        overviewStats,
        companyPerformance,
        driverPerformance,
        selectedDriver,
      ];
}

class AnalyticsError extends AnalyticsState {
  final String message;

  const AnalyticsError({required this.message});

  @override
  List<Object?> get props => [message];
}
