import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';

class ParentAcademicsService {
  ParentAcademicsService(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getAttendance() async {
    final res = await _apiClient.get(ApiEndpoints.parentAttendance);
    final body = res.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid attendance response.');
    }
    return body;
  }

  Future<Map<String, dynamic>> getTimetable() async {
    final res = await _apiClient.get(ApiEndpoints.parentTimetable);
    final body = res.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid timetable response.');
    }
    return body;
  }

  Future<Map<String, dynamic>> getProgressReports() async {
    final res = await _apiClient.get(ApiEndpoints.parentProgressReports);
    final body = res.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid progress reports response.');
    }
    return body;
  }

  Future<Map<String, dynamic>> getLiveClasses() async {
    final res = await _apiClient.get(ApiEndpoints.parentLiveClasses);
    final body = res.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid live classes response.');
    }
    return body;
  }
}

