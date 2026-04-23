/// Normalizes backend auth payloads: `data.user`, `data.profile`, or flat `data.role`.
class AuthUserParse {
  AuthUserParse._();

  /// Reads role string from API `data` object (after unwrap), or null.
  static String? roleFromData(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return null;
    final user = data['user'];
    if (user is Map) {
      final r = user['role']?.toString().trim();
      if (r != null && r.isNotEmpty) return r;
    }
    final profile = data['profile'];
    if (profile is Map) {
      final r = profile['role']?.toString().trim();
      if (r != null && r.isNotEmpty) return r;
    }
    final r = data['role']?.toString().trim();
    if (r != null && r.isNotEmpty) return r;
    return null;
  }

  /// Full response body `{ success, data: { ... } }` — also checks top-level legacy shapes.
  static String? roleFromAuthResponse(Map<String, dynamic>? body) {
    if (body == null || body.isEmpty) return null;
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      final fromInner = roleFromData(data);
      if (fromInner != null) return fromInner;
    }
    return roleFromData(body);
  }
}
