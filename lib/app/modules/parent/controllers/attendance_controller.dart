import 'package:get/get.dart';
import '../../../../common/services/parent/parent_academics_service.dart';
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
  Worker? _childWorker;

  @override
  void onInit() {
    super.onInit();
    _generateDays();
    _childWorker = ever<String?>(
      _parentContext.selectedChildId,
      (_) => loadAttendance(),
    );
    loadAttendance();
  }

  void _generateDays() {
    List<int?> days = List.filled(35, null);
    for (int i = 0; i < 31; i++) {
      days[i + 4] = i + 1; // start on Thursday
    }
    calendarDays.value = days;
  }

  Future<void> loadAttendance() async {
    isLoading.value = true;
    try {
      final data = await _academicsService.getAttendance(
        childId: _parentContext.selectedChildId.value,
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
          final mapped = <int?>[];
          dayStatusMap.clear();
          for (final entry in days.whereType<Map>()) {
            final day = _asInt(entry['day']);
            mapped.add(day);
            dayStatusMap[day] = (entry['status'] ?? '').toString().toLowerCase();
          }
          calendarDays.assignAll(mapped);
        } else {
          calendarDays.assignAll(days.map((e) => e == null ? null : _asInt(e)));
        }
      }
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
    if (day == 13) return 'late';
    if (day % 2 == 0) return 'present';
    return 'absent';
  }

  void previousMonth() {
    currentMonthOffset.value--;
    month.value = 'September 2023';
    loadAttendance();
  }

  void nextMonth() {
    currentMonthOffset.value++;
    month.value = 'November 2023';
    loadAttendance();
  }

  @override
  void onClose() {
    _childWorker?.dispose();
    super.onClose();
  }
}
