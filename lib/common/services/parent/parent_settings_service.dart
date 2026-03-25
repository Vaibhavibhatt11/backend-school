import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';

class ParentSettingsService {
  ParentSettingsService(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getSettings() async {
    final res = await _apiClient.get(ApiEndpoints.parentSettings);
    final body = res.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid settings response.');
    }
    return body;
  }

  Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> payload) async {
    final res = await _apiClient.put(ApiEndpoints.parentSettings, data: payload);
    final body = res.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid update settings response.');
    }
    return body;
  }
}

