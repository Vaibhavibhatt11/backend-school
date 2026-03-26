import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import 'parent_api_utils.dart';

class ParentProfileService {
  ParentProfileService(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getProfileHub({String? childId}) async {
    final query = <String, dynamic>{
      if (childId != null && childId.isNotEmpty) 'childId': childId,
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
    final query = <String, dynamic>{
      if (childId != null && childId.isNotEmpty) 'childId': childId,
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
    final query = <String, dynamic>{
      if (childId != null && childId.isNotEmpty) 'childId': childId,
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

