import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/services/staff/staff_service.dart';
import 'package:get/get.dart';

class TeacherHomeController extends GetxController {
  final StaffService _staffService = Get.find<StaffService>();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final teacherName = ''.obs;
  final notificationCount = 0.obs;
  final pendingTask = ''.obs;
  final todayClasses = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadHome();
  }

  Future<void> loadHome() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _staffService.getDashboard();
      teacherName.value = (data['staffName'] ?? '').toString();
      final notifications = _asStringList(data['notifications']);
      notificationCount.value = notifications.length;

      final tasks = _asStringList(data['pendingTasks']);
      pendingTask.value = tasks.isNotEmpty ? tasks.first : '';

      todayClasses.assignAll(_parseScheduleItems(data['todayScheduleItems']));
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      teacherName.value = '';
      notificationCount.value = 0;
      pendingTask.value = '';
      todayClasses.clear();
    } finally {
      isLoading.value = false;
    }
  }

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  List<String> _asStringList(dynamic value) {
    if (value is! List) {
      return const <String>[];
    }
    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  List<Map<String, String>> _parseScheduleItems(dynamic value) {
    if (value is! List) {
      return const <Map<String, String>>[];
    }

    final now = DateTime.now();
    return value.whereType<Map>().map((item) {
      final mapped = Map<String, dynamic>.from(item);
      final time = (mapped['time'] ?? '').toString();
      final classLabel = (mapped['classLabel'] ?? '').toString();
      final status = _statusForTime(now, time);

      return <String, String>{
        'title': (mapped['subject'] ?? 'Class').toString(),
        'grade': classLabel,
        'room': classLabel,
        'time': time,
        'status': status,
      };
    }).toList();
  }

  String _statusForTime(DateTime now, String rawTime) {
    final parts = rawTime.split(':');
    if (parts.length != 2) {
      return 'Upcoming';
    }

    final hour = int.tryParse(parts[0]) ?? -1;
    final minute = int.tryParse(parts[1]) ?? -1;
    if (hour < 0 || minute < 0) {
      return 'Upcoming';
    }

    final start = DateTime(now.year, now.month, now.day, hour, minute);
    final end = start.add(const Duration(minutes: 45));
    if (now.isAfter(end)) {
      return 'Completed';
    }
    if (!now.isBefore(start) && now.isBefore(end)) {
      return 'In Progress';
    }
    return 'Upcoming';
  }
}
