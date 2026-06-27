part of 'driver_earnings_bloc.dart';

abstract class DriverEarningsState extends Equatable {
  const DriverEarningsState();
  @override
  List<Object?> get props => [];
}

class DriverEarningsInitial extends DriverEarningsState {
  const DriverEarningsInitial();
}

class DriverEarningsLoading extends DriverEarningsState {
  const DriverEarningsLoading();
}

class DriverEarningsLoaded extends DriverEarningsState {
  final DriverEntity driver;
  final WeeklyEarningEntity? earning;
  final DateTime weekStart;

  const DriverEarningsLoaded({
    required this.driver,
    this.earning,
    required this.weekStart,
  });

  @override
  List<Object?> get props => [driver, earning, weekStart];
}

class DriverEarningsSaving extends DriverEarningsState {
  final DriverEntity driver;
  final DateTime weekStart;

  const DriverEarningsSaving({required this.driver, required this.weekStart});

  @override
  List<Object?> get props => [driver, weekStart];
}

class DriverEarningsError extends DriverEarningsState {
  final String message;

  const DriverEarningsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class DriverEarningsActionSuccess extends DriverEarningsLoaded {
  final String message;

  const DriverEarningsActionSuccess({
    required super.driver,
    super.earning,
    required super.weekStart,
    required this.message,
  });

  @override
  List<Object?> get props => [driver, earning, weekStart, message];
}

class DriverEarningsActionError extends DriverEarningsLoaded {
  final String message;

  const DriverEarningsActionError({
    required super.driver,
    super.earning,
    required super.weekStart,
    required this.message,
  });

  @override
  List<Object?> get props => [driver, earning, weekStart, message];
}
