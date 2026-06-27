// ─── Vehicles BLoC ────────────────────────────────────────────────────────────
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rangrej_fleet/features/drivers/data/models/driver_model.dart';
import 'package:rangrej_fleet/features/vehicles/domain/entities/vehicle_entity.dart';
import 'package:rangrej_fleet/features/vehicles/domain/repositories/vehicle_repository.dart';

part 'vehicles_event.dart';
part 'vehicles_state.dart';

class VehiclesBloc extends Bloc<VehiclesEvent, VehiclesState> {
  final VehicleRepository _repository;

  VehiclesBloc({required VehicleRepository repository})
      : _repository = repository,
        super(const VehiclesInitial()) {
    on<LoadVehicles>(_onLoadVehicles);
    on<LoadMoreVehicles>(_onLoadMoreVehicles);
    on<FilterVehiclesByStatus>(_onFilterByStatus);
    on<SearchVehicles>(_onSearchVehicles);
    on<DeleteVehicle>(_onDeleteVehicle);
    on<CreateVehicle>(_onCreateVehicle);
    on<LoadVehicleDetail>(_onLoadVehicleDetail);
    on<UpdateVehicle>(_onUpdateVehicle);
    on<RefreshVehicles>(_onRefreshVehicles);
  }

  Future<void> _onLoadVehicles(LoadVehicles event, Emitter<VehiclesState> emit) async {
    emit(const VehiclesLoading());
    final (vehicles, meta, failure) = await _repository.getVehicles(page: 1, limit: 10);
    if (failure != null) { emit(VehiclesError(message: failure.message)); return; }
    emit(VehiclesLoaded(vehicles: vehicles, meta: meta, hasMore: meta?.hasMore ?? false, currentPage: 1));
  }

  Future<void> _onLoadMoreVehicles(LoadMoreVehicles event, Emitter<VehiclesState> emit) async {
    final cs = state;
    if (cs is! VehiclesLoaded || !cs.hasMore || cs.isLoadingMore) return;
    emit(cs.copyWith(isLoadingMore: true));
    final nextPage = cs.currentPage + 1;
    final (vehicles, meta, failure) = await _repository.getVehicles(page: nextPage, limit: 10, status: cs.statusFilter);
    if (failure != null) { emit(cs.copyWith(isLoadingMore: false)); return; }
    emit(VehiclesLoaded(vehicles: [...cs.vehicles, ...vehicles], meta: meta, hasMore: meta?.hasMore ?? false, currentPage: nextPage, statusFilter: cs.statusFilter));
  }

  Future<void> _onFilterByStatus(FilterVehiclesByStatus event, Emitter<VehiclesState> emit) async {
    emit(const VehiclesLoading());
    final status = event.status.isEmpty ? null : event.status;
    final (vehicles, meta, failure) = await _repository.getVehicles(page: 1, limit: 10, status: status);
    if (failure != null) { emit(VehiclesError(message: failure.message)); return; }
    emit(VehiclesLoaded(vehicles: vehicles, meta: meta, hasMore: meta?.hasMore ?? false, currentPage: 1, statusFilter: status));
  }

  Future<void> _onSearchVehicles(SearchVehicles event, Emitter<VehiclesState> emit) async {
    if (event.query.isEmpty) { add(const LoadVehicles()); return; }
    emit(const VehiclesLoading());
    final (vehicles, failure) = await _repository.searchVehicles(event.query);
    if (failure != null) { emit(VehiclesError(message: failure.message)); return; }
    emit(VehiclesLoaded(vehicles: vehicles ?? [], hasMore: false, currentPage: 1, isSearchResult: true));
  }

  Future<void> _onDeleteVehicle(DeleteVehicle event, Emitter<VehiclesState> emit) async {
    final (success, failure) = await _repository.deleteVehicle(event.id);
    if (failure != null) { emit(VehicleActionError(message: failure.message)); return; }
    emit(VehicleActionSuccess(message: 'Vehicle deleted successfully'));
    add(const LoadVehicles());
  }

  Future<void> _onCreateVehicle(CreateVehicle event, Emitter<VehiclesState> emit) async {
    emit(const VehicleSaving());
    final (vehicle, failure) = await _repository.createVehicle(number: event.number, status: event.status);
    if (failure != null) { emit(VehicleActionError(message: failure.message)); return; }
    emit(VehicleActionSuccess(message: 'Vehicle registered successfully!'));
  }

  Future<void> _onLoadVehicleDetail(LoadVehicleDetail event, Emitter<VehiclesState> emit) async {
    emit(const VehicleDetailLoading());
    final (vehicle, failure) = await _repository.getVehicleById(event.id);
    if (failure != null) { emit(VehiclesError(message: failure.message)); return; }
    if (vehicle != null) emit(VehicleDetailLoaded(vehicle: vehicle));
  }

  Future<void> _onUpdateVehicle(UpdateVehicle event, Emitter<VehiclesState> emit) async {
    emit(const VehicleSaving());
    final (vehicle, failure) = await _repository.updateVehicle(event.id, number: event.number, status: event.status);
    if (failure != null) { emit(VehicleActionError(message: failure.message)); return; }
    emit(VehicleActionSuccess(message: 'Vehicle updated successfully!'));
  }

  Future<void> _onRefreshVehicles(RefreshVehicles event, Emitter<VehiclesState> emit) async {
    final (vehicles, meta, failure) = await _repository.getVehicles(page: 1, limit: 10);
    if (failure != null) { emit(VehiclesError(message: failure.message)); return; }
    emit(VehiclesLoaded(vehicles: vehicles, meta: meta, hasMore: meta?.hasMore ?? false, currentPage: 1));
  }
}
