part of 'analytics_bloc.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();
  @override
  List<Object?> get props => [];
}

class LoadAnalyticsData extends AnalyticsEvent {
  const LoadAnalyticsData();
}

class LoadDriverSpecificAnalytics extends AnalyticsEvent {
  final String driverId;
  final String driverName;

  const LoadDriverSpecificAnalytics({required this.driverId, required this.driverName});

  @override
  List<Object?> get props => [driverId, driverName];
}
