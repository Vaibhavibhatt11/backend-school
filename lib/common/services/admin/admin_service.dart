import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import '../parent/parent_api_utils.dart';

class AdminService {
  AdminService(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getSchoolAdminDashboard() async {
    final res = await _apiClient.get(ApiEndpoints.dashboardSchoolAdmin);
    return extractApiData(res.data, context: 'admin dashboard');
  }

  Future<Map<String, dynamic>> getPendingApprovalsSummary() async {
    final res = await _apiClient.get(ApiEndpoints.schoolApprovalsPendingSummary);
    return extractApiData(res.data, context: 'pending approvals');
  }

  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (status != null && status.isNotEmpty) 'status': status,
    };
    final res = await _apiClient.get(ApiEndpoints.schoolNotifications, query: query);
    return extractApiData(res.data, context: 'notifications');
  }

  Future<Map<String, dynamic>> getFeeSnapshot() async {
    final res = await _apiClient.get(ApiEndpoints.schoolFeesSnapshot);
    return extractApiData(res.data, context: 'fee snapshot');
  }

  /// Optional breakdown; shape may include `breakdown`, `categories`, or `structures`.
  Future<Map<String, dynamic>> getFeesSummary() async {
    final res = await _apiClient.get(ApiEndpoints.schoolFeesSummary);
    return extractApiData(res.data, context: 'fees summary');
  }

  Future<Map<String, dynamic>> getAttendanceTrend({
    int days = 7,
    String type = 'student',
  }) async {
    final res = await _apiClient.get(
      ApiEndpoints.schoolAttendanceTrend,
      query: {'days': days, 'type': type},
    );
    return extractApiData(res.data, context: 'attendance trend');
  }

  Future<Map<String, dynamic>> getAttendanceOverview({String? date}) async {
    final query = <String, dynamic>{
      if (date != null && date.isNotEmpty) 'date': date,
    };
    final res = await _apiClient.get(
      ApiEndpoints.schoolAttendanceOverview,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'attendance overview');
  }

  Future<Map<String, dynamic>> getProfileMe() async {
    final res = await _apiClient.get(ApiEndpoints.schoolProfileMe);
    return extractApiData(res.data, context: 'admin profile me');
  }

  Future<Map<String, dynamic>> getSchoolProfile() async {
    final res = await _apiClient.get(ApiEndpoints.schoolProfile);
    return extractApiData(res.data, context: 'school profile');
  }

  Future<Map<String, dynamic>> getSchoolSettings() async {
    final res = await _apiClient.get(ApiEndpoints.schoolSettings);
    return extractApiData(res.data, context: 'school settings');
  }

  Future<Map<String, dynamic>> updateSchoolSettings(Map<String, dynamic> payload) async {
    final res = await _apiClient.put(
      ApiEndpoints.schoolSettings,
      data: payload,
    );
    return extractApiData(res.data, context: 'update school settings');
  }

  Future<Map<String, dynamic>> patchSchoolSettings(Map<String, dynamic> payload) async {
    final res = await _apiClient.patch(
      ApiEndpoints.schoolSettings,
      data: payload,
    );
    return extractApiData(res.data, context: 'patch school settings');
  }

  Future<Map<String, dynamic>> getAnnouncements({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (status != null && status.isNotEmpty) 'status': status,
    };
    final res = await _apiClient.get(ApiEndpoints.schoolAnnouncements, query: query);
    return extractApiData(res.data, context: 'announcements');
  }

  Future<Map<String, dynamic>> getAuditLogs({
    int page = 1,
    int limit = 50,
  }) async {
    final res = await _apiClient.get(
      ApiEndpoints.schoolAuditLogs,
      query: {'page': page, 'limit': limit},
    );
    return extractApiData(res.data, context: 'audit logs');
  }

}
