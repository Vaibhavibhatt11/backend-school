import 'package:get/get.dart';
import '../../../common/api/api_client.dart';
import '../../../common/api/api_endpoints.dart';
import '../../../common/services/parent/parent_context_service.dart';
import '../../../common/services/session_storage_service.dart';
import '../../../common/services/parent/parent_api_utils.dart';
import 'models/communication_models.dart';

class StudentCommunicationController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final SessionStorageService _sessionStorage = Get.find<SessionStorageService>();
  final RxInt unreadCount = 0.obs;
  final RxList<CommunicationItem> items = <CommunicationItem>[].obs;
  final RxList<ScheduledMeeting> scheduledMeetings = <ScheduledMeeting>[].obs;
  final isScheduling = false.obs;

  /// all | message | alert | announcement | meeting
  final RxString selectedFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    items.clear();
    scheduledMeetings.clear();
    _updateUnreadCount();
  }

  void _updateUnreadCount() {
    unreadCount.value = items.where((e) => !e.isRead).length;
  }

  void addScheduledMeeting({
    required String facultyName,
    required String subject,
    required String reason,
    required DateTime date,
    required String day,
    required String time,
  }) {
    scheduledMeetings.insert(
      0,
      ScheduledMeeting(
        id: 'M${DateTime.now().millisecondsSinceEpoch}',
        facultyName: facultyName.trim(),
        subject: subject.trim(),
        reason: reason.trim(),
        date: date,
        day: day,
        time: time.trim(),
      ),
    );
    _sortMeetings();
  }

  Future<void> submitMeetingRequest({
    required String facultyName,
    required String subject,
    required String reason,
    required DateTime date,
    required String day,
    required String time,
  }) async {
    if (isScheduling.value) return;
    isScheduling.value = true;
    try {
      final loginResponse = await _sessionStorage.getLoginResponse();
      final role =
          (loginResponse?['data']?['user']?['role'] ?? '').toString().toUpperCase();
      final payload = {
        'preferredDate': date.toIso8601String(),
        'purpose': '$subject meeting with $facultyName at $time ($day). Reason: $reason',
      };

      if (role == 'PARENT') {
        String? childId;
        if (Get.isRegistered<ParentContextService>()) {
          final ctx = Get.find<ParentContextService>();
          childId = ctx.selectedChildId.value ?? await ctx.ensureSelectedChildId();
        }
        await _apiClient.post(
          ApiEndpoints.parentMeetingsRequest,
          data: payload,
          query: (childId != null && childId.isNotEmpty) ? {'childId': childId} : null,
        );
      } else {
        await _apiClient.post(ApiEndpoints.studentMeetingsRequest, data: payload);
      }

      addScheduledMeeting(
        facultyName: facultyName,
        subject: subject,
        reason: reason,
        date: date,
        day: day,
        time: time,
      );
    } catch (e) {
      throw Exception(dioOrApiErrorMessage(e));
    } finally {
      isScheduling.value = false;
    }
  }

  void _sortMeetings() {
    final sorted = scheduledMeetings.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    scheduledMeetings.assignAll(sorted);
  }

  List<CommunicationItem> get filteredItems {
    final filter = selectedFilter.value;
    if (filter == 'all' || filter == 'meeting') return items;
    CommunicationType? type;
    if (filter == 'message') type = CommunicationType.message;
    if (filter == 'alert') type = CommunicationType.alert;
    if (filter == 'announcement') type = CommunicationType.announcement;
    if (type == null) return items;
    return items.where((e) => e.type == type).toList();
  }

  bool get showMeetingsOnly => selectedFilter.value == 'meeting';

  bool get showScheduledMeetingsSection =>
      selectedFilter.value == 'all' || selectedFilter.value == 'meeting';

  void setFilter(String filterKey) {
    selectedFilter.value = filterKey;
  }

  void markAsRead(String id) {
    final idx = items.indexWhere((e) => e.id == id);
    if (idx >= 0) {
      items[idx] = CommunicationItem(
        id: items[idx].id,
        type: items[idx].type,
        title: items[idx].title,
        body: items[idx].body,
        from: items[idx].from,
        date: items[idx].date,
        isRead: true,
      );
      items.refresh();
      _updateUnreadCount();
    }
  }
}
