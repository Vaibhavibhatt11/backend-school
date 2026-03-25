import 'package:get/get.dart';
import 'models/communication_models.dart';

class StudentCommunicationController extends GetxController {
  final RxInt unreadCount = 0.obs;
  final RxList<CommunicationItem> items = <CommunicationItem>[].obs;
  final RxList<ScheduledMeeting> scheduledMeetings = <ScheduledMeeting>[].obs;

  /// all | message | alert | announcement | meeting
  final RxString selectedFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
    _loadMockMeetings();
    _updateUnreadCount();
  }

  void _loadMockData() {
    final now = DateTime.now();
    items.assignAll([
      CommunicationItem(
        id: '1',
        type: CommunicationType.announcement,
        title: 'School holiday – 15 March',
        body: 'School will remain closed on 15 March for local holiday. Classes will resume on 16 March.',
        from: 'School Admin',
        date: now.subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      CommunicationItem(
        id: '2',
        type: CommunicationType.alert,
        title: 'Fee payment reminder',
        body: 'Transport fee for March is due by 10 March. Please pay online or at the office.',
        from: 'Accounts',
        date: now.subtract(const Duration(days: 1)),
        isRead: false,
      ),
      CommunicationItem(
        id: '3',
        type: CommunicationType.message,
        title: 'Science project submission',
        body: 'Please submit your science project by Friday. Contact your class teacher for guidelines.',
        from: 'Mr. Sharma (Science)',
        date: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
      CommunicationItem(
        id: '4',
        type: CommunicationType.announcement,
        title: 'Parent-teacher meeting',
        body: 'PTM scheduled for 20 March, 10 AM–1 PM. Please confirm your slot via the app.',
        from: 'School Admin',
        date: now.subtract(const Duration(days: 3)),
        isRead: true,
      ),
      CommunicationItem(
        id: '5',
        type: CommunicationType.message,
        title: 'Homework feedback',
        body: 'Good progress on the last assignment. See comments in the homework section.',
        from: 'Ms. Patel (English)',
        date: now.subtract(const Duration(days: 4)),
        isRead: true,
      ),
    ]);
    _updateUnreadCount();
  }

  void _updateUnreadCount() {
    unreadCount.value = items.where((e) => !e.isRead).length;
  }

  void _loadMockMeetings() {
    final now = DateTime.now();
    scheduledMeetings.assignAll([
      ScheduledMeeting(
        id: 'M1',
        facultyName: 'Ms. Patel',
        subject: 'English',
        reason: 'Clarification on essay feedback and writing structure.',
        date: now.add(const Duration(days: 2)),
        day: 'Wednesday',
        time: '11:30 AM',
      ),
    ]);
    _sortMeetings();
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
