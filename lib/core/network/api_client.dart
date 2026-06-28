// ─── API Client ───────────────────────────────────────────────────────────────
// Dio HTTP client with interceptors for auth token injection, refresh & errors
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:rangrej_fleet/core/constants/app_constants.dart';
import 'package:rangrej_fleet/core/errors/exceptions.dart';
import 'package:rangrej_fleet/core/network/endpoints.dart';
import 'package:rangrej_fleet/core/storage/secure_storage_service.dart';

class ApiClient {
  late final Dio _dio;
  final SecureStorageService _secureStorage;
  bool _isRefreshing = false;

  ApiClient(this._secureStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['BASE_URL'] ?? '',
        connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
        sendTimeout: const Duration(milliseconds: AppConstants.sendTimeout),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(_secureStorage, _dio, _refreshToken),
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        error: true,
        compact: true,
      ),
    ]);
  }

  Dio get dio => _dio;

  // ── Token Refresh ─────────────────────────────────────────────────────────
  Future<void> _refreshToken() async {
    if (_isRefreshing) return;
    _isRefreshing = true;

    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw const UnauthorizedException();
      }

      final response = await Dio(
        BaseOptions(baseUrl: dotenv.env['BASE_URL'] ?? ''),
      ).post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      final data = response.data['data'];
      if (data != null) {
        await _secureStorage.saveAccessToken(data['accessToken']);
        await _secureStorage.saveRefreshToken(data['refreshToken']);
      }
    } catch (_) {
      await _secureStorage.clearAll();
      rethrow;
    } finally {
      _isRefreshing = false;
    }
  }

  // ── GET ───────────────────────────────────────────────────────────────────
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool forceRefresh = false,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // ── POST ──────────────────────────────────────────────────────────────────
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    List<String> invalidateCache = const [],
  }) async {
    try {
      final response = await _dio.post(path, data: data, queryParameters: queryParameters, options: options);
      return response;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // ── PUT ───────────────────────────────────────────────────────────────────
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    List<String> invalidateCache = const [],
  }) async {
    try {
      final response = await _dio.put(path, data: data, queryParameters: queryParameters, options: options);
      return response;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // ── PATCH ─────────────────────────────────────────────────────────────────
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    List<String> invalidateCache = const [],
  }) async {
    try {
      final response = await _dio.patch(path, data: data, queryParameters: queryParameters, options: options);
      return response;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    List<String> invalidateCache = const [],
  }) async {
    try {
      final response = await _dio.delete(path, data: data, queryParameters: queryParameters, options: options);
      return response;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // ── Multipart Upload ──────────────────────────────────────────────────────
  Future<Response> uploadFile(
    String path, {
    required String filePath,
    String fieldName = 'file',
    Map<String, dynamic>? extraFields,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        if (extraFields != null) ...extraFields,
      });
      return await _dio.post(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // ── Error Handler ─────────────────────────────────────────────────────────
  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkException(message: 'Request timed out. Please try again.');
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? 'Server error occurred';
        if (statusCode == 401) return const UnauthorizedException();
        if (statusCode == 404) return NotFoundException(message: message.toString());
        if (statusCode == 409) return ServerException(message: message.toString(), statusCode: statusCode);
        if (statusCode == 429) return ServerException(message: 'Too many requests. Please wait.', statusCode: statusCode);
        return ServerException(message: message.toString(), statusCode: statusCode);
      default:
        return ServerException(message: e.message ?? 'An unexpected error occurred');
    }
  }
}

// ─── Auth Interceptor ─────────────────────────────────────────────────────────
class _AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;
  final Dio _dio;
  final Future<void> Function() _refreshToken;

  _AuthInterceptor(this._secureStorage, this._dio, this._refreshToken);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        await _refreshToken();
        // Retry the original request with new token
        final token = await _secureStorage.getAccessToken();
        if (token != null) {
          err.requestOptions.headers['Authorization'] = 'Bearer $token';
          final response = await _dio.fetch(err.requestOptions);
          return handler.resolve(response);
        }
      } catch (_) {
        // Token refresh failed — let the error propagate
      }
    }
    return handler.next(err);
  }
}
