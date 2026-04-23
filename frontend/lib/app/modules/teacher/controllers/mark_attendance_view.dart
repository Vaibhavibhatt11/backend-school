import 'package:erp_frontend/common/api/api_client.dart';
import 'package:erp_frontend/common/api/api_endpoints.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';

class Students {
  final String studentId;
  final String name;
  final String rollNo;
  final String imageUrl;
  RxString status; // 'P', 'A', 'L' or '' (not selected)

  Students({
    required this.studentId,
    required this.name,
    required this.rollNo,
    this.imageUrl = '',
    required String initialStatus,
  }) : status = RxString(initialStatus);
}

class MarkAttendanceController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final selectedClassName = ''.obs;
  final selectedSection = ''.obs;

  final allStudents = <Students>[].obs;
  final filteredStudents = <Students>[].obs;
  final searchQuery = ''.obs;

  final presentCount = 0.obs;
  final absentCount = 0.obs;
  final lateCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    ever<String>(searchQuery, _filter);
    _loadFromArguments();
  }

  Future<void> _loadFromArguments() async {
    final args = (Get.arguments as Map?)?.cast<String, dynamic>() ?? const {};
    final classMap = args['class'] as Map?;
    if (classMap == null) {
      errorMessage.value = 'Class not provided.';
      return;
    }

    selectedClassName.value = classMap['className']?.toString() ?? classMap['title']?.toString() ?? '';
    selectedSection.value = classMap['section']?.toString() ?? '';

    await loadAttendanceForToday();
  }

  void _filter(String query) {
    if (query.isEmpty) {
      filteredStudents.assignAll(allStudents);
    } else {
      final q = query.toLowerCase();
      filteredStudents.assignAll(
        allStudents.where((s) => s.name.toLowerCase().contains(q) || s.rollNo.toLowerCase().contains(q)),
      );
    }
  }

  void _recalculateCounts() {
    presentCount.value = allStudents.where((s) => s.status.value == 'P').length;
    absentCount.value = allStudents.where((s) => s.status.value == 'A').length;
    lateCount.value = allStudents.where((s) => s.status.value == 'L').length;
  }

  void updateStatus(Students student, String newStatus) {
    student.status.value = newStatus;
    _recalculateCounts();
  }

  void markAllPresent() {
    for (final s in allStudents) {
      s.status.value = 'P';
    }
    _recalculateCounts();
    filteredStudents.assignAll(filteredStudents); // trigger Obx updates
  }

  Future<void> loadAttendanceForToday() async {
    if (selectedClassName.value.isEmpty) return;

    isLoading.value = true;
    errorMessage.value = '';
    try {
      final now = DateTime.now();
      final dateIso = now.toIso8601String();

      // 1) Load students roster
      final resStudents = await _apiClient.get(
        ApiEndpoints.schoolStudents,
        query: {
          'className': selectedClassName.value,
          if (selectedSection.value.isNotEmpty) 'section': selectedSection.value,
          'page': 1,
          'limit': 300,
        },
      );
      final studentsPayload = extractApiData(resStudents.data, context: 'students roster');
      final rosterItems = studentsPayload['items'];

      final roster = <Students>[];
      if (rosterItems is List) {
        for (final raw in rosterItems.whereType<Map>()) {
          final id = raw['id']?.toString() ?? '';
          if (id.isEmpty) continue;
          final first = raw['firstName']?.toString() ?? '';
          final last = raw['lastName']?.toString() ?? '';
          final name = '$first $last'.trim();
          roster.add(
            Students(
              studentId: id,
              name: name.isEmpty ? 'Student' : name,
              rollNo: raw['rollNo']?.toString() ?? '',
              initialStatus: '',
            ),
          );
        }
      }

      // 2) Load existing attendance records for today
      final resRecords = await _apiClient.get(
        ApiEndpoints.schoolAttendanceRecords,
        query: {
          'type': 'student',
          'date': dateIso,
          'className': selectedClassName.value,
          if (selectedSection.value.isNotEmpty) 'section': selectedSection.value,
          'limit': 1000,
        },
      );
      final recordsPayload = extractApiData(resRecords.data, context: 'attendance records');
      final recordItems = recordsPayload['items'];

      final statusByStudentId = <String, String>{};
      if (recordItems is List) {
        for (final raw in recordItems.whereType<Map>()) {
          final student = raw['student'] as Map?;
          if (student == null) continue;
          final sid = student['id']?.toString() ?? '';
          final backendStatus = raw['status']?.toString();
          if (sid.isEmpty || backendStatus == null) continue;

          final uiStatus = switch (backendStatus) {
            'PRESENT' => 'P',
            'ABSENT' => 'A',
            'LATE' => 'L',
            'LEAVE' => 'A',
            _ => '',
          };
          if (uiStatus.isNotEmpty) statusByStudentId[sid] = uiStatus;
        }
      }

      // Apply existing statuses
      for (final s in roster) {
        final existing = statusByStudentId[s.studentId];
        if (existing != null) {
          s.status.value = existing;
        }
      }

      allStudents.assignAll(roster);
      filteredStudents.assignAll(roster);
      _recalculateCounts();
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      AppToast.show(errorMessage.value);
      allStudents.clear();
      filteredStudents.clear();
      presentCount.value = 0;
      absentCount.value = 0;
      lateCount.value = 0;
    } finally {
      isLoading.value = false;
    }
  }

  String _toBackendStatus(String uiStatus) {
    return switch (uiStatus) {
      'P' => 'PRESENT',
      'A' => 'ABSENT',
      'L' => 'LATE',
      _ => 'ABSENT',
    };
  }

  Future<void> submitAttendance() async {
    if (allStudents.isEmpty) return;

    // Validate: must select status for each student
    for (final s in allStudents) {
      if (s.status.value.isEmpty) {
        AppToast.show('Please mark attendance for all students.');
        return;
      }
    }

    isLoading.value = true;
    try {
      final now = DateTime.now();
      final dateIso = now.toIso8601String();

      final records = allStudents
          .map((s) => {
                'studentId': s.studentId,
                'status': _toBackendStatus(s.status.value),
                // optional remark can be added later
                'remark': null,
              })
          .toList();

      await _apiClient.post(
        ApiEndpoints.schoolAttendanceBulkMark,
        data: {
          'type': 'student',
          'date': dateIso,
          'records': records,
        },
      );

      AppToast.show('Attendance submitted successfully');
      Get.back();
    } catch (e) {
      final msg = dioOrApiErrorMessage(e);
      AppToast.show(msg);
    } finally {
      isLoading.value = false;
    }
  }
}
