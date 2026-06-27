part of 'dashboard_bloc.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final DashboardSummaryModel summary;
  final WeeklyOverviewModel overview;
  final List<Map<String, dynamic>> companyTrend;
  final List<Map<String, dynamic>> driverTrend;
  final DateTime selectedDate;

  const DashboardLoaded({
    required this.summary,
    required this.overview,
    required this.companyTrend,
    required this.driverTrend,
    required this.selectedDate,
  });

  @override
  List<Object?> get props => [summary, overview, companyTrend, driverTrend, selectedDate];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}
