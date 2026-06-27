// ─── Driver Earnings BLoC ─────────────────────────────────────────────────────
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rangrej_fleet/features/drivers/domain/entities/driver_entity.dart';
import 'package:rangrej_fleet/features/drivers/domain/repositories/driver_repository.dart';
import 'package:rangrej_fleet/features/earnings/domain/entities/weekly_earning_entity.dart';
import 'package:rangrej_fleet/features/earnings/domain/repositories/earnings_repository.dart';

part 'driver_earnings_event.dart';
part 'driver_earnings_state.dart';

class DriverEarningsBloc extends Bloc<DriverEarningsEvent, DriverEarningsState> {
  final EarningsRepository _earningsRepository;
  final DriverRepository _driverRepository;

  DriverEarningsBloc({
    required EarningsRepository earningsRepository,
    required DriverRepository driverRepository,
  })  : _earningsRepository = earningsRepository,
        _driverRepository = driverRepository,
        super(const DriverEarningsInitial()) {
    on<LoadDriverEarningsForWeek>(_onLoadForWeek);
    on<SaveDriverEarnings>(_onSaveEarnings);
    on<UpdateDriverEarnings>(_onUpdateEarnings);
  }

  Future<void> _onLoadForWeek(
    LoadDriverEarningsForWeek event,
    Emitter<DriverEarningsState> emit,
  ) async {
    emit(const DriverEarningsLoading());

    // 1. Fetch driver details
    final (driver, driverFailure) = await _driverRepository.getDriverById(event.driverId);
    if (driverFailure != null) {
      emit(DriverEarningsError(message: driverFailure.message));
      return;
    }

    if (driver == null) {
      emit(const DriverEarningsError(message: 'Driver not found'));
      return;
    }

    // 2. Fetch earnings for the week
    final (earning, earningFailure) = await _earningsRepository.getDriverEarningForWeek(
      event.driverId,
      event.weekStart,
    );

    if (earningFailure != null) {
      emit(DriverEarningsError(message: earningFailure.message));
      return;
    }

    emit(DriverEarningsLoaded(
      driver: driver,
      earning: earning,
      weekStart: event.weekStart,
    ));
  }

  Future<void> _onSaveEarnings(
    SaveDriverEarnings event,
    Emitter<DriverEarningsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DriverEarningsLoaded) return;

    emit(DriverEarningsSaving(driver: currentState.driver, weekStart: currentState.weekStart));

    final (saved, failure) = await _earningsRepository.saveDriverEarning(event.earning);

    if (failure != null) {
      emit(DriverEarningsActionError(
        driver: currentState.driver,
        weekStart: currentState.weekStart,
        message: failure.message,
      ));
      return;
    }

    emit(DriverEarningsActionSuccess(
      driver: currentState.driver,
      weekStart: currentState.weekStart,
      earning: saved,
      message: 'Weekly earnings saved successfully!',
    ));
  }

  Future<void> _onUpdateEarnings(
    UpdateDriverEarnings event,
    Emitter<DriverEarningsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DriverEarningsLoaded || currentState.earning == null) return;

    emit(DriverEarningsSaving(driver: currentState.driver, weekStart: currentState.weekStart));

    final (updated, failure) = await _earningsRepository.updateDriverEarning(
      currentState.earning!.id,
      event.earning,
    );

    if (failure != null) {
      emit(DriverEarningsActionError(
        driver: currentState.driver,
        weekStart: currentState.weekStart,
        message: failure.message,
      ));
      return;
    }

    emit(DriverEarningsActionSuccess(
      driver: currentState.driver,
      weekStart: currentState.weekStart,
      earning: updated,
      message: 'Weekly earnings updated successfully!',
    ));
  }
}
