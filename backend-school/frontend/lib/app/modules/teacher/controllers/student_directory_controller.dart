import 'package:erp_frontend/app/modules/teacher/models/teacher_models.dart';
import 'package:get/get.dart';

import '../../../../common/api/api_client.dart';
import '../../../../common/api/api_endpoints.dart';
import '../../../../common/services/parent/parent_api_utils.dart';
import '../../../../common/services/staff/staff_service.dart';
import '../../../../common/utils/app_toast.dart';

class StudentDirectoryController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final StaffService _staffService = Get.find<StaffService>();

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final classTitle = 'Class'.obs;
  final classSubtitle = ''.obs;
  final studentCount = 0.obs;

  final students = <Student>[].obs;
  final filteredStudents = <Student>[].obs;
  final searchQuery = ''.obs;
  final selectedLetter = 'A'.obs;

  @override
  void onInit() {
    super.onInit();
    load();
    ever(searchQuery, _filter);
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      // Pick a class from today's teacher timetable (fallback to first timetable item).
      final staffProfile = await _staffService.getProfile();
      final staffId = staffProfile['staffId']?.toString();
      if (staffId == null || staffId.isEmpty) {
        throw Exception('Staff profile not found for student directory.');
      }

      final res = await _apiClient.get(ApiEndpoints.schoolTimetableTeacher(staffId));
      final data = extractApiData(res.data, context: 'teacher timetable');
      final items = data['items'];
      if (items is! List || items.isEmpty) {
        students.clear();
        filteredStudents.clear();
        studentCount.value = 0;
        return;
      }

      final now = DateTime.now();
      final todayYmd = '${now.year}-${now.month}-${now.day}';

      Map<String, dynamic>? picked;
      for (final raw in items) {
        if (raw is! Map) continue;
        final classRoom = raw['classRoom'];
        if (classRoom is! Map) continue;
        final startsAtRaw = raw['startsAt']?.toString();
        if (startsAtRaw == null) continue;
        final startsAt = DateTime.tryParse(startsAtRaw);
        if (startsAt == null) continue;
        final localYmd = '${startsAt.toLocal().year}-${startsAt.toLocal().month}-${startsAt.toLocal().day}';
        if (localYmd == todayYmd) {
          picked = raw.cast<String, dynamic>();
          break;
        }
      }

      picked ??= (items.first is Map ? (items.first as Map).cast<String, dynamic>() : null);
      if (picked == null) return;

      final classRoom = (picked['classRoom'] as Map);
      final subject = (picked['subject'] as Map?);

      final className = classRoom['name']?.toString() ?? 'Class';
      final section = classRoom['section']?.toString() ?? '';
      final title = section.isNotEmpty ? '$className-$section' : className;
      classTitle.value = title;

      final subjectName = subject?['name']?.toString();
      classSubtitle.value = subjectName != null && subjectName.isNotEmpty
          ? '$subjectName • ${section.isNotEmpty ? 'Section $section' : className}'
          : (section.isNotEmpty ? 'Section $section' : '');

      // Students roster for picked class.
      final resStudents = await _apiClient.get(
        ApiEndpoints.schoolStudents,
        query: {
          'className': className,
          if (section.isNotEmpty) 'section': section,
          'page': 1,
          'limit': 500,
        },
      );
      final studentsPayload = extractApiData(resStudents.data, context: 'class students');
      final rosterItems = studentsPayload['items'];

      final roster = <Student>[];
      if (rosterItems is List) {
        roster.addAll(rosterItems.whereType<Map>().map((raw) {
          final sid = raw['id']?.toString() ?? '';
          final first = raw['firstName']?.toString() ?? '';
          final last = raw['lastName']?.toString() ?? '';
          final name = '$first $last'.trim().isEmpty ? 'Student' : '$first $last'.trim();
          return Student(
            id: sid,
            name: name,
            rollNo: raw['rollNo']?.toString() ?? '',
            grade: className,
            imageUrl: null,
            parentName: null,
            parentPhone: null,
            attendancePercentage: 0,
            recentAttendance: <String, AttendanceStatus>{},
          );
        }));
      }

      // Today attendance records to populate recentAttendance.
      final recordsRes = await _apiClient.get(
        ApiEndpoints.schoolAttendanceRecords,
        query: {
          'type': 'student',
          'date': now.toIso8601String(),
          'className': className,
          if (section.isNotEmpty) 'section': section,
          'limit': 1000,
        },
      );
      final recordsPayload = extractApiData(recordsRes.data, context: 'attendance records');
      final recordItems = recordsPayload['items'];

      final statusByStudentId = <String, AttendanceStatus>{};
      if (recordItems is List) {
        for (final raw in recordItems.whereType<Map>()) {
          final student = raw['student'] as Map?;
          if (student == null) continue;
          final sid = student['id']?.toString() ?? '';
          final backendStatus = raw['status']?.toString();
          if (sid.isEmpty || backendStatus == null) continue;
          statusByStudentId[sid] = switch (backendStatus) {
            'PRESENT' => AttendanceStatus.present,
            'ABSENT' => AttendanceStatus.absent,
            'LATE' => AttendanceStatus.late,
            _ => AttendanceStatus.unknown,
          };
        }
      }

      // Attach recentAttendance for "today" key so the view can render a status chip.
      final recentKey = todayYmd;
      for (final s in roster) {
        final st = statusByStudentId[s.id] ?? AttendanceStatus.unknown;
        s.recentAttendance[recentKey] = st;
      }

      students.assignAll(roster);
      filteredStudents.assignAll(roster);
      studentCount.value = roster.length;
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      students.clear();
      filteredStudents.clear();
      studentCount.value = 0;
      AppToast.show(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  void _filter(String query) {
    if (query.isEmpty) {
      filteredStudents.assignAll(students);
    } else {
      filteredStudents.assignAll(
        students.where(
          (s) =>
              s.name.toLowerCase().contains(query.toLowerCase()) ||
              s.rollNo.toLowerCase().contains(query.toLowerCase()),
        ),
      );
    }
  }

  void selectLetter(String letter) {
    selectedLetter.value = letter;
    // Optionally scroll to that section
  }

  Map<String, List<Student>> get groupedStudents {
    final map = <String, List<Student>>{};
    for (var student in filteredStudents) {
      String firstLetter = student.name[0].toUpperCase();
      if (!map.containsKey(firstLetter)) {
        map[firstLetter] = [];
      }
      map[firstLetter]!.add(student);
    }
    final sortedKeys = map.keys.toList()..sort();
    final sortedMap = <String, List<Student>>{};
    for (var key in sortedKeys) {
      sortedMap[key] = map[key]!;
    }
    return sortedMap;
  }
}
