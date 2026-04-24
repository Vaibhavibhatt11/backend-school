import 'package:erp_frontend/app/modules/teacher/models/teacher_models.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/services/staff/staff_service.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';

class LiveClassController extends GetxController {
  final StaffService _staffService = Get.find<StaffService>();

  final searchQuery = ''.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final liveSessions = <ClassSession>[].obs;
  final upcomingSessions = <ClassSession>[].obs;
  final filteredUpcoming = <ClassSession>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadSessions();
    ever(searchQuery, _filterUpcoming);
  }

  Future<void> loadSessions() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _staffService.getDashboard();
      final sessions = _buildSessions(data['todayScheduleItems']);

      liveSessions.assignAll(sessions.where((session) => session.isLive));
      upcomingSessions.assignAll(
        sessions.where((session) => !session.isLive && !session.isCompleted),
      );
      _filterUpcoming(searchQuery.value);
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      liveSessions.clear();
      upcomingSessions.clear();
      filteredUpcoming.clear();
    } finally {
      isLoading.value = false;
    }
  }

  List<ClassSession> _buildSessions(dynamic value) {
    if (value is! List) {
      return const <ClassSession>[];
    }

    final now = DateTime.now();
    return value.whereType<Map>().map((item) {
      final mapped = Map<String, dynamic>.from(item);
      final time = (mapped['time'] ?? '').toString();
      final parts = time.split(':');
      final hour = parts.length == 2 ? int.tryParse(parts[0]) ?? 0 : 0;
      final minute = parts.length == 2 ? int.tryParse(parts[1]) ?? 0 : 0;
      final start = DateTime(now.year, now.month, now.day, hour, minute);
      final end = start.add(const Duration(minutes: 45));

      return ClassSession(
        id: '${mapped['subject'] ?? 'class'}-$time',
        title: (mapped['subject'] ?? 'Class').toString(),
        grade: (mapped['classLabel'] ?? '').toString(),
        subject: (mapped['subject'] ?? 'Class').toString(),
        room: (mapped['classLabel'] ?? '').toString(),
        startTime: start,
        endTime: end,
        isLive: !now.isBefore(start) && now.isBefore(end),
        isCompleted: now.isAfter(end),
      );
    }).toList();
  }

  void _filterUpcoming(String query) {
    if (query.isEmpty) {
      filteredUpcoming.assignAll(upcomingSessions);
      return;
    }

    final normalized = query.toLowerCase();
    filteredUpcoming.assignAll(
      upcomingSessions.where(
        (session) =>
            session.title.toLowerCase().contains(normalized) ||
            session.grade.toLowerCase().contains(normalized),
      ),
    );
  }

  void createLiveSession() {
    loadSessions();
  }

  void joinSession(String sessionId) {
    AppToast.show('Opening class $sessionId');
  }
}
