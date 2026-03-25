import 'package:dio/dio.dart';

import '../services/session_storage_service.dart';
import 'api_config.dart';

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
}

