import 'package:dio/dio.dart';
import '../../../config/env_config.dart';

class ApiProvider {
  late Dio _dio;

  ApiProvider() {
    _dio = Dio(BaseOptions(
      baseUrl: EnvConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
  }

  Dio get client => _dio;
}