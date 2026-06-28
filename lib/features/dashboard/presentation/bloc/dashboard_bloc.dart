// ─── Dashboard BLoC ───────────────────────────────────────────────────────────
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rangrej_fleet/features/dashboard/data/models/dashboard_summary_model.dart';
import 'package:rangrej_fleet/features/dashboard/domain/repositories/dashboard_repository.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _repository;

  DashboardBloc({required DashboardRepository repository})
      : _repository = repository,
        super(const DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());

    // 1. Fetch dashboard summary
    final (summary, summaryFailure) = await _repository.getDashboardSummary(
      date: event.date,
      forceRefresh: event.forceRefresh,
    );
    if (summaryFailure != null) {
      emit(DashboardError(message: summaryFailure.message));
      return;
    }

    // 2. Fetch weekly overview map
    final (overview, overviewFailure) = await _repository.getWeeklyOverview(
      forceRefresh: event.forceRefresh,
    );
    if (overviewFailure != null) {
      emit(DashboardError(message: overviewFailure.message));
      return;
    }

    // 3. Fetch company analytics trend
    final (companyTrend, _) = await _repository.getCompanyAnalyticsTrend(
      forceRefresh: event.forceRefresh,
    );

    // 4. Fetch driver earnings trend
    final (driverTrend, _) = await _repository.getDriverEarningsTrend(
      forceRefresh: event.forceRefresh,
    );

    if (summary != null && overview != null) {
      emit(DashboardLoaded(
        summary: summary,
        overview: overview,
        companyTrend: companyTrend ?? [],
        driverTrend: driverTrend ?? [],
        selectedDate: event.date ?? DateTime.now(),
      ));
    } else {
      emit(const DashboardError(message: 'Failed to retrieve dashboard summary data'));
    }
  }
}
