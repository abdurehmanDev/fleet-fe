// ─── Drivers Events ───────────────────────────────────────────────────────────
part of 'drivers_bloc.dart';

abstract class DriversEvent extends Equatable {
  const DriversEvent();
  @override
  List<Object?> get props => [];
}

class LoadDrivers extends DriversEvent {
  const LoadDrivers();
}

class LoadMoreDrivers extends DriversEvent {
  const LoadMoreDrivers();
}

class SearchDrivers extends DriversEvent {
  final String query;
  const SearchDrivers(this.query);
  @override
  List<Object?> get props => [query];
}

class DeleteDriver extends DriversEvent {
  final String id;
  const DeleteDriver(this.id);
  @override
  List<Object?> get props => [id];
}

class CreateDriver extends DriversEvent {
  final String name;
  final String mobile;
  const CreateDriver({required this.name, required this.mobile});
  @override
  List<Object?> get props => [name, mobile];
}

class LoadDriverDetail extends DriversEvent {
  final String id;
  const LoadDriverDetail(this.id);
  @override
  List<Object?> get props => [id];
}

class UpdateDriver extends DriversEvent {
  final String id;
  final String? name;
  final String? mobile;
  const UpdateDriver({required this.id, this.name, this.mobile});
  @override
  List<Object?> get props => [id, name, mobile];
}

class RefreshDrivers extends DriversEvent {
  const RefreshDrivers();
}
