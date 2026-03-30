import 'package:get/get.dart';
import '../../../../common/services/parent/parent_academics_service.dart';
import '../../../../common/services/parent/parent_api_utils.dart';
import '../../../../common/services/parent/parent_context_service.dart';

class AttendanceController extends GetxController {
  final ParentAcademicsService _academicsService = Get.find<ParentAcademicsService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final isLoading = false.obs;
  final studentName = ''.obs;
  final studentClass = ''.obs;
  final studentPhotoUrl = ''.obs;
  final month = ''.obs;
  final currentMonthOffset = 0.obs;

  final calendarDays = <int?>[].obs;
  final attendanceStats = <String, int>{'present': 0, 'absent': 0, 'late': 0}.obs;
  final dayStatusMap = <int, String>{}.obs;
  final errorMessage = ''.obs;
  Worker? _childWorker;

  @override
  void onInit() {
    super.onInit();
    _setMonthLabel();
    _generateDays();
    _childWorker = ever<String?>(
      _parentContext.selectedChildId,
      (_) => loadAttendance(),
    );
    loadAttendance();
  }

  void _setMonthLabel() {
    final now = DateTime.now();
    final target = DateTime(now.year, now.month + currentMonthOffset.value, 1);
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    month.value = '${monthNames[target.month - 1]} ${target.year}';
  }

  String _monthParam() {
    final now = DateTime.now();
    final target = DateTime(now.year, now.month + currentMonthOffset.value, 1);
    final mm = target.month.toString().padLeft(2, '0');
    return '${target.year}-$mm';
  }

  void _generateDays() {
    final now = DateTime.now();
    final target = DateTime(now.year, now.month + currentMonthOffset.value, 1);
    final firstWeekdayIndex = target.weekday % 7; // Sunday=0 ... Saturday=6
    final daysInMonth = DateTime(target.year, target.month + 1, 0).day;
    List<int?> days = List.filled(35, null);
    for (int i = 0; i < daysInMonth && i + firstWeekdayIndex < 35; i++) {
      days[i + firstWeekdayIndex] = i + 1;
    }
    calendarDays.value = days;
  }

  Future<void> loadAttendance() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _academicsService.getAttendance(
        childId: _parentContext.selectedChildId.value,
        month: _monthParam(),
      );
      if (data['studentName'] != null) {
        studentName.value = data['studentName'].toString();
      }
      if (data['studentClass'] != null) {
        studentClass.value = data['studentClass'].toString();
      }
      studentPhotoUrl.value =
          (data['photoUrl'] ?? data['avatarUrl'] ?? data['studentPhotoUrl'] ?? studentPhotoUrl.value)
              .toString();
      final stats = data['attendanceStats'];
      if (stats is Map) {
        attendanceStats.assignAll(
          stats.map((key, value) => MapEntry(key.toString(), _asInt(value))),
        );
      }
      final days = data['calendarDays'];
      if (days is List) {
        if (days.isNotEmpty && days.first is Map) {
          final mapped = List<int?>.from(calendarDays);
          dayStatusMap.clear();
          for (final entry in days.whereType<Map>()) {
            final day = _asInt(entry['day']);
            if (day <= 0) continue;
            dayStatusMap[day] = (entry['status'] ?? '').toString().toLowerCase();
          }
          calendarDays.assignAll(mapped);
        } else {
          calendarDays.assignAll(days.map((e) => e == null ? null : _asInt(e)));
        }
      }
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
    } finally {
      isLoading.value = false;
    }
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String getStatusForDay(int day) {
    final apiStatus = dayStatusMap[day];
    if (apiStatus != null && apiStatus.isNotEmpty) return apiStatus;
    return '';
  }

  void previousMonth() {
    currentMonthOffset.value--;
    _setMonthLabel();
    _generateDays();
    loadAttendance();
  }

  void nextMonth() {
    currentMonthOffset.value++;
    _setMonthLabel();
    _generateDays();
    loadAttendance();
  }

  @override
  void onClose() {
    _childWorker?.dispose();
    super.onClose();
  }
}
