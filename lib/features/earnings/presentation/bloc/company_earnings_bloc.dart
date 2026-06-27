// ─── Company Earnings BLoC ───────────────────────────────────────────────────
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rangrej_fleet/features/earnings/domain/entities/company_earning_entity.dart';
import 'package:rangrej_fleet/features/earnings/domain/repositories/earnings_repository.dart';

part 'company_earnings_event.dart';
part 'company_earnings_state.dart';

class CompanyEarningsBloc extends Bloc<CompanyEarningsEvent, CompanyEarningsState> {
  final EarningsRepository _repository;

  CompanyEarningsBloc({required EarningsRepository repository})
      : _repository = repository,
        super(const CompanyEarningsInitial()) {
    on<LoadCompanyEarningsForWeek>(_onLoadForWeek);
    on<SaveCompanyEarnings>(_onSaveEarnings);
  }

  Future<void> _onLoadForWeek(
    LoadCompanyEarningsForWeek event,
    Emitter<CompanyEarningsState> emit,
  ) async {
    emit(const CompanyEarningsLoading());

    // 1. Fetch weekly summary stats (total payouts, active drivers, completed trips, operating costs)
    final (summary, summaryFailure) = await _repository.getWeekPayoutSummary(event.weekStart);
    if (summaryFailure != null) {
      emit(CompanyEarningsError(message: summaryFailure.message));
      return;
    }

    final double totalPayouts = double.tryParse(summary?['totalPayouts']?.toString() ?? '0.0') ?? 0.0;
    final int activeDrivers = int.tryParse(summary?['activeDrivers']?.toString() ?? '0') ?? 0;
    final int completedTrips = int.tryParse(summary?['completedTrips']?.toString() ?? '0') ?? 0;
    final double operatingCosts = double.tryParse(summary?['estimatedOperatingCosts']?.toString() ?? '0.0') ?? 0.0;

    // 2. Fetch existing saved company earnings if any
    final (savedEarning, earningFailure) = await _repository.getCompanyEarningForWeek(event.weekStart);
    if (earningFailure != null) {
      emit(CompanyEarningsError(message: earningFailure.message));
      return;
    }

    emit(CompanyEarningsLoaded(
      weekStart: event.weekStart,
      totalDriverPayouts: totalPayouts,
      activeDrivers: activeDrivers,
      completedTrips: completedTrips,
      operatingCosts: operatingCosts,
      existingEarning: savedEarning,
    ));
  }

  Future<void> _onSaveEarnings(
    SaveCompanyEarnings event,
    Emitter<CompanyEarningsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CompanyEarningsLoaded) return;

    emit(CompanyEarningsSaving(
      weekStart: currentState.weekStart,
      totalDriverPayouts: currentState.totalDriverPayouts,
      activeDrivers: currentState.activeDrivers,
      completedTrips: currentState.completedTrips,
      operatingCosts: currentState.operatingCosts,
      existingEarning: currentState.existingEarning,
    ));

    final (saved, failure) = await _repository.saveCompanyEarning(event.earning);

    if (failure != null) {
      emit(CompanyEarningsActionError(
        weekStart: currentState.weekStart,
        totalDriverPayouts: currentState.totalDriverPayouts,
        activeDrivers: currentState.activeDrivers,
        completedTrips: currentState.completedTrips,
        operatingCosts: currentState.operatingCosts,
        existingEarning: currentState.existingEarning,
        message: failure.message,
      ));
      return;
    }

    emit(CompanyEarningsActionSuccess(
      weekStart: currentState.weekStart,
      totalDriverPayouts: currentState.totalDriverPayouts,
      activeDrivers: currentState.activeDrivers,
      completedTrips: currentState.completedTrips,
      operatingCosts: currentState.operatingCosts,
      existingEarning: saved,
      message: 'Company earnings saved successfully!',
    ));
  }
}
