import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';

class ParentProfileService {
  ParentProfileService(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getProfileHub() async {
    final res = await _apiClient.get(ApiEndpoints.parentProfileHub);
    final body = res.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid profile hub response.');
    }
    return body;
  }

  Future<Map<String, dynamic>> getLibrary() async {
    final res = await _apiClient.get(ApiEndpoints.parentLibrary);
    final body = res.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid library response.');
    }
    return body;
  }

  Future<Map<String, dynamic>> getDocuments() async {
    final res = await _apiClient.get(ApiEndpoints.parentDocuments);
    final body = res.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid documents response.');
    }
    return body;
  }
}

