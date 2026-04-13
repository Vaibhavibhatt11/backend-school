import 'package:dio/dio.dart';

import '../routes/common_routes_screens.dart';
import '../utils/safe_navigation.dart';
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
  static bool _isForcingLogout = false;

  bool _isAuthPath(String path) {
    return path.contains(ApiEndpoints.authLogin) ||
        path.contains(ApiEndpoints.authRefresh) ||
        path.contains(ApiEndpoints.authForgotPassword) ||
        path.contains(ApiEndpoints.authVerifyOtp) ||
        path.contains(ApiEndpoints.authResetPassword);
  }

  bool _isPublicPath(String path) {
    return path.contains(ApiEndpoints.health) ||
        path.contains(ApiEndpoints.ready) ||
        _isAuthPath(path);
  }

  bool _isAuthFailure(DioException err) {
    final code = err.response?.statusCode;
    if (code == 401) return true;

    final payload = err.response?.data;
    final text = payload?.toString().toLowerCase() ?? '';
    return text.contains('token') &&
        (text.contains('expired') ||
            text.contains('invalid') ||
            text.contains('malformed') ||
            text.contains('missing') ||
            text.contains('unauthorized'));
  }

  Future<void> _forceLogoutAndRedirect() async {
    if (_isForcingLogout) return;
    _isForcingLogout = true;
    try {
      await _sessionStorage.clearSession();
      SafeNavigation.offAllNamed(CommonScreenRoutes.loginScreen);
    } finally {
      _isForcingLogout = false;
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (_isPublicPath(options.path)) {
      return handler.next(options);
    }
    final token = await _sessionStorage.getToken();
    if (token == null || token.isEmpty) {
      await _forceLogoutAndRedirect();
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: options,
            statusCode: 401,
            data: {'message': 'Authentication required'},
          ),
        ),
      );
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (!_isAuthFailure(err)) {
      return handler.next(err);
    }
    final path = err.requestOptions.path;
    if (_isAuthPath(path)) {
      await _forceLogoutAndRedirect();
      return handler.next(err);
    }
    if (err.requestOptions.extra['authRetried'] == true) {
      await _forceLogoutAndRedirect();
      return handler.next(err);
    }
    final refreshToken = await _sessionStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _forceLogoutAndRedirect();
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
        await _forceLogoutAndRedirect();
        return handler.next(err);
      }
      await _sessionStorage.saveLoginResponse(body);
      final data = body['data'];
      final access = data is Map<String, dynamic> ? data['accessToken']?.toString() : null;
      if (access == null || access.isEmpty) {
        await _forceLogoutAndRedirect();
        return handler.next(err);
      }
      await _sessionStorage.saveToken(access);
      final ro = err.requestOptions;
      ro.headers['Authorization'] = 'Bearer $access';
      ro.extra['authRetried'] = true;
      final response = await _dio.fetch(ro);
      return handler.resolve(response);
    } catch (_) {
      await _forceLogoutAndRedirect();
      return handler.next(err);
    }
  }
}

