Map<String, dynamic> extractApiData(
  dynamic payload, {
  required String context,
}) {
  if (payload is! Map<String, dynamic>) {
    throw Exception('Invalid $context response.');
  }

  final success = payload['success'];
  if (success is bool && !success) {
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
  if (success is bool) {
    return <String, dynamic>{'value': data};
  }
  return payload;
}
