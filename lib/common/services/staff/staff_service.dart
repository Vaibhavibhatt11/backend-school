import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import '../parent/parent_api_utils.dart';

class StaffService {
  StaffService(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getDashboard() async {
    final res = await _apiClient.get(ApiEndpoints.staffDashboard);
    return extractApiData(res.data, context: 'staff dashboard');
  }

  Future<Map<String, dynamic>> getProfile() async {
    final res = await _apiClient.get(ApiEndpoints.staffProfile);
    return extractApiData(res.data, context: 'staff profile');
  }

  Future<Map<String, dynamic>> getReports() async {
    final res = await _apiClient.get(ApiEndpoints.staffReports);
    return extractApiData(res.data, context: 'staff reports');
  }

  Future<Map<String, dynamic>> getCommunication() async {
    final res = await _apiClient.get(ApiEndpoints.staffCommunication);
    return extractApiData(res.data, context: 'staff communication');
  }
}
