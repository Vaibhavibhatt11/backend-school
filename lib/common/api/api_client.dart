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

  Dio get dio => _dio;

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
  }) {
    return _dio.get(path, queryParameters: query, options: options);
  }

  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Options? options,
  }) {
    return _dio.post(path, data: data, queryParameters: query, options: options);
  }

  Future<Response<dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Options? options,
  }) {
    return _dio.put(path, data: data, queryParameters: query, options: options);
  }

  Future<Response<dynamic>> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Options? options,
  }) {
    return _dio.patch(path, data: data, queryParameters: query, options: options);
  }
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

