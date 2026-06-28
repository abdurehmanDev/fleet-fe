// ─── Cache Manager ───────────────────────────────────────────────────────────────
// Manages API response caching with TTL and invalidation strategies
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_file_store/dio_cache_interceptor_file_store.dart';
import 'package:path_provider/path_provider.dart';

class CacheManager {
  static CacheManager? _instance;
  late final CacheStore _cacheStore;
  late final DioCacheInterceptor _cacheInterceptor;

  CacheManager._();

  static CacheManager get instance {
    _instance ??= CacheManager._();
    return _instance!;
  }

  Future<void> initialize() async {
    final dir = await getTemporaryDirectory();
    _cacheStore = FileCacheStore(dir.path);
    
    _cacheInterceptor = DioCacheInterceptor(
      options: CacheOptions(
        store: _cacheStore,
        policy: CachePolicy.request,
        hitCacheOnErrorExcept: [401, 403],
        maxStale: const Duration(hours: 1),
        priority: CachePriority.high,
        cipher: null,
        keyBuilder: CacheOptions.defaultCacheKeyBuilder,
      ),
    );
  }

  DioCacheInterceptor get interceptor => _cacheInterceptor;

  CacheStore get cacheStore => _cacheStore;

  // Invalidate cache for specific endpoints
  Future<void> invalidate(String pattern) async {
    await _cacheStore.deleteFromPath(RegExp(pattern));
  }

  // Invalidate all cache
  Future<void> invalidateAll() async {
    await _cacheStore.clean();
  }

  // Cache duration for different endpoint types
  static Duration getCacheDurationForEndpoint(String endpoint) {
    // Dashboard data - cache for 5 minutes
    if (endpoint.contains('dashboard')) {
      return const Duration(minutes: 5);
    }
    
    // Analytics data - cache for 15 minutes
    if (endpoint.contains('analytics') || endpoint.contains('trend')) {
      return const Duration(minutes: 15);
    }
    
    // Static data like drivers/vehicles - cache for 30 minutes
    if (endpoint.contains('drivers') || endpoint.contains('vehicles')) {
      return const Duration(minutes: 30);
    }
    
    // Notifications - cache for 2 minutes
    if (endpoint.contains('notifications')) {
      return const Duration(minutes: 2);
    }
    
    // Earnings - cache for 10 minutes
    if (endpoint.contains('earnings')) {
      return const Duration(minutes: 10);
    }
    
    // Default - cache for 5 minutes
    return const Duration(minutes: 5);
  }

  // Custom cache options for specific endpoints
  CacheOptions getCacheOptions(String endpoint) {
    final duration = getCacheDurationForEndpoint(endpoint);
    
    return CacheOptions(
      store: _cacheStore,
      policy: CachePolicy.request,
      hitCacheOnErrorExcept: [401, 403],
      maxStale: duration,
      priority: CachePriority.high,
    );
  }
}
