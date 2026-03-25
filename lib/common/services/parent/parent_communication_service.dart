import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';

class ParentCommunicationService {
  ParentCommunicationService(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getAnnouncements() async {
    final res = await _apiClient.get(ApiEndpoints.parentAnnouncements);
    final body = res.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid announcements response.');
    }
    return body;
  }

  Future<Map<String, dynamic>> getNotifications() async {
    final res = await _apiClient.get(ApiEndpoints.parentNotifications);
    final body = res.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid notifications response.');
    }
    return body;
  }
}

