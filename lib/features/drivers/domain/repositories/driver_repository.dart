// ─── Driver Repository Contract ───────────────────────────────────────────────
import 'package:rangrej_fleet/core/errors/failures.dart';
import 'package:rangrej_fleet/features/drivers/data/models/driver_model.dart';
import 'package:rangrej_fleet/features/drivers/domain/entities/driver_entity.dart';

abstract class DriverRepository {
  Future<(List<DriverEntity>, PaginationMeta?, Failure?)> getDrivers({
    int page = 1,
    int limit = 10,
    String? search,
  });

  Future<(List<DriverEntity>?, Failure?)> searchDrivers(String query);
  Future<(DriverEntity?, Failure?)> getDriverById(String id);
  Future<(DriverEntity?, Failure?)> createDriver({required String name, required String mobile});
  Future<(DriverEntity?, Failure?)> updateDriver(String id, {String? name, String? mobile});
  Future<(bool, Failure?)> deleteDriver(String id);
}
