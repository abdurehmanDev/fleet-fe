part of 'dashboard_bloc.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => [];
}

class LoadDashboardData extends DashboardEvent {
  final DateTime? date;

  const LoadDashboardData({this.date});

  @override
  List<Object?> get props => [date];
}
