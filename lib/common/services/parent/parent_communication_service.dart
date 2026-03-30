import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import 'package:get/get.dart';
import 'parent_api_utils.dart';
import 'parent_context_service.dart';

class ParentCommunicationService {
  ParentCommunicationService(this._apiClient);

  final ApiClient _apiClient;
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  Future<Map<String, dynamic>> getAnnouncements({
    String? childId,
    String? type,
  }) async {
    final scopedChildId = (childId == null || childId.isEmpty)
        ? await _parentContext.ensureSelectedChildId()
        : childId;
    final query = <String, dynamic>{
      if (scopedChildId != null && scopedChildId.isNotEmpty) 'childId': scopedChildId,
      if (type != null && type.isNotEmpty) 'type': type,
    };
    final res = await _apiClient.get(
      ApiEndpoints.parentAnnouncements,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'announcements');
  }

  /// Sectioned `data.notifications` per handoff; `page`/`limit` only if backend documents offset pagination.
  Future<Map<String, dynamic>> getNotifications({
    String? childId,
    int? page,
    int? limit,
  }) async {
    final scopedChildId = (childId == null || childId.isEmpty)
        ? await _parentContext.ensureSelectedChildId()
        : childId;
    final query = <String, dynamic>{
      if (scopedChildId != null && scopedChildId.isNotEmpty) 'childId': scopedChildId,
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    };
    final res = await _apiClient.get(
      ApiEndpoints.parentNotifications,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'notifications');
  }

  Future<Map<String, dynamic>> markAllNotificationsRead({String? childId}) async {
    final scopedChildId = (childId == null || childId.isEmpty)
        ? await _parentContext.ensureSelectedChildId()
        : childId;
    final query = <String, dynamic>{
      if (scopedChildId != null && scopedChildId.isNotEmpty) 'childId': scopedChildId,
    };
    final res = await _apiClient.post(
      ApiEndpoints.parentMarkNotificationsRead,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'mark notifications read');
  }
}

