// ─── Drivers BLoC ─────────────────────────────────────────────────────────────
// Business logic controller for drivers — maps Events → States
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rangrej_fleet/features/drivers/data/models/driver_model.dart';
import 'package:rangrej_fleet/features/drivers/domain/entities/driver_entity.dart';
import 'package:rangrej_fleet/features/drivers/domain/repositories/driver_repository.dart';

part 'drivers_event.dart';
part 'drivers_state.dart';

class DriversBloc extends Bloc<DriversEvent, DriversState> {
  final DriverRepository _repository;

  DriversBloc({required DriverRepository repository})
      : _repository = repository,
        super(const DriversInitial()) {
    on<LoadDrivers>(_onLoadDrivers);
    on<LoadMoreDrivers>(_onLoadMoreDrivers);
    on<SearchDrivers>(_onSearchDrivers);
    on<DeleteDriver>(_onDeleteDriver);
    on<CreateDriver>(_onCreateDriver);
    on<LoadDriverDetail>(_onLoadDriverDetail);
    on<UpdateDriver>(_onUpdateDriver);
    on<RefreshDrivers>(_onRefreshDrivers);
  }

  // ── Load drivers (initial or first page) ──────────────────────────────────
  Future<void> _onLoadDrivers(
    LoadDrivers event,
    Emitter<DriversState> emit,
  ) async {
    emit(const DriversLoading());

    final (drivers, meta, failure) = await _repository.getDrivers(
      page: 1,
      limit: 10,
    );

    if (failure != null) {
      emit(DriversError(message: failure.message));
      return;
    }

    emit(DriversLoaded(
      drivers: drivers,
      meta: meta,
      hasMore: meta?.hasMore ?? false,
      currentPage: 1,
    ));
  }

  // ── Load more (pagination) ────────────────────────────────────────────────
  Future<void> _onLoadMoreDrivers(
    LoadMoreDrivers event,
    Emitter<DriversState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DriversLoaded || !currentState.hasMore || currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;
    final (drivers, meta, failure) = await _repository.getDrivers(
      page: nextPage,
      limit: 10,
    );

    if (failure != null) {
      emit(currentState.copyWith(isLoadingMore: false));
      return;
    }

    emit(DriversLoaded(
      drivers: [...currentState.drivers, ...drivers],
      meta: meta,
      hasMore: meta?.hasMore ?? false,
      currentPage: nextPage,
    ));
  }

  // ── Search ────────────────────────────────────────────────────────────────
  Future<void> _onSearchDrivers(
    SearchDrivers event,
    Emitter<DriversState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(const LoadDrivers());
      return;
    }

    emit(const DriversLoading());

    final (drivers, failure) = await _repository.searchDrivers(event.query);

    if (failure != null) {
      emit(DriversError(message: failure.message));
      return;
    }

    emit(DriversLoaded(
      drivers: drivers ?? [],
      hasMore: false,
      currentPage: 1,
      isSearchResult: true,
    ));
  }

  // ── Delete ────────────────────────────────────────────────────────────────
  Future<void> _onDeleteDriver(
    DeleteDriver event,
    Emitter<DriversState> emit,
  ) async {
    final (success, failure) = await _repository.deleteDriver(event.id);

    if (failure != null) {
      emit(DriverActionError(message: failure.message));
      // Restore previous state
      if (state is DriversLoaded) return;
      return;
    }

    emit(DriverActionSuccess(message: 'Driver deleted successfully'));
    add(const LoadDrivers()); // Refresh list
  }

  // ── Create ────────────────────────────────────────────────────────────────
  Future<void> _onCreateDriver(
    CreateDriver event,
    Emitter<DriversState> emit,
  ) async {
    emit(const DriverSaving());

    final (driver, failure) = await _repository.createDriver(
      name: event.name,
      mobile: event.mobile,
    );

    if (failure != null) {
      emit(DriverActionError(message: failure.message));
      return;
    }

    emit(DriverActionSuccess(message: 'Driver added successfully!'));
  }

  // ── Load Detail ───────────────────────────────────────────────────────────
  Future<void> _onLoadDriverDetail(
    LoadDriverDetail event,
    Emitter<DriversState> emit,
  ) async {
    emit(const DriverDetailLoading());

    final (driver, failure) = await _repository.getDriverById(event.id);

    if (failure != null) {
      emit(DriversError(message: failure.message));
      return;
    }

    if (driver != null) {
      emit(DriverDetailLoaded(driver: driver));
    }
  }

  // ── Update ────────────────────────────────────────────────────────────────
  Future<void> _onUpdateDriver(
    UpdateDriver event,
    Emitter<DriversState> emit,
  ) async {
    emit(const DriverSaving());

    final (driver, failure) = await _repository.updateDriver(
      event.id,
      name: event.name,
      mobile: event.mobile,
    );

    if (failure != null) {
      emit(DriverActionError(message: failure.message));
      return;
    }

    emit(DriverActionSuccess(message: 'Driver updated successfully!'));
  }

  // ── Refresh ───────────────────────────────────────────────────────────────
  Future<void> _onRefreshDrivers(
    RefreshDrivers event,
    Emitter<DriversState> emit,
  ) async {
    final (drivers, meta, failure) = await _repository.getDrivers(
      page: 1,
      limit: 10,
      forceRefresh: true,
    );

    if (failure != null) {
      emit(DriversError(message: failure.message));
      return;
    }

    emit(DriversLoaded(
      drivers: drivers,
      meta: meta,
      hasMore: meta?.hasMore ?? false,
      currentPage: 1,
    ));
  }
}
