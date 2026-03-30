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

  Future<Map<String, dynamic>> decideApproval({
    required String approvalType,
    required String id,
    required bool approve,
    String? reason,
  }) async {
    final endpoint = ApiEndpoints.schoolApprovalDecision(approvalType, id);
    final res = await _apiClient.patch(
      endpoint,
      data: {
        'decision': approve ? 'APPROVED' : 'REJECTED',
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
    return extractApiData(res.data, context: 'approval decision');
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

  Future<Map<String, dynamic>> getClasses({
    int page = 1,
    int limit = 100,
  }) async {
    final res = await _apiClient.get(
      ApiEndpoints.schoolClasses,
      query: {'page': page, 'limit': limit},
    );
    return extractApiData(res.data, context: 'classes');
  }

  Future<Map<String, dynamic>> getAttendanceReport({
    String? dateFrom,
    String? dateTo,
    String type = 'student',
  }) async {
    final query = <String, dynamic>{
      'type': type,
      if (dateFrom != null && dateFrom.isNotEmpty) 'dateFrom': dateFrom,
      if (dateTo != null && dateTo.isNotEmpty) 'dateTo': dateTo,
    };
    final res = await _apiClient.get(
      ApiEndpoints.schoolReportAttendance,
      query: query,
    );
    return extractApiData(res.data, context: 'attendance report');
  }

  Future<Map<String, dynamic>> getFeesReport({
    String? dateFrom,
    String? dateTo,
  }) async {
    final query = <String, dynamic>{
      if (dateFrom != null && dateFrom.isNotEmpty) 'dateFrom': dateFrom,
      if (dateTo != null && dateTo.isNotEmpty) 'dateTo': dateTo,
    };
    final res = await _apiClient.get(
      ApiEndpoints.schoolReportFees,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'fees report');
  }

}
