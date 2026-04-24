import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import 'package:get/get.dart';
import 'parent_api_utils.dart';
import 'parent_context_service.dart';

class ParentSettingsService {
  ParentSettingsService(this._apiClient);

  final ApiClient _apiClient;
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  Future<Map<String, dynamic>> getSettings({String? childId}) async {
    final scopedChildId = (childId == null || childId.isEmpty)
        ? await _parentContext.ensureSelectedChildId()
        : childId;
    final query = <String, dynamic>{
      if (scopedChildId != null && scopedChildId.isNotEmpty) 'childId': scopedChildId,
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
    final scopedChildId = (childId == null || childId.isEmpty)
        ? await _parentContext.ensureSelectedChildId()
        : childId;
    final query = <String, dynamic>{
      if (scopedChildId != null && scopedChildId.isNotEmpty) 'childId': scopedChildId,
    };
    final res = await _apiClient.put(
      ApiEndpoints.parentSettings,
      data: payload,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'update settings');
  }
}

