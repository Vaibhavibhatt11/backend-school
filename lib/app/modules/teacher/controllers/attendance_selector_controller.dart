import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../../../../common/api/api_client.dart';
import '../../../../common/api/api_endpoints.dart';
import '../../../../common/services/parent/parent_api_utils.dart';
import '../../../../common/services/staff/staff_service.dart';

class AttendanceSelectorController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final StaffService _staffService = Get.find<StaffService>();

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  /// 0 = Pending, 1 = Completed
  final selectedTabIndex = 0.obs;

  final pendingClasses = <Map<String, dynamic>>[].obs;
  final completedClasses = <Map<String, dynamic>>[].obs;

  final selectedDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      selectedDate.value = DateTime.now();
      final staffProfile = await _staffService.getProfile();
      final staffId = staffProfile['staffId']?.toString();
      if (staffId == null || staffId.isEmpty) {
        throw Exception('Staff profile not found for attendance marking.');
      }

      final res = await _apiClient.get(
        ApiEndpoints.schoolTimetableTeacher(staffId),
      );
      final data = extractApiData(
        res.data,
        context: 'teacher timetable',
      );

      final items = data['items'];
      if (items is! List) {
        pendingClasses.clear();
        completedClasses.clear();
        return;
      }

      final now = selectedDate.value;
      final todayYmd = '${now.year}-${now.month}-${now.day}';

      // Build a unique set of classes for today (dedupe by classRoom.id).
      final byClassId = <String, Map<String, dynamic>>{};
      for (final raw in items) {
        if (raw is! Map) continue;
        final classRoom = raw['classRoom'];
        if (classRoom is! Map) continue;
        final classId = classRoom['id']?.toString();
        if (classId == null || classId.isEmpty) continue;

        final startsAt = raw['startsAt'] != null ? DateTime.parse(raw['startsAt'].toString()) : null;
        if (startsAt == null) continue;
        final localYmd = '${startsAt.toLocal().year}-${startsAt.toLocal().month}-${startsAt.toLocal().day}';
        if (localYmd != todayYmd) continue;

        final subjectName = (raw['subject'] is Map ? raw['subject']['name']?.toString() : null) ??
            raw['title']?.toString() ??
            'Class';
        final className = classRoom['name']?.toString() ?? 'Class';
        final section = classRoom['section']?.toString() ?? '';

        final title = section.isNotEmpty ? '$className-$section' : className;
        final time = _formatTimeRange(startsAt, raw['endsAt']?.toString());

        byClassId[classId] = {
          'classId': classId,
          'title': title,
          'subtitle': subjectName,
          'className': className,
          'section': section,
          'time': time,
        };
      }

      final classList = byClassId.values.toList();

      // Completed classes = classes that already have any attendance records for today.
      final completed = <Map<String, dynamic>>[];
      final pending = <Map<String, dynamic>>[];
      await Future.wait(classList.map((cls) async {
        final className = cls['className']?.toString();
        final section = cls['section']?.toString();
        if (className == null || className.isEmpty) {
          pending.add(cls);
          return;
        }

        final resRecords = await _apiClient.get(
          ApiEndpoints.schoolAttendanceRecords,
          query: {
            'type': 'student',
            'date': now.toIso8601String(),
            'className': className,
            if (section != null && section.isNotEmpty) 'section': section,
            'limit': 1,
          },
          // reduce api-client caching issues for dynamic “today”
          options: Options(extra: {'skipCache': true}),
        );

        final recordsData = extractApiData(
          resRecords.data,
          context: 'attendance records',
        );
        final items = recordsData['items'];
        final hasAny = items is List && items.isNotEmpty;
        if (hasAny) {
          completed.add(cls);
        } else {
          pending.add(cls);
        }
      }));

      pendingClasses.assignAll(pending);
      completedClasses.assignAll(completed);
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      pendingClasses.clear();
      completedClasses.clear();
    } finally {
      isLoading.value = false;
    }
  }

  String _formatTimeRange(DateTime start, String? endsAtRaw) {
    final startLocal = start.toLocal();
    final startStr = _formatTime(startLocal);
    final endsAt = endsAtRaw == null || endsAtRaw.isEmpty ? null : DateTime.tryParse(endsAtRaw);
    if (endsAt == null) return startStr;
    final endLocal = endsAt.toLocal();
    final endStr = _formatTime(endLocal);
    return '$startStr — $endStr';
  }

  String _formatTime(DateTime d) {
    final h = d.hour;
    final hour12 = h % 12 == 0 ? 12 : h % 12;
    final ampm = h < 12 ? 'AM' : 'PM';
    final mm = d.minute.toString().padLeft(2, '0');
    return '$hour12:$mm $ampm';
  }
}
