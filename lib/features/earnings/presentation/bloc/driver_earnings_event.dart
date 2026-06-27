part of 'driver_earnings_bloc.dart';

abstract class DriverEarningsEvent extends Equatable {
  const DriverEarningsEvent();
  @override
  List<Object?> get props => [];
}

class LoadDriverEarningsForWeek extends DriverEarningsEvent {
  final String driverId;
  final DateTime weekStart;

  const LoadDriverEarningsForWeek({required this.driverId, required this.weekStart});

  @override
  List<Object?> get props => [driverId, weekStart];
}

class SaveDriverEarnings extends DriverEarningsEvent {
  final WeeklyEarningEntity earning;

  const SaveDriverEarnings({required this.earning});

  @override
  List<Object?> get props => [earning];
}

class UpdateDriverEarnings extends DriverEarningsEvent {
  final WeeklyEarningEntity earning;

  const UpdateDriverEarnings({required this.earning});

  @override
  List<Object?> get props => [earning];
}
