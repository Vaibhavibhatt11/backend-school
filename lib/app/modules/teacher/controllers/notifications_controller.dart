import 'package:erp_frontend/app/modules/teacher/models/teacher_models.dart';
import 'package:get/get.dart';

class NotificationsController extends GetxController {
  final notifications = <NotificationItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
  }

  void _loadNotifications() {
    notifications.assignAll([
      NotificationItem(
        id: '1',
        title: 'Attendance Pending',
        body: 'Class 10B attendance for Period 3 has not been submitted yet.',
        category: 'Attendance',
        timestamp: DateTime.now(),
        isRead: false,
      ),
      NotificationItem(
        id: '2',
        title: 'Staff Meeting Rescheduled',
        body: 'The weekly briefing has been moved to 3:00 PM in the Main Hall.',
        category: 'Principal',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      NotificationItem(
        id: '3',
        title: 'Gradebook Update',
        body:
            'New bulk-entry features are now available in your teacher portal.',
        category: 'System',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        isRead: true,
      ),
      NotificationItem(
        id: '4',
        title: 'New Schedule Published',
        body:
            'The revised timetable for the upcoming mid-term exams is now ready.',
        category: 'Timetable',
        timestamp: DateTime.now().subtract(
          const Duration(days: 1, hours: -4, minutes: 30),
        ),
        isRead: true,
      ),
      NotificationItem(
        id: '5',
        title: 'Monthly Report Generated',
        body:
            'Your professional performance summary for last month has been uploaded.',
        category: 'Reports',
        timestamp: DateTime.now().subtract(
          const Duration(days: 1, hours: -9, minutes: 15),
        ),
        isRead: true,
      ),
    ]);
  }

  void markAllAsRead() {
    for (var n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
  }

  void markAsRead(NotificationItem item) {
    item.isRead = true;
    notifications.refresh();
  }
}
