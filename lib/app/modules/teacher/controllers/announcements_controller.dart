import 'package:erp_frontend/app/modules/teacher/models/teacher_models.dart';
import 'package:get/get.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';

class AnnouncementsController extends GetxController {
  final selectedTab = 0.obs; // 0: All Notices, 1: My Classes, 2: Important
  final announcements = <Announcement>[].obs;
  final filteredAnnouncements = <Announcement>[].obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    announcements.clear();
    filteredAnnouncements.assignAll(announcements);
    ever(searchQuery, _filter);
    ever(selectedTab, (_) => _filter(searchQuery.value));
  }

  void _filter(String query) {
    var filtered =
        announcements.where((a) {
          if (selectedTab.value == 1 && !a.targetGrades.contains('10-A')) {
            return false; // example
          }
          if (selectedTab.value == 2 && !a.isUrgent) return false;
          if (query.isNotEmpty &&
              !a.title.toLowerCase().contains(query.toLowerCase())) {
            return false;
          }
          return true;
        }).toList();
    filteredAnnouncements.assignAll(filtered);
  }

  void createAnnouncement(Map<String, dynamic> data) {
    final newAnnouncement = Announcement(
      id: DateTime.now().toString(),
      title: data['title'],
      content: data['content'],
      authorName: 'Ms. Sarah Jenkins', // from logged in user
      authorImage: null,
      timestamp: DateTime.now(),
      targetGrades: [data['target'] ?? 'All'],
      isUrgent: data['isUrgent'] ?? false,
      views: 0,
    );
    announcements.insert(0, newAnnouncement);
    filteredAnnouncements.insert(0, newAnnouncement);
    Get.back(); // close dialog
    AppToast.show('Announcement created');
  }
}
