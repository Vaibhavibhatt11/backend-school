import 'package:dio/dio.dart';

import '../services/session_storage_service.dart';
import 'api_config.dart';
import 'api_endpoints.dart';

class ApiClient {
  ApiClient(this._sessionStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _sessionStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
    _dio.interceptors.add(_AuthRefreshInterceptor(_sessionStorage, _dio));
  }

  final SessionStorageService _sessionStorage;
  late final Dio _dio;
  final Map<String, _CachedGetResponse> _getCache = {};
  final Map<String, Future<Response<dynamic>>> _inFlightGets = {};
  static const Duration _defaultGetCacheTtl = Duration(seconds: 15);

  Dio get dio => _dio;

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
  }) {
    final skipCache = options?.extra?['skipCache'] == true;
    if (skipCache || _isUncacheablePath(path)) {
      return _dio.get(path, queryParameters: query, options: options);
    }
    final cacheKey = _buildCacheKey(path, query);
    final cached = _getCache[cacheKey];
    if (cached != null && DateTime.now().isBefore(cached.expiresAt)) {
      return Future.value(
        Response<dynamic>(
          data: cached.data,
          requestOptions: RequestOptions(path: path, queryParameters: query ?? const {}),
          statusCode: cached.statusCode,
        ),
      );
    }
    final inFlight = _inFlightGets[cacheKey];
    if (inFlight != null) return inFlight;

    final future = _dio
        .get(path, queryParameters: query, options: options)
        .then((response) {
          _getCache[cacheKey] = _CachedGetResponse(
            data: response.data,
            statusCode: response.statusCode,
            expiresAt: DateTime.now().add(_defaultGetCacheTtl),
          );
          return response;
        })
        .whenComplete(() {
          _inFlightGets.remove(cacheKey);
        });

    _inFlightGets[cacheKey] = future;
    return future;
  }

  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Options? options,
  }) {
    _invalidateGetCache();
    return _dio.post(path, data: data, queryParameters: query, options: options);
  }

  Future<Response<dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Options? options,
  }) {
    _invalidateGetCache();
    return _dio.put(path, data: data, queryParameters: query, options: options);
  }

  Future<Response<dynamic>> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Options? options,
  }) {
    _invalidateGetCache();
    return _dio.patch(path, data: data, queryParameters: query, options: options);
  }

  void _invalidateGetCache() {
    _getCache.clear();
  }

  bool _isUncacheablePath(String path) {
    return path.contains('/auth/');
  }

  String _buildCacheKey(String path, Map<String, dynamic>? query) {
    if (query == null || query.isEmpty) return path;
    final keys = query.keys.map((k) => k.toString()).toList()..sort();
    final parts = keys.map((k) => '$k=${query[k]}').join('&');
    return '$path?$parts';
  }
}

class _CachedGetResponse {
  _CachedGetResponse({
    required this.data,
    required this.statusCode,
    required this.expiresAt,
  });

  final dynamic data;
  final int? statusCode;
  final DateTime expiresAt;
}

/// On 401, refresh once via [SessionStorageService] and retry the failed request.
class _AuthRefreshInterceptor extends Interceptor {
  _AuthRefreshInterceptor(this._sessionStorage, this._dio);

  final SessionStorageService _sessionStorage;
  final Dio _dio;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }
    final path = err.requestOptions.path;
    if (path.contains(ApiEndpoints.authRefresh) || path.contains(ApiEndpoints.authLogin)) {
      return handler.next(err);
    }
    if (err.requestOptions.extra['authRetried'] == true) {
      return handler.next(err);
    }
    final refreshToken = await _sessionStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return handler.next(err);
    }
    try {
      final res = await _dio.post(
        ApiEndpoints.authRefresh,
        data: {'refreshToken': refreshToken},
        options: Options(extra: {'authRetried': true}),
      );
      final body = res.data;
      if (body is! Map<String, dynamic> || body['success'] == false) {
        return handler.next(err);
      }
      await _sessionStorage.saveLoginResponse(body);
      final data = body['data'];
      final access = data is Map<String, dynamic> ? data['accessToken']?.toString() : null;
      if (access == null || access.isEmpty) {
        return handler.next(err);
      }
      await _sessionStorage.saveToken(access);
      final ro = err.requestOptions;
      ro.headers['Authorization'] = 'Bearer $access';
      ro.extra['authRetried'] = true;
      final response = await _dio.fetch(ro);
      return handler.resolve(response);
    } catch (_) {
      return handler.next(err);
    }
  }
}

