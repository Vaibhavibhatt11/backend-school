import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import 'parent_api_utils.dart';

class ParentDashboardService {
  ParentDashboardService(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getChildren() async {
    final res = await _apiClient.get(ApiEndpoints.parentChildren);
    return extractApiData(res.data, context: 'children');
  }

  Future<Map<String, dynamic>> getHome({
    String? childId,
    String? month,
  }) async {
    final query = <String, dynamic>{
      if (childId != null && childId.isNotEmpty) 'childId': childId,
      if (month != null && month.isNotEmpty) 'month': month,
    };
    final res = await _apiClient.get(
      ApiEndpoints.parentHome,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'home');
  }
}

