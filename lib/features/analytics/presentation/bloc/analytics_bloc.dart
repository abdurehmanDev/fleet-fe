// ─── Analytics BLoC ───────────────────────────────────────────────────────────
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rangrej_fleet/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:rangrej_fleet/features/drivers/domain/entities/driver_entity.dart';
import 'package:rangrej_fleet/features/drivers/domain/repositories/driver_repository.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsRepository _analyticsRepository;
  final DriverRepository _driverRepository;

  AnalyticsBloc({
    required AnalyticsRepository analyticsRepository,
    required DriverRepository driverRepository,
  })  : _analyticsRepository = analyticsRepository,
        _driverRepository = driverRepository,
        super(const AnalyticsInitial()) {
    on<LoadAnalyticsData>(_onLoadAnalyticsData);
    on<LoadDriverSpecificAnalytics>(_onLoadDriverAnalytics);
  }

  Future<void> _onLoadAnalyticsData(
    LoadAnalyticsData event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());

    try {
      // 1. Fetch drivers list for filter
      final (drivers, _, driverFailure) = await _driverRepository.getDrivers(page: 1, limit: 100);
      if (driverFailure != null) {
        emit(AnalyticsError(message: driverFailure.message));
        return;
      }

      // 2. Fetch analytics overview
      final (overview, overviewFailure) = await _analyticsRepository.getAnalyticsOverview();
      if (overviewFailure != null) {
        emit(AnalyticsError(message: overviewFailure.message));
        return;
      }

      // 3. Fetch company weekly performance charts
      final (chartData, chartFailure) = await _analyticsRepository.getCompanyAnalytics(weeks: 4);
      if (chartFailure != null) {
        emit(AnalyticsError(message: chartFailure.message));
        return;
      }

      emit(AnalyticsLoaded(
        drivers: drivers,
        overviewStats: overview ?? {},
        companyPerformance: chartData ?? [],
        selectedDriver: 'All Drivers',
      ));
    } catch (e) {
      emit(AnalyticsError(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  Future<void> _onLoadDriverAnalytics(
    LoadDriverSpecificAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    final cs = state;
    if (cs is! AnalyticsLoaded) return;

    emit(const AnalyticsLoading());

    try {
      if (event.driverId == 'All Drivers' || event.driverId.isEmpty) {
        add(const LoadAnalyticsData());
        return;
      }

      final (driverPerformance, failure) = await _analyticsRepository.getDriverAnalytics(event.driverId);
      if (failure != null) {
        emit(AnalyticsError(message: failure.message));
        return;
      }

      emit(cs.copyWith(
        driverPerformance: driverPerformance ?? [],
        selectedDriver: event.driverName,
      ));
    } catch (e) {
      emit(AnalyticsError(message: 'Unexpected error: ${e.toString()}'));
    }
  }
}
