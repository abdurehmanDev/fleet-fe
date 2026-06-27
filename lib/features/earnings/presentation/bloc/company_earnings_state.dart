part of 'company_earnings_bloc.dart';

abstract class CompanyEarningsState extends Equatable {
  const CompanyEarningsState();
  @override
  List<Object?> get props => [];
}

class CompanyEarningsInitial extends CompanyEarningsState {
  const CompanyEarningsInitial();
}

class CompanyEarningsLoading extends CompanyEarningsState {
  const CompanyEarningsLoading();
}

class CompanyEarningsLoaded extends CompanyEarningsState {
  final DateTime weekStart;
  final double totalDriverPayouts;
  final int activeDrivers;
  final int completedTrips;
  final double operatingCosts;
  final CompanyEarningEntity? existingEarning;

  const CompanyEarningsLoaded({
    required this.weekStart,
    required this.totalDriverPayouts,
    required this.activeDrivers,
    required this.completedTrips,
    required this.operatingCosts,
    this.existingEarning,
  });

  @override
  List<Object?> get props => [
        weekStart,
        totalDriverPayouts,
        activeDrivers,
        completedTrips,
        operatingCosts,
        existingEarning,
      ];
}

class CompanyEarningsSaving extends CompanyEarningsLoaded {
  const CompanyEarningsSaving({
    required super.weekStart,
    required super.totalDriverPayouts,
    required super.activeDrivers,
    required super.completedTrips,
    required super.operatingCosts,
    super.existingEarning,
  });
}

class CompanyEarningsError extends CompanyEarningsState {
  final String message;

  const CompanyEarningsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class CompanyEarningsActionSuccess extends CompanyEarningsLoaded {
  final String message;

  const CompanyEarningsActionSuccess({
    required super.weekStart,
    required super.totalDriverPayouts,
    required super.activeDrivers,
    required super.completedTrips,
    required super.operatingCosts,
    super.existingEarning,
    required this.message,
  });

  @override
  List<Object?> get props => [
        weekStart,
        totalDriverPayouts,
        activeDrivers,
        completedTrips,
        operatingCosts,
        existingEarning,
        message,
      ];
}

class CompanyEarningsActionError extends CompanyEarningsLoaded {
  final String message;

  const CompanyEarningsActionError({
    required super.weekStart,
    required super.totalDriverPayouts,
    required super.activeDrivers,
    required super.completedTrips,
    required super.operatingCosts,
    super.existingEarning,
    required this.message,
  });

  @override
  List<Object?> get props => [
        weekStart,
        totalDriverPayouts,
        activeDrivers,
        completedTrips,
        operatingCosts,
        existingEarning,
        message,
      ];
}
