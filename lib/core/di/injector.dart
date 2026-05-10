// ─── Dependency Injection ─────────────────────────────────────────────────────
// get_it service locator setup — register all services, repos, blocs here
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:rangrej_fleet/core/network/api_client.dart';
import 'package:rangrej_fleet/core/network/network_info.dart';
import 'package:rangrej_fleet/core/storage/secure_storage_service.dart';

// Features
import 'package:rangrej_fleet/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:rangrej_fleet/features/auth/data/repositories_impl/auth_repository_impl.dart';
import 'package:rangrej_fleet/features/auth/domain/repositories/auth_repository.dart';
import 'package:rangrej_fleet/features/auth/domain/usecases/login_usecase.dart';
import 'package:rangrej_fleet/features/auth/presentation/bloc/auth_bloc.dart';

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
  // DataSources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<ApiClient>()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
      secureStorage: sl<SecureStorageService>(),
    ),
  );

  // UseCases
  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl<AuthRepository>()),
  );

  // BLoCs (registered as Factory — new instance per page)
  sl.registerFactory<AuthBloc>(() => AuthBloc(loginUseCase: sl<LoginUseCase>()));
}
