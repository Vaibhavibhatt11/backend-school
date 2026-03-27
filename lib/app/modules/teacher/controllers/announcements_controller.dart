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
    announcements.assignAll(_mockAnnouncements());
    filteredAnnouncements.assignAll(announcements);
    ever(searchQuery, _filter);
    ever(selectedTab, (_) => _filter(searchQuery.value));
  }

  List<Announcement> _mockAnnouncements() {
    return [
      Announcement(
        id: '1',
        title: 'Upcoming Math Midterm Examination',
        content:
            'Please be informed that the midterm examination for Algebra II has been...',
        authorName: 'Ms. Sarah Johnson',
        authorImage: 'https://via.placeholder.com/150',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        targetGrades: ['10-B'],
        isUrgent: false,
        views: 12,
      ),
      Announcement(
        id: '2',
        title: 'Annual Sports Day Registration',
        content:
            'The deadline for sports day registration is tomorrow at 4 PM. Students who haven\'t...',
        authorName: 'Mr. David Smith',
        authorImage: 'https://via.placeholder.com/150',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        targetGrades: ['School-wide'],
        isUrgent: true,
        views: 128,
      ),
      Announcement(
        id: '3',
        title: 'New Lab Safety Protocols',
        content:
            'Effective immediately, all Grade 11 and 12 students must wear enhanced protective gear during chemistry sessions.',
        authorName: 'Dr. Robert Chen',
        authorImage: 'https://via.placeholder.com/150',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        targetGrades: ['11-12'],
        isUrgent: false,
        // imageUrl: 'https://via.placeholder.com/150',
      ),
      Announcement(
        id: '4',
        title: 'Parent-Teacher Meeting Schedule',
        content:
            'The schedule for the upcoming PT meeting has been finalized. Please check the portal to book your slots for individual sessions.',
        authorName: 'Admin',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        targetGrades: ['All'],
        isUrgent: false,
        fileUrl: 'https://example.com/PT_Meeting_2024.pdf',
        fileName: 'PT_Meeting_2024.pdf',
      ),
    ];
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
    // Add the new announcement to the list (mock)
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
