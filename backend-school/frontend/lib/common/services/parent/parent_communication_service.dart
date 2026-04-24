import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import 'package:get/get.dart';
import 'parent_api_utils.dart';
import 'parent_context_service.dart';

class ParentCommunicationService {
  ParentCommunicationService(this._apiClient);

  final ApiClient _apiClient;
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  Future<Map<String, dynamic>> getAnnouncements({
    String? childId,
    String? type,
  }) async {
    final scopedChildId = (childId == null || childId.isEmpty)
        ? await _parentContext.ensureSelectedChildId()
        : childId;
    final query = <String, dynamic>{
      if (scopedChildId != null && scopedChildId.isNotEmpty)
        'childId': scopedChildId,
      if (type != null && type.isNotEmpty) 'type': type,
    };
    final res = await _apiClient.get(
      ApiEndpoints.parentAnnouncements,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'announcements');
  }

  /// Sectioned `data.notifications` per handoff; `page`/`limit` only if backend documents offset pagination.
  Future<Map<String, dynamic>> getNotifications({
    String? childId,
    int? page,
    int? limit,
  }) async {
    final scopedChildId = (childId == null || childId.isEmpty)
        ? await _parentContext.ensureSelectedChildId()
        : childId;
    final query = <String, dynamic>{
      if (scopedChildId != null && scopedChildId.isNotEmpty)
        'childId': scopedChildId,
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    };
    final res = await _apiClient.get(
      ApiEndpoints.parentNotifications,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'notifications');
  }

  Future<Map<String, dynamic>> markAllNotificationsRead({
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
      ApiEndpoints.parentMarkNotificationsRead,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'mark notifications read');
  }

  Future<Map<String, dynamic>> createMeetingRequest({
    required String teacher,
    required String purpose,
    required DateTime preferredDate,
    String? timeSlot,
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
      ApiEndpoints.parentMeetingsRequest,
      query: query.isEmpty ? null : query,
      data: {
        'teacher': teacher,
        'purpose': purpose,
        'preferredDate': preferredDate.toIso8601String(),
        if (timeSlot != null && timeSlot.isNotEmpty) 'timeSlot': timeSlot,
      },
    );
    return extractApiData(res.data, context: 'meeting request');
  }

  Future<Map<String, dynamic>> getMeetings({String? childId}) async {
    final scopedChildId = (childId == null || childId.isEmpty)
        ? await _parentContext.ensureSelectedChildId()
        : childId;
    final query = <String, dynamic>{
      if (scopedChildId != null && scopedChildId.isNotEmpty)
        'childId': scopedChildId,
    };
    final res = await _apiClient.get(
      ApiEndpoints.parentMeetings,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'meetings');
  }

  Future<Map<String, dynamic>> getMessages({String? childId}) async {
    final scopedChildId = (childId == null || childId.isEmpty)
        ? await _parentContext.ensureSelectedChildId()
        : childId;
    final query = <String, dynamic>{
      if (scopedChildId != null && scopedChildId.isNotEmpty)
        'childId': scopedChildId,
    };
    final res = await _apiClient.get(
      ApiEndpoints.parentMessages,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'messages');
  }

  Future<Map<String, dynamic>> sendMessage({
    required String teacher,
    required String subject,
    required String message,
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
      ApiEndpoints.parentMessages,
      query: query.isEmpty ? null : query,
      data: {'teacher': teacher, 'subject': subject, 'message': message},
    );
    return extractApiData(res.data, context: 'send message');
  }

  Future<Map<String, dynamic>> getEventTimetable({
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
      ApiEndpoints.parentEventTimetable,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'event timetable');
  }

  Future<Map<String, dynamic>> getEventsHub({String? childId}) async {
    final scopedChildId = (childId == null || childId.isEmpty)
        ? await _parentContext.ensureSelectedChildId()
        : childId;
    final query = <String, dynamic>{
      if (scopedChildId != null && scopedChildId.isNotEmpty)
        'childId': scopedChildId,
    };
    final res = await _apiClient.get(
      ApiEndpoints.parentEvents,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'events');
  }

  Future<Map<String, dynamic>> registerForEvent(
    String eventId, {
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
      ApiEndpoints.parentEventRegister(eventId),
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'event registration');
  }

  Future<Map<String, dynamic>> cancelEventRegistration(
    String eventId, {
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
      ApiEndpoints.parentEventCancel(eventId),
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'cancel event registration');
  }
}
