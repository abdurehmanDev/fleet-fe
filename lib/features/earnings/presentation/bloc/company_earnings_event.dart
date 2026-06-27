part of 'company_earnings_bloc.dart';

abstract class CompanyEarningsEvent extends Equatable {
  const CompanyEarningsEvent();
  @override
  List<Object?> get props => [];
}

class LoadCompanyEarningsForWeek extends CompanyEarningsEvent {
  final DateTime weekStart;

  const LoadCompanyEarningsForWeek({required this.weekStart});

  @override
  List<Object?> get props => [weekStart];
}

class SaveCompanyEarnings extends CompanyEarningsEvent {
  final CompanyEarningEntity earning;

  const SaveCompanyEarnings({required this.earning});

  @override
  List<Object?> get props => [earning];
}
