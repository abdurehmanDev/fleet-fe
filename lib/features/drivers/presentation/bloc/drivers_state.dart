// ─── Drivers States ───────────────────────────────────────────────────────────
part of 'drivers_bloc.dart';

abstract class DriversState extends Equatable {
  const DriversState();
  @override
  List<Object?> get props => [];
}

class DriversInitial extends DriversState {
  const DriversInitial();
}

class DriversLoading extends DriversState {
  const DriversLoading();
}

class DriversLoaded extends DriversState {
  final List<DriverEntity> drivers;
  final PaginationMeta? meta;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;
  final bool isSearchResult;

  const DriversLoaded({
    required this.drivers,
    this.meta,
    this.hasMore = false,
    this.currentPage = 1,
    this.isLoadingMore = false,
    this.isSearchResult = false,
  });

  DriversLoaded copyWith({
    List<DriverEntity>? drivers,
    PaginationMeta? meta,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
    bool? isSearchResult,
  }) {
    return DriversLoaded(
      drivers: drivers ?? this.drivers,
      meta: meta ?? this.meta,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSearchResult: isSearchResult ?? this.isSearchResult,
    );
  }

  @override
  List<Object?> get props => [drivers, meta, hasMore, currentPage, isLoadingMore, isSearchResult];
}

class DriversError extends DriversState {
  final String message;
  const DriversError({required this.message});
  @override
  List<Object?> get props => [message];
}

class DriverDetailLoading extends DriversState {
  const DriverDetailLoading();
}

class DriverDetailLoaded extends DriversState {
  final DriverEntity driver;
  const DriverDetailLoaded({required this.driver});
  @override
  List<Object?> get props => [driver];
}

class DriverSaving extends DriversState {
  const DriverSaving();
}

class DriverActionSuccess extends DriversState {
  final String message;
  const DriverActionSuccess({required this.message});
  @override
  List<Object?> get props => [message];
}

class DriverActionError extends DriversState {
  final String message;
  const DriverActionError({required this.message});
  @override
  List<Object?> get props => [message];
}
