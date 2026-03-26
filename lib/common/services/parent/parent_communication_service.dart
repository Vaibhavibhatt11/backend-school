import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import 'parent_api_utils.dart';

class ParentCommunicationService {
  ParentCommunicationService(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getAnnouncements({
    String? childId,
    String? type,
  }) async {
    final query = <String, dynamic>{
      if (childId != null && childId.isNotEmpty) 'childId': childId,
      if (type != null && type.isNotEmpty) 'type': type,
    };
    final res = await _apiClient.get(
      ApiEndpoints.parentAnnouncements,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'announcements');
  }

  Future<Map<String, dynamic>> getNotifications({String? childId}) async {
    final query = <String, dynamic>{
      if (childId != null && childId.isNotEmpty) 'childId': childId,
    };
    final res = await _apiClient.get(
      ApiEndpoints.parentNotifications,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'notifications');
  }
}

