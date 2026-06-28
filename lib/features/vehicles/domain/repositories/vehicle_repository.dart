// ─── Vehicle Repository Contract ──────────────────────────────────────────────
import 'package:rangrej_fleet/core/errors/failures.dart';
import 'package:rangrej_fleet/features/drivers/data/models/driver_model.dart';
import 'package:rangrej_fleet/features/vehicles/domain/entities/vehicle_entity.dart';

abstract class VehicleRepository {
  Future<(List<VehicleEntity>, PaginationMeta?, Failure?)> getVehicles({int page = 1, int limit = 10, String? status, bool forceRefresh = false});
  Future<(List<VehicleEntity>?, Failure?)> searchVehicles(String query);
  Future<(VehicleEntity?, Failure?)> getVehicleById(String id);
  Future<(VehicleEntity?, Failure?)> createVehicle({required String number, String status = 'ACTIVE'});
  Future<(VehicleEntity?, Failure?)> updateVehicle(String id, {String? number, String? status});
  Future<(bool, Failure?)> updateVehicleStatus(String id, String status);
  Future<(bool, Failure?)> deleteVehicle(String id);
}
