import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import 'parent_api_utils.dart';

class ParentAcademicsService {
  ParentAcademicsService(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getAttendance({
    String? childId,
    String? month,
  }) async {
    final query = <String, dynamic>{
      if (childId != null && childId.isNotEmpty) 'childId': childId,
      if (month != null && month.isNotEmpty) 'month': month,
    };
    final res = await _apiClient.get(
      ApiEndpoints.parentAttendance,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'attendance');
  }

  Future<Map<String, dynamic>> getTimetable({
    String? childId,
    String? day,
  }) async {
    final query = <String, dynamic>{
      if (childId != null && childId.isNotEmpty) 'childId': childId,
      if (day != null && day.isNotEmpty) 'day': day,
    };
    final res = await _apiClient.get(
      ApiEndpoints.parentTimetable,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'timetable');
  }

  Future<Map<String, dynamic>> getProgressReports({
    String? childId,
    String? term,
  }) async {
    final query = <String, dynamic>{
      if (childId != null && childId.isNotEmpty) 'childId': childId,
      if (term != null && term.isNotEmpty) 'term': term,
    };
    final res = await _apiClient.get(
      ApiEndpoints.parentProgressReports,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'progress reports');
  }

  Future<Map<String, dynamic>> getLiveClasses({String? childId}) async {
    final query = <String, dynamic>{
      if (childId != null && childId.isNotEmpty) 'childId': childId,
    };
    final res = await _apiClient.get(
      ApiEndpoints.parentLiveClasses,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'live classes');
  }
}

