import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import 'package:get/get.dart';
import 'parent_api_utils.dart';
import 'parent_context_service.dart';

class ParentDashboardService {
  ParentDashboardService(this._apiClient);

  final ApiClient _apiClient;
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  Future<Map<String, dynamic>> getChildren() async {
    final res = await _apiClient.get(ApiEndpoints.parentChildren);
    return extractApiData(res.data, context: 'children');
  }

  Future<Map<String, dynamic>> getHome({
    String? childId,
    String? month,
  }) async {
    final scopedChildId = (childId == null || childId.isEmpty)
        ? await _parentContext.ensureSelectedChildId()
        : childId;
    final query = <String, dynamic>{
      if (scopedChildId != null && scopedChildId.isNotEmpty) 'childId': scopedChildId,
      if (month != null && month.isNotEmpty) 'month': month,
    };
    final res = await _apiClient.get(
      ApiEndpoints.parentHome,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'home');
  }
}

