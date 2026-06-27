// ─── Dependency Injection ─────────────────────────────────────────────────────
// get_it service locator setup — register all services, repos, blocs here
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:rangrej_fleet/core/network/api_client.dart';
import 'package:rangrej_fleet/core/network/network_info.dart';
import 'package:rangrej_fleet/core/storage/secure_storage_service.dart';

// Features - Auth
import 'package:rangrej_fleet/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:rangrej_fleet/features/auth/data/repositories_impl/auth_repository_impl.dart';
import 'package:rangrej_fleet/features/auth/domain/repositories/auth_repository.dart';
import 'package:rangrej_fleet/features/auth/domain/usecases/login_usecase.dart';
import 'package:rangrej_fleet/features/auth/presentation/bloc/auth_bloc.dart';

// Features - Drivers
import 'package:rangrej_fleet/features/drivers/data/datasources/driver_remote_datasource.dart';
import 'package:rangrej_fleet/features/drivers/data/repositories_impl/driver_repository_impl.dart';
import 'package:rangrej_fleet/features/drivers/domain/repositories/driver_repository.dart';
import 'package:rangrej_fleet/features/drivers/presentation/bloc/drivers_bloc.dart';

// Features - Vehicles
import 'package:rangrej_fleet/features/vehicles/data/datasources/vehicle_remote_datasource.dart';
import 'package:rangrej_fleet/features/vehicles/data/repositories_impl/vehicle_repository_impl.dart';
import 'package:rangrej_fleet/features/vehicles/domain/repositories/vehicle_repository.dart';
import 'package:rangrej_fleet/features/vehicles/presentation/bloc/vehicles_bloc.dart';

// Features - Earnings
import 'package:rangrej_fleet/features/earnings/data/datasources/earnings_remote_datasource.dart';
import 'package:rangrej_fleet/features/earnings/data/repositories_impl/earnings_repository_impl.dart';
import 'package:rangrej_fleet/features/earnings/domain/repositories/earnings_repository.dart';
import 'package:rangrej_fleet/features/earnings/presentation/bloc/driver_earnings_bloc.dart';
import 'package:rangrej_fleet/features/earnings/presentation/bloc/company_earnings_bloc.dart';

// Features - Dashboard
import 'package:rangrej_fleet/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:rangrej_fleet/features/dashboard/data/repositories_impl/dashboard_repository_impl.dart';
import 'package:rangrej_fleet/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:rangrej_fleet/features/dashboard/presentation/bloc/dashboard_bloc.dart';

// Features - Analytics
import 'package:rangrej_fleet/features/analytics/data/datasources/analytics_remote_datasource.dart';
import 'package:rangrej_fleet/features/analytics/data/repositories_impl/analytics_repository_impl.dart';
import 'package:rangrej_fleet/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:rangrej_fleet/features/analytics/presentation/bloc/analytics_bloc.dart';

// Features - Notifications
import 'package:rangrej_fleet/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:rangrej_fleet/features/notifications/data/repositories_impl/notifications_repository_impl.dart';
import 'package:rangrej_fleet/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:rangrej_fleet/features/notifications/presentation/bloc/notifications_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> setupDependencies() async {
  // ── Core ──────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );

  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(sl<FlutterSecureStorage>()),
  );

  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(sl<SecureStorageService>()),
  );

  // ── Auth Feature ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
      secureStorage: sl<SecureStorageService>(),
    ),
  );

  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl<AuthRepository>()),
  );

  sl.registerFactory<AuthBloc>(() => AuthBloc(loginUseCase: sl<LoginUseCase>()));

  // ── Drivers Feature ───────────────────────────────────────────────────────
  sl.registerLazySingleton<DriverRemoteDataSource>(
    () => DriverRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<DriverRepository>(
    () => DriverRepositoryImpl(
      remoteDataSource: sl<DriverRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  sl.registerFactory<DriversBloc>(
    () => DriversBloc(repository: sl<DriverRepository>()),
  );

  // ── Vehicles Feature ──────────────────────────────────────────────────────
  sl.registerLazySingleton<VehicleRemoteDataSource>(
    () => VehicleRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<VehicleRepository>(
    () => VehicleRepositoryImpl(
      remoteDataSource: sl<VehicleRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  sl.registerFactory<VehiclesBloc>(
    () => VehiclesBloc(repository: sl<VehicleRepository>()),
  );

  // ── Earnings Feature ──────────────────────────────────────────────────────
  sl.registerLazySingleton<EarningsRemoteDataSource>(
    () => EarningsRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<EarningsRepository>(
    () => EarningsRepositoryImpl(
      remoteDataSource: sl<EarningsRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  sl.registerFactory<DriverEarningsBloc>(
    () => DriverEarningsBloc(
      earningsRepository: sl<EarningsRepository>(),
      driverRepository: sl<DriverRepository>(),
    ),
  );

  sl.registerFactory<CompanyEarningsBloc>(
    () => CompanyEarningsBloc(repository: sl<EarningsRepository>()),
  );

  // ── Dashboard Feature ─────────────────────────────────────────────────────
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      remoteDataSource: sl<DashboardRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  sl.registerFactory<DashboardBloc>(
    () => DashboardBloc(repository: sl<DashboardRepository>()),
  );

  // ── Analytics Feature ─────────────────────────────────────────────────────
  sl.registerLazySingleton<AnalyticsRemoteDataSource>(
    () => AnalyticsRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(
      remoteDataSource: sl<AnalyticsRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  sl.registerFactory<AnalyticsBloc>(
    () => AnalyticsBloc(
      analyticsRepository: sl<AnalyticsRepository>(),
      driverRepository: sl<DriverRepository>(),
    ),
  );

  // ── Notifications Feature ─────────────────────────────────────────────────
  sl.registerLazySingleton<NotificationsRemoteDataSource>(
    () => NotificationsRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(
      remoteDataSource: sl<NotificationsRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  sl.registerFactory<NotificationsBloc>(
    () => NotificationsBloc(repository: sl<NotificationsRepository>()),
  );
}
