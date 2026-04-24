import 'package:dio/dio.dart';

class DioExceptions implements Exception {
  late String message;

  DioExceptions.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.cancel:
        message = 'Request cancelled';
        break;
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Receive timeout';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Send timeout';
        break;
      case DioExceptionType.badResponse:
        message = _handleResponse(dioError.response);
        break;
      default:
        message = 'Something went wrong';
    }
  }

  String _handleResponse(Response? response) {
    // Custom error handling based on status code
    return 'Server error';
  }

  @override
  String toString() => message;
}
