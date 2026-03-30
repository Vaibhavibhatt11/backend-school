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
      if (scopedChildId != null && scopedChildId.isNotEmpty) 'childId': scopedChildId,
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
    final scopedChildId = (childId == null || childId.isEmpty)
        ? await _parentContext.ensureSelectedChildId()
        : childId;
    final query = <String, dynamic>{
      if (scopedChildId != null && scopedChildId.isNotEmpty) 'childId': scopedChildId,
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
      if (scopedChildId != null && scopedChildId.isNotEmpty) 'childId': scopedChildId,
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
      if (scopedChildId != null && scopedChildId.isNotEmpty) 'childId': scopedChildId,
    };
    final res = await _apiClient.get(
      ApiEndpoints.parentLiveClasses,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'live classes');
  }
}

