import 'package:get/get.dart';
import '../../../../common/services/parent/parent_communication_service.dart';
import '../../../../common/services/parent/parent_context_service.dart';

class NotificationsController extends GetxController {
  final ParentCommunicationService _communicationService = Get.find<ParentCommunicationService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final isLoading = false.obs;
  final selectedFilter = 'All'.obs;

  final notifications =
      [
        {
          'section': 'Today',
          'items': [
            {
              'type': 'fee',
              'title': 'Fee Reminder',
              'description':
                  'The tuition fee for the second quarter is due by Friday. Please...',
              'time': '2 mins ago',
              'unread': true,
              'action': 'PAY NOW',
            },
            {
              'type': 'attendance',
              'title': 'Attendance Update',
              'description':
                  'Liam was marked absent for the 1st Period (Mathematics) today.',
              'time': '1 hour ago',
              'unread': true,
            },
            {
              'type': 'general',
              'title': 'School Holiday',
              'description':
                  'The school will remain closed this Friday on account of National Day celebrations.',
              'time': '3 hours ago',
              'unread': false,
            },
          ],
        },
        {
          'section': 'Yesterday',
          'items': [
            {
              'type': 'exam',
              'title': 'Exam Results Out',
              'description':
                  'Results for the Mid-term Science Assessment are now available to view.',
              'time': 'Yesterday, 4:30 PM',
              'unread': false,
              'action': 'VIEW GRADES',
            },
            {
              'type': 'timetable',
              'title': 'Timetable Change',
              'description':
                  'The Physical Education class has been rescheduled to Thursday, Period 4.',
              'time': 'Yesterday, 9:00 AM',
              'unread': false,
            },
          ],
        },
        {
          'section': 'Last Week',
          'items': [
            {
              'type': 'profile',
              'title': 'Profile Updated',
              'description':
                  'Your contact information was successfully updated in our database.',
              'time': 'Oct 12',
              'unread': false,
            },
          ],
        },
      ].obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      final data = await _communicationService.getNotifications(
        childId: _parentContext.selectedChildId.value,
      );
      final items = data['notifications'];
      if (items is List) {
        notifications.assignAll(
          items.whereType<Map>().map((e) => Map<String, Object>.from(e)),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(String filter) => selectedFilter.value = filter;
  void markAllRead() =>
      Get.snackbar('Mark Read', 'All notifications marked as read');
}
