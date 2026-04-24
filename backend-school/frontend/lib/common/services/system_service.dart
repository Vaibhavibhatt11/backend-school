import '../api/api_client.dart';
import '../api/api_endpoints.dart';

class SystemService {
  SystemService(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> health() async {
    final res = await _apiClient.get(ApiEndpoints.health);
    final body = res.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid health response.');
    }
    return body;
  }

  Future<Map<String, dynamic>> ready() async {
    final res = await _apiClient.get(ApiEndpoints.ready);
    final body = res.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid ready response.');
    }
    return body;
  }
}

