import 'package:dio/dio.dart';

/// Best-effort message from `{ success: false, error: { message } }` or Dio errors.
String dioOrApiErrorMessage(Object error) {
  String normalizeGenericMessage(
    String candidate, {
    int? statusCode,
    DioExceptionType? type,
  }) {
    final normalized = candidate.trim().toLowerCase();
    const generic = {
      'something went wrong',
      'server error',
      'request failed',
      'internal server error',
      'login failed',
      'unable to login. please try again.',
    };
    if (!generic.contains(normalized)) return candidate;

    if (statusCode == 401) {
      return 'Invalid email or password.';
    }
    if (statusCode == 429) {
      return 'Too many login attempts. Please wait and try again.';
    }
    if (statusCode == 503) {
      return 'Server is waking up. Please try again in 10-20 seconds.';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'Server issue right now. Please try again shortly.';
    }
    if (type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.receiveTimeout ||
        type == DioExceptionType.sendTimeout) {
      return 'Request timed out. Please try again.';
    }
    if (type == DioExceptionType.connectionError) {
      return 'Cannot reach server. Check internet and try again.';
    }
    return 'Unable to process request right now. Please try again.';
  }

  if (error is DioException) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString().trim();
      if (message != null && message.isNotEmpty) {
        return normalizeGenericMessage(
          message,
          statusCode: statusCode,
          type: error.type,
        );
      }
      final err = data['error'];
      if (err is Map<String, dynamic>) {
        final m = err['message']?.toString().trim();
        if (m != null && m.isNotEmpty) {
          return normalizeGenericMessage(
            m,
            statusCode: statusCode,
            type: error.type,
          );
        }
      }
    }

    if (statusCode == 401) return 'Invalid email or password.';
    if (statusCode == 429) {
      return 'Too many login attempts. Please wait and try again.';
    }
    if (statusCode == 503) {
      return 'Server is waking up. Please try again in 10-20 seconds.';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'Server issue right now. Please try again shortly.';
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'Request timed out. Please try again.';
    }
    if (error.type == DioExceptionType.connectionError) {
      return 'Cannot reach server. Check internet and try again.';
    }

    if (error.message != null && error.message!.isNotEmpty) {
      return normalizeGenericMessage(
        error.message!,
        statusCode: statusCode,
        type: error.type,
      );
    }
  }
  final raw = error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
  if (raw.isEmpty) return 'Unable to process request right now. Please try again.';
  return normalizeGenericMessage(raw);
}

Map<String, dynamic> extractApiData(
  dynamic payload, {
  required String context,
}) {
  if (payload is! Map<String, dynamic>) {
    throw Exception('Invalid $context response.');
  }

  final success = payload['success'];
  if (success is bool && !success) {
    final message = payload['message']?.toString();
    if (message != null && message.isNotEmpty) {
      throw Exception(message);
    }
    final error = payload['error'];
    if (error is Map<String, dynamic>) {
      final message = error['message']?.toString();
      if (message != null && message.isNotEmpty) {
        throw Exception(message);
      }
    }
    throw Exception('Request failed for $context.');
  }

  final data = payload['data'];
  if (data is Map<String, dynamic>) {
    return data;
  }
  if (data is List) {
    return <String, dynamic>{'items': data};
  }
  if (success is bool) {
    return <String, dynamic>{'value': data};
  }
  return payload;
}
