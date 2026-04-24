import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import 'package:get/get.dart';
import 'parent_api_utils.dart';
import 'parent_context_service.dart';

class ParentAcademicsService {
  ParentAcademicsService(this._apiClient);

  final ApiClient _apiClient;
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  Future<Map<String, dynamic>> getAttendance({
    String? childId,
    String? month,
  }) async {
    final scopedChildId = (childId == null || childId.isEmpty)
        ? await _parentContext.ensureSelectedChildId()
        : childId;
    final query = <String, dynamic>{
      if (scopedChildId != null && scopedChildId.isNotEmpty)
        'childId': scopedChildId,
      if (month != null && month.isNotEmpty) 'month': month,
    };
    final res = await _apiClient.get(
      ApiEndpoints.parentAttendance,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'attendance');
  }

  Future<Map<String, dynamic>> createLeaveRequest({
    required DateTime fromDate,
    required DateTime toDate,
    required String reason,
    String? childId,
  }) async {
    final scopedChildId = (childId == null || childId.isEmpty)
        ? await _parentContext.ensureSelectedChildId()
        : childId;
    final query = <String, dynamic>{
      if (scopedChildId != null && scopedChildId.isNotEmpty)
        'childId': scopedChildId,
    };
    final res = await _apiClient.post(
      ApiEndpoints.parentLeaveRequests,
      query: query.isEmpty ? null : query,
      data: {
        'fromDate': fromDate.toIso8601String(),
        'toDate': toDate.toIso8601String(),
        'reason': reason,
      },
    );
    return extractApiData(res.data, context: 'leave request');
  }

  Future<Map<String, dynamic>> getTimetable({
    String? childId,
    String? day,
  }) async {
    final scopedChildId = (childId == null || childId.isEmpty)
        ? await _parentContext.ensureSelectedChildId()
        : childId;
    final query = <String, dynamic>{
      if (scopedChildId != null && scopedChildId.isNotEmpty)
        'childId': scopedChildId,
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
    final scopedChildId = (childId == null || childId.isEmpty)
        ? await _parentContext.ensureSelectedChildId()
        : childId;
    final query = <String, dynamic>{
      if (scopedChildId != null && scopedChildId.isNotEmpty)
        'childId': scopedChildId,
      if (term != null && term.isNotEmpty) 'term': term,
    };
    final res = await _apiClient.get(
      ApiEndpoints.parentProgressReports,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'progress reports');
  }

  Future<Map<String, dynamic>> getLiveClasses({String? childId}) async {
    final scopedChildId = (childId == null || childId.isEmpty)
        ? await _parentContext.ensureSelectedChildId()
        : childId;
    final query = <String, dynamic>{
      if (scopedChildId != null && scopedChildId.isNotEmpty)
        'childId': scopedChildId,
    };
    final res = await _apiClient.get(
      ApiEndpoints.parentLiveClasses,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'live classes');
  }

  Future<Map<String, dynamic>> getExamTimetable({
    String? childId,
    String? month,
  }) async {
    final scopedChildId = (childId == null || childId.isEmpty)
        ? await _parentContext.ensureSelectedChildId()
        : childId;
    final query = <String, dynamic>{
      if (scopedChildId != null && scopedChildId.isNotEmpty)
        'childId': scopedChildId,
      if (month != null && month.isNotEmpty) 'month': month,
    };
    final res = await _apiClient.get(
      ApiEndpoints.parentExamTimetable,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'exam timetable');
  }

  Future<Map<String, dynamic>> getAchievements({String? childId}) async {
    final scopedChildId = (childId == null || childId.isEmpty)
        ? await _parentContext.ensureSelectedChildId()
        : childId;
    final query = <String, dynamic>{
      if (scopedChildId != null && scopedChildId.isNotEmpty)
        'childId': scopedChildId,
    };
    final res = await _apiClient.get(
      ApiEndpoints.parentAchievements,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'achievements');
  }
}
