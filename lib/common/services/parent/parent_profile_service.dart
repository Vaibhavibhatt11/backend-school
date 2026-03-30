import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import 'package:get/get.dart';
import 'parent_api_utils.dart';
import 'parent_context_service.dart';

class ParentProfileService {
  ParentProfileService(this._apiClient);

  final ApiClient _apiClient;
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  Future<Map<String, dynamic>> getProfileHub({String? childId}) async {
    final scopedChildId = (childId == null || childId.isEmpty)
        ? await _parentContext.ensureSelectedChildId()
        : childId;
    final query = <String, dynamic>{
      if (scopedChildId != null && scopedChildId.isNotEmpty) 'childId': scopedChildId,
    };
    final res = await _apiClient.get(
      ApiEndpoints.parentProfileHub,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'profile hub');
  }

  Future<Map<String, dynamic>> getLibrary({
    String? childId,
    int? page,
    int? limit,
    String? search,
  }) async {
    final scopedChildId = (childId == null || childId.isEmpty)
        ? await _parentContext.ensureSelectedChildId()
        : childId;
    final query = <String, dynamic>{
      if (scopedChildId != null && scopedChildId.isNotEmpty) 'childId': scopedChildId,
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final res = await _apiClient.get(
      ApiEndpoints.parentLibrary,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'library');
  }

  Future<Map<String, dynamic>> getDocuments({
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
      ApiEndpoints.parentDocuments,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'documents');
  }
}

