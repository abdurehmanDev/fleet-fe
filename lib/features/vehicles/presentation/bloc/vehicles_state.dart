part of 'vehicles_bloc.dart';

abstract class VehiclesState extends Equatable {
  const VehiclesState();
  @override
  List<Object?> get props => [];
}

class VehiclesInitial extends VehiclesState { const VehiclesInitial(); }
class VehiclesLoading extends VehiclesState { const VehiclesLoading(); }

class VehiclesLoaded extends VehiclesState {
  final List<VehicleEntity> vehicles;
  final PaginationMeta? meta;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;
  final bool isSearchResult;
  final String? statusFilter;

  const VehiclesLoaded({
    required this.vehicles,
    this.meta,
    this.hasMore = false,
    this.currentPage = 1,
    this.isLoadingMore = false,
    this.isSearchResult = false,
    this.statusFilter,
  });

  VehiclesLoaded copyWith({
    List<VehicleEntity>? vehicles,
    PaginationMeta? meta,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
    bool? isSearchResult,
    String? statusFilter,
  }) {
    return VehiclesLoaded(
      vehicles: vehicles ?? this.vehicles,
      meta: meta ?? this.meta,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSearchResult: isSearchResult ?? this.isSearchResult,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }

  @override
  List<Object?> get props => [vehicles, meta, hasMore, currentPage, isLoadingMore, isSearchResult, statusFilter];
}

class VehiclesError extends VehiclesState {
  final String message;
  const VehiclesError({required this.message});
  @override
  List<Object?> get props => [message];
}

class VehicleDetailLoading extends VehiclesState { const VehicleDetailLoading(); }
class VehicleDetailLoaded extends VehiclesState {
  final VehicleEntity vehicle;
  const VehicleDetailLoaded({required this.vehicle});
  @override
  List<Object?> get props => [vehicle];
}

class VehicleSaving extends VehiclesState { const VehicleSaving(); }
class VehicleActionSuccess extends VehiclesState {
  final String message;
  const VehicleActionSuccess({required this.message});
  @override
  List<Object?> get props => [message];
}
class VehicleActionError extends VehiclesState {
  final String message;
  const VehicleActionError({required this.message});
  @override
  List<Object?> get props => [message];
}
