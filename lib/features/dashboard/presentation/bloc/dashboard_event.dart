part of 'dashboard_bloc.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => [];
}

class LoadDashboardData extends DashboardEvent {
  final DateTime? date;
  final bool forceRefresh;

  const LoadDashboardData({this.date, this.forceRefresh = false});

  @override
  List<Object?> get props => [date, forceRefresh];
}
