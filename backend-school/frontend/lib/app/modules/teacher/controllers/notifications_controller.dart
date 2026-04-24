import 'package:erp_frontend/app/modules/teacher/models/teacher_models.dart';
import 'package:erp_frontend/common/services/staff/staff_service.dart';
import 'package:get/get.dart';

class NotificationsController extends GetxController {
  final StaffService _staffService = Get.find<StaffService>();

  final notifications = <NotificationItem>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _staffService.getDashboard();
      final items = <NotificationItem>[];

      items.addAll(
        _buildItems(
          data['pendingTasks'],
          category: 'Tasks',
          titleBuilder: (value) => 'Pending Task',
        ),
      );
      items.addAll(
        _buildItems(
          data['notifications'],
          category: 'Announcements',
          titleBuilder: (value) => value,
        ),
      );
      items.addAll(
        _buildItems(
          data['upcomingExams'],
          category: 'Exams',
          titleBuilder: (value) => 'Upcoming Exam',
        ),
      );
      items.addAll(
        _buildItems(
          data['meetings'],
          category: 'Meetings',
          titleBuilder: (value) => 'Meeting Update',
        ),
      );

      notifications.assignAll(items);
    } catch (e) {
      errorMessage.value = e.toString();
      notifications.clear();
    } finally {
      isLoading.value = false;
    }
  }

  List<NotificationItem> _buildItems(
    dynamic value, {
    required String category,
    required String Function(String value) titleBuilder,
  }) {
    if (value is! List) {
      return const <NotificationItem>[];
    }

    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList()
        .asMap()
        .entries
        .map(
          (entry) => NotificationItem(
            id: '$category-${entry.key}',
            title: titleBuilder(entry.value),
            body: entry.value,
            category: category,
            timestamp: DateTime.now().subtract(
              Duration(minutes: entry.key * 10),
            ),
            isRead: false,
          ),
        )
        .toList();
  }

  void markAllAsRead() {
    for (final item in notifications) {
      item.isRead = true;
    }
    notifications.refresh();
  }

  void markAsRead(NotificationItem item) {
    item.isRead = true;
    notifications.refresh();
  }
}
