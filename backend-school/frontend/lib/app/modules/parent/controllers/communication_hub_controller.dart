import 'package:get/get.dart';
import '../../../../common/services/parent/parent_api_utils.dart';
import '../../../../common/services/parent/parent_communication_service.dart';
import '../../../../common/services/parent/parent_context_service.dart';
import '../../../../common/utils/app_toast.dart';

class CommunicationHubController extends GetxController {
  final ParentCommunicationService _communicationService =
      Get.find<ParentCommunicationService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final selectedTab = 'teacherMessages'.obs;

  final teacherMessages = <Map<String, dynamic>>[].obs;
  final announcements = <Map<String, dynamic>>[].obs;
  final notifications = <Map<String, dynamic>>[].obs;
  final circulars = <Map<String, dynamic>>[].obs;
  final meetings = <Map<String, dynamic>>[].obs;
  final chatMessages = <Map<String, dynamic>>[].obs;

  Worker? _childWorker;

  @override
  void onInit() {
    super.onInit();
    _childWorker = ever<String?>(
      _parentContext.selectedChildId,
      (_) => loadData(),
    );
    loadData();
  }

  @override
  void onClose() {
    _childWorker?.dispose();
    super.onClose();
  }

  Future<void> loadData() async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await _parentContext.ensureSelectedChildId();
      await Future.wait([
        _loadAnnouncements(),
        _loadNotifications(),
        _loadMeetings(),
        _loadMessages(),
      ]);
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      announcements.clear();
      teacherMessages.clear();
      circulars.clear();
      notifications.clear();
      meetings.clear();
      chatMessages.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadAnnouncements() async {
    final data = await _communicationService.getAnnouncements(
      childId: _parentContext.selectedChildId.value,
    );
    final raw = data['announcements'];
    if (raw is! List) {
      announcements.clear();
      teacherMessages.clear();
      circulars.clear();
      return;
    }

    final mapped = raw.whereType<Map>().map((e) {
      final m = Map<String, dynamic>.from(e);
      final type = (m['type'] ?? 'general').toString().toLowerCase();
      return {
        'id': (m['id'] ?? '').toString(),
        'type': type,
        'title': (m['title'] ?? 'Untitled').toString(),
        'description': (m['description'] ?? '').toString(),
        'postedBy': (m['postedBy'] ?? 'School').toString(),
        'time': (m['time'] ?? '').toString(),
        'teacherName': (m['teacherName'] ?? '').toString(),
        'attachment': m['attachment']?.toString(),
      };
    }).toList();

    announcements.assignAll(mapped);
    teacherMessages.assignAll(
      mapped
          .where(
            (x) =>
                x['type'] == 'teacher' ||
                (x['teacherName'] as String).isNotEmpty,
          )
          .toList(),
    );
    circulars.assignAll(
      mapped.where((x) {
        final t = (x['type'] ?? '').toString();
        return t.contains('circular') ||
            t.contains('notice') ||
            t.contains('general');
      }).toList(),
    );
  }

  Future<void> _loadNotifications() async {
    final data = await _communicationService.getNotifications(
      childId: _parentContext.selectedChildId.value,
    );
    final raw = data['notifications'];
    if (raw is! List) {
      notifications.clear();
      return;
    }

    final mapped = <Map<String, dynamic>>[];
    for (final section in raw.whereType<Map>()) {
      final sectionMap = Map<String, dynamic>.from(section);
      final items = sectionMap['items'];
      if (items is List) {
        for (final item in items.whereType<Map>()) {
          final m = Map<String, dynamic>.from(item);
          mapped.add({
            'section': (sectionMap['section'] ?? 'General').toString(),
            'title': (m['title'] ?? m['subject'] ?? '').toString(),
            'description': (m['description'] ?? m['body'] ?? m['message'] ?? '')
                .toString(),
            'time': (m['time'] ?? m['createdAt'] ?? '').toString(),
            'unread': m['unread'] == true,
            'type': (m['type'] ?? 'general').toString(),
          });
        }
      }
    }
    notifications.assignAll(mapped);
  }

  Future<void> _loadMeetings() async {
    final data = await _communicationService.getMeetings(
      childId: _parentContext.selectedChildId.value,
    );
    final raw = data['meetings'];
    if (raw is! List) {
      meetings.clear();
      return;
    }

    meetings.assignAll(
      raw.whereType<Map>().map((e) {
        final m = Map<String, dynamic>.from(e);
        return {
          'id': (m['id'] ?? '').toString(),
          'teacher': (m['teacher'] ?? 'School Staff').toString(),
          'purpose': (m['purpose'] ?? '').toString(),
          'date': _parseDate(m['date']),
          'timeSlot': (m['timeSlot'] ?? '').toString(),
          'status': (m['status'] ?? 'PENDING').toString(),
        };
      }),
    );
  }

  Future<void> _loadMessages() async {
    final data = await _communicationService.getMessages(
      childId: _parentContext.selectedChildId.value,
    );
    final raw = data['messages'];
    if (raw is! List) {
      chatMessages.clear();
      return;
    }

    chatMessages.assignAll(
      raw.whereType<Map>().map((e) {
        final m = Map<String, dynamic>.from(e);
        return {
          'id': (m['id'] ?? '').toString(),
          'to': (m['to'] ?? 'Teacher').toString(),
          'subject': (m['subject'] ?? '').toString(),
          'message': (m['message'] ?? '').toString(),
          'time': (m['time'] ?? '').toString(),
          'fromParent': m['fromParent'] != false,
        };
      }),
    );
  }

  void changeTab(String key) => selectedTab.value = key;

  Future<void> sendParentMessage({
    required String teacher,
    required String subject,
    required String message,
  }) async {
    try {
      await _communicationService.sendMessage(
        childId: _parentContext.selectedChildId.value,
        teacher: teacher,
        subject: subject,
        message: message,
      );
      await _loadMessages();
      AppToast.show('Message sent to $teacher');
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      AppToast.show(errorMessage.value);
    }
  }

  Future<void> bookMeeting({
    required String teacher,
    required String purpose,
    required DateTime date,
    required String timeSlot,
  }) async {
    try {
      await _communicationService.createMeetingRequest(
        childId: _parentContext.selectedChildId.value,
        teacher: teacher,
        purpose: purpose,
        preferredDate: date,
        timeSlot: timeSlot,
      );
      await _loadMeetings();
      AppToast.show('Meeting booked successfully');
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      AppToast.show(errorMessage.value);
    }
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
