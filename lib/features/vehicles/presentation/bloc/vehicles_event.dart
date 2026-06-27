part of 'vehicles_bloc.dart';

abstract class VehiclesEvent extends Equatable {
  const VehiclesEvent();
  @override
  List<Object?> get props => [];
}

class LoadVehicles extends VehiclesEvent { const LoadVehicles(); }
class LoadMoreVehicles extends VehiclesEvent { const LoadMoreVehicles(); }
class FilterVehiclesByStatus extends VehiclesEvent {
  final String status;
  const FilterVehiclesByStatus(this.status);
  @override
  List<Object?> get props => [status];
}
class SearchVehicles extends VehiclesEvent {
  final String query;
  const SearchVehicles(this.query);
  @override
  List<Object?> get props => [query];
}
class DeleteVehicle extends VehiclesEvent {
  final String id;
  const DeleteVehicle(this.id);
  @override
  List<Object?> get props => [id];
}
class CreateVehicle extends VehiclesEvent {
  final String number;
  final String status;
  const CreateVehicle({required this.number, this.status = 'ACTIVE'});
  @override
  List<Object?> get props => [number, status];
}
class LoadVehicleDetail extends VehiclesEvent {
  final String id;
  const LoadVehicleDetail(this.id);
  @override
  List<Object?> get props => [id];
}
class UpdateVehicle extends VehiclesEvent {
  final String id;
  final String? number;
  final String? status;
  const UpdateVehicle({required this.id, this.number, this.status});
  @override
  List<Object?> get props => [id, number, status];
}
class RefreshVehicles extends VehiclesEvent { const RefreshVehicles(); }
