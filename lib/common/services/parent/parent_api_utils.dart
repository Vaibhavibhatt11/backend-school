import 'package:dio/dio.dart';

/// Best-effort message from `{ success: false, error: { message } }` or Dio errors.
String dioOrApiErrorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString();
      if (message != null && message.isNotEmpty) return message;
      final err = data['error'];
      if (err is Map<String, dynamic>) {
        final m = err['message']?.toString();
        if (m != null && m.isNotEmpty) return m;
      }
      final m = data['message']?.toString();
      if (m != null && m.isNotEmpty) return m;
    }
    if (error.message != null && error.message!.isNotEmpty) {
      return error.message!;
    }
  }
  return error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
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
