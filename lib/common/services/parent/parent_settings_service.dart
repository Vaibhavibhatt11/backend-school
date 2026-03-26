import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import 'parent_api_utils.dart';

class ParentSettingsService {
  ParentSettingsService(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getSettings({String? childId}) async {
    final query = <String, dynamic>{
      if (childId != null && childId.isNotEmpty) 'childId': childId,
    };
    final res = await _apiClient.get(
      ApiEndpoints.parentSettings,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'settings');
  }

  Future<Map<String, dynamic>> updateSettings(
    Map<String, dynamic> payload, {
    String? childId,
  }) async {
    final query = <String, dynamic>{
      if (childId != null && childId.isNotEmpty) 'childId': childId,
    };
    final res = await _apiClient.put(
      ApiEndpoints.parentSettings,
      data: payload,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'update settings');
  }
}

