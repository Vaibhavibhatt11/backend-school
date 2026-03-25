// lib/app/modules/teacher/controllers/live_class_controller.dart
import 'package:erp_frontend/app/modules/teacher/models/teacher_models.dart';
import 'package:get/get.dart';

class LiveClassController extends GetxController {
  final searchQuery = ''.obs;
  final liveSessions = <ClassSession>[].obs;
  final upcomingSessions = <ClassSession>[].obs;
  final filteredUpcoming = <ClassSession>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadSessions();
    ever(searchQuery, _filterUpcoming);
  }

  void _loadSessions() {
    liveSessions.assignAll([
      ClassSession(
        id: 'l1',
        title: 'Advanced Mathematics',
        grade: 'Grade 10-A',
        subject: 'Mathematics',
        room: 'Room 402',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        isLive: true,
      ),
    ]);

    upcomingSessions.assignAll([
      ClassSession(
        id: 'u1',
        title: 'English Literature',
        grade: 'Grade 11-C',
        subject: 'English',
        room: '',
        startTime: DateTime.now().add(const Duration(hours: 2)),
        endTime: DateTime.now().add(const Duration(hours: 3)),
      ),
      ClassSession(
        id: 'u2',
        title: 'Physics Workshop',
        grade: 'Grade 12-B',
        subject: 'Physics',
        room: '',
        startTime: DateTime.now().add(const Duration(hours: 4)),
        endTime: DateTime.now().add(const Duration(hours: 5)),
      ),
      ClassSession(
        id: 'u3',
        title: 'Modern History',
        grade: 'Grade 10-A',
        subject: 'History',
        room: '',
        startTime: DateTime.now().add(const Duration(days: 1)),
        endTime: DateTime.now().add(const Duration(days: 1, hours: 1)),
      ),
    ]);
    filteredUpcoming.assignAll(upcomingSessions);
  }

  void _filterUpcoming(String query) {
    if (query.isEmpty) {
      filteredUpcoming.assignAll(upcomingSessions);
    } else {
      filteredUpcoming.assignAll(
        upcomingSessions.where(
          (s) => s.title.toLowerCase().contains(query.toLowerCase()),
        ),
      );
    }
  }

  void createLiveSession() {
    // Navigate to create session screen (not implemented, just snackbar)
    Get.snackbar('Create Session', 'Feature coming soon!');
  }

  void joinSession(String sessionId) {
    // Open meeting link – for demo, show snackbar
    Get.snackbar('Join Session', 'Joining session $sessionId');
  }
}
