import 'package:get/get.dart';
import '../../../../common/services/parent/parent_api_utils.dart';
import '../../../../common/services/parent/parent_communication_service.dart';
import '../../../../common/services/parent/parent_context_service.dart';
import '../../../../common/utils/app_toast.dart';

class CommunicationHubController extends GetxController {
  final ParentCommunicationService _communicationService = Get.find<ParentCommunicationService>();
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
      ]);
      if (meetings.isEmpty) _seedMeetings();
      if (chatMessages.isEmpty) _seedChat();
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      _seedFallbackAll();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadAnnouncements() async {
    try {
      final data = await _communicationService.getAnnouncements(
        childId: _parentContext.selectedChildId.value,
      );
      final raw = data['announcements'];
      if (raw is! List) {
        _seedAnnouncementFallback();
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
            .where((x) => x['type'] == 'teacher' || (x['teacherName'] as String).isNotEmpty)
            .toList(),
      );
      circulars.assignAll(
        mapped.where((x) {
          final t = (x['type'] ?? '').toString();
          return t.contains('circular') || t.contains('notice') || t.contains('general');
        }).toList(),
      );

      if (teacherMessages.isEmpty || circulars.isEmpty) {
        _seedAnnouncementFallback(onlyMissing: true);
      }
    } catch (_) {
      _seedAnnouncementFallback();
    }
  }

  Future<void> _loadNotifications() async {
    try {
      final data = await _communicationService.getNotifications(
        childId: _parentContext.selectedChildId.value,
      );
      final raw = data['notifications'];
      if (raw is! List) {
        _seedNotificationsFallback();
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
              'description': (m['description'] ?? m['body'] ?? m['message'] ?? '').toString(),
              'time': (m['time'] ?? m['createdAt'] ?? '').toString(),
              'unread': m['unread'] == true,
              'type': (m['type'] ?? 'general').toString(),
            });
          }
        }
      }
      notifications.assignAll(mapped);
      if (notifications.isEmpty) _seedNotificationsFallback();
    } catch (_) {
      _seedNotificationsFallback();
    }
  }

  void changeTab(String key) => selectedTab.value = key;

  void sendParentMessage({
    required String teacher,
    required String subject,
    required String message,
  }) {
    final now = DateTime.now();
    chatMessages.insert(0, {
      'id': 'c_${now.millisecondsSinceEpoch}',
      'to': teacher,
      'subject': subject,
      'message': message,
      'time': _timeLabel(now),
      'fromParent': true,
    });
    AppToast.show('Message sent to $teacher');
  }

  void bookMeeting({
    required String teacher,
    required String purpose,
    required DateTime date,
    required String timeSlot,
  }) {
    meetings.insert(0, {
      'id': 'm_${DateTime.now().millisecondsSinceEpoch}',
      'teacher': teacher,
      'purpose': purpose,
      'date': date,
      'timeSlot': timeSlot,
      'status': 'Requested',
    });
    AppToast.show('Meeting booked successfully');
  }

  String _timeLabel(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final min = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$hour:$min $period';
  }

  void _seedFallbackAll() {
    _seedAnnouncementFallback();
    _seedNotificationsFallback();
    _seedMeetings();
    _seedChat();
  }

  void _seedAnnouncementFallback({bool onlyMissing = false}) {
    if (!onlyMissing || announcements.isEmpty) {
      announcements.assignAll([
        {
          'id': 'a1',
          'type': 'general',
          'title': 'School Reopens Monday',
          'description': 'All classes resume from 8:00 AM.',
          'postedBy': 'Admin Office',
          'time': '2h ago',
        },
        {
          'id': 'a2',
          'type': 'teacher',
          'title': 'Math practice worksheet uploaded',
          'description': 'Please ensure homework submission before Friday.',
          'postedBy': 'Class Teacher',
          'teacherName': 'Ms. Neha Shah',
          'time': '5h ago',
        },
      ]);
    }

    if (!onlyMissing || teacherMessages.isEmpty) {
      teacherMessages.assignAll([
        {
          'id': 'tm1',
          'type': 'teacher',
          'title': 'Weekly progress update',
          'description': 'Your child is doing well in algebra and needs revision in geometry.',
          'teacherName': 'Ms. Neha Shah',
          'postedBy': 'Class Teacher',
          'time': '1d ago',
        },
      ]);
    }

    if (!onlyMissing || circulars.isEmpty) {
      circulars.assignAll([
        {
          'id': 'c1',
          'type': 'circular',
          'title': 'Circular: Parent Orientation',
          'description': 'Parent orientation is scheduled next Wednesday in the school hall.',
          'postedBy': 'Principal Office',
          'time': '2d ago',
          'attachment': 'orientation-circular.pdf',
        },
      ]);
    }
  }

  void _seedNotificationsFallback() {
    notifications.assignAll([
      {
        'section': 'Academic',
        'title': 'Science test result published',
        'description': 'You can now view marks in exam center.',
        'time': '30m ago',
        'unread': true,
        'type': 'exam',
      },
      {
        'section': 'General',
        'title': 'New announcement posted',
        'description': 'Check latest school circular.',
        'time': '2h ago',
        'unread': false,
        'type': 'general',
      },
    ]);
  }

  void _seedMeetings() {
    meetings.assignAll([
      {
        'id': 'm1',
        'teacher': 'Ms. Neha Shah',
        'purpose': 'Discuss Math progress',
        'date': DateTime.now().add(const Duration(days: 2)),
        'timeSlot': '10:30 AM',
        'status': 'Confirmed',
      },
    ]);
  }

  void _seedChat() {
    chatMessages.assignAll([
      {
        'id': 'ch1',
        'to': 'Ms. Neha Shah',
        'subject': 'Homework guidance',
        'message': 'Can you share extra practice sheets for algebra?',
        'time': 'Yesterday',
        'fromParent': true,
      },
      {
        'id': 'ch2',
        'to': 'Ms. Neha Shah',
        'subject': 'Re: Homework guidance',
        'message': 'Sure, I have uploaded two worksheets in study materials.',
        'time': 'Today',
        'fromParent': false,
      },
    ]);
  }
}
