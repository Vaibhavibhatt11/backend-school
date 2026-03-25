import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';

class ParentDashboardService {
  ParentDashboardService(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getChildren() async {
    final res = await _apiClient.get(ApiEndpoints.parentChildren);
    final body = res.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid children response.');
    }
    return body;
  }

  Future<Map<String, dynamic>> getHome() async {
    final res = await _apiClient.get(ApiEndpoints.parentHome);
    final body = res.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid home response.');
    }
    return body;
  }
}

