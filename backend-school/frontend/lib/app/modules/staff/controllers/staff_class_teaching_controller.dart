import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/staff/staff_portal_store_service.dart';
import 'package:erp_frontend/common/services/staff/staff_service.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';

class StaffClassTeachingController extends GetxController {
  StaffClassTeachingController(
    this._adminService,
    this._staffService,
    this._store,
  );

  final AdminService _adminService;
  final StaffService _staffService;
  final StaffPortalStoreService _store;

  final activeTab = 0.obs;
  final classList = <Map<String, String>>[].obs;
  final studentList = <Map<String, String>>[].obs;
  final subjectAssignments = <Map<String, String>>[].obs;
  final classroomSchedule = <Map<String, String>>[].obs;
  final classNotes = <Map<String, String>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
    final args = Get.arguments;
    if (args is Map && args['tab'] == 'schedule') {
      activeTab.value = 3;
    }
  }

  void setTab(int index) {
    if (index < 0 || index > 4) return;
    activeTab.value = index;
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final localClasses = await _loadCollection('classList');
      final localStudents = await _loadCollection('studentList');
      final localAssignments = await _loadCollection('subjectAssignments');
      final localSchedule = await _loadCollection('classroomSchedule');
      final localNotes = await _loadCollection('classNotes');

      final remoteClasses = await _loadRemoteClasses();
      final remoteStudents = await _loadRemoteStudents();
      final remoteTeaching = await _loadRemoteTeachingData();

      classList.assignAll(_mergeRows(remoteClasses, localClasses));
      studentList.assignAll(_mergeRows(remoteStudents, localStudents));
      subjectAssignments.assignAll(
        _mergeRows(remoteTeaching.assignments, localAssignments),
      );
      classroomSchedule.assignAll(
        _mergeRows(remoteTeaching.schedule, localSchedule),
      );
      classNotes.assignAll(localNotes);
    } catch (_) {
      classList.assignAll(await _loadCollection('classList'));
      studentList.assignAll(await _loadCollection('studentList'));
      subjectAssignments.assignAll(await _loadCollection('subjectAssignments'));
      classroomSchedule.assignAll(await _loadCollection('classroomSchedule'));
      classNotes.assignAll(await _loadCollection('classNotes'));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addClass(String name, String section) async {
    if (name.trim().isEmpty) return;
    final cleanSection = section.trim().isEmpty ? 'A' : section.trim();
    try {
      await _adminService.createClass(name: name.trim(), section: cleanSection);
      await loadData();
      AppToast.show('Class added');
    } catch (_) {
      await _store.upsertCollectionItem(
        moduleKey: 'classTeaching',
        collectionKey: 'classList',
        payload: {
          'name': name.trim(),
          'section': cleanSection,
        },
      );
      await loadData();
      AppToast.show('Class saved in staff workspace');
    }
  }

  Future<void> addStudent(String name, String className) async {
    if (name.trim().isEmpty) return;
    final parsed = _splitName(name.trim());
    final classParts = _splitClassLabel(className);
    try {
      await _adminService.createStudent(
        admissionNo: 'AUTO-${DateTime.now().millisecondsSinceEpoch}',
        firstName: parsed.first,
        lastName: parsed.last,
        className: classParts.className,
        section: classParts.section,
        status: 'ACTIVE',
      );
      await loadData();
      AppToast.show('Student added');
    } catch (_) {
      await _store.upsertCollectionItem(
        moduleKey: 'classTeaching',
        collectionKey: 'studentList',
        payload: {
          'name': name.trim(),
          'className': className.trim().isEmpty ? 'Class 1' : className.trim(),
        },
      );
      await loadData();
      AppToast.show('Student saved in staff workspace');
    }
  }

  Future<void> upsertSubjectAssignment({
    required String className,
    required String subject,
    required String teacher,
  }) async {
    if (className.trim().isEmpty || subject.trim().isEmpty) return;
    await _store.upsertCollectionItem(
      moduleKey: 'classTeaching',
      collectionKey: 'subjectAssignments',
      payload: {
        'className': className.trim(),
        'subject': subject.trim(),
        'teacher': teacher.trim().isEmpty ? 'Current Staff' : teacher.trim(),
      },
    );
    await loadData();
    AppToast.show('Subject assigned');
  }

  Future<void> addSchedule({
    required String className,
    required String day,
    required String period,
    required String subject,
  }) async {
    if (className.trim().isEmpty || subject.trim().isEmpty) return;
    await _store.upsertCollectionItem(
      moduleKey: 'classTeaching',
      collectionKey: 'classroomSchedule',
      payload: {
        'className': className.trim(),
        'day': day.trim(),
        'period': period.trim(),
        'subject': subject.trim(),
      },
    );
    await loadData();
    AppToast.show('Schedule updated');
  }

  Future<void> addClassNote({
    required String className,
    required String title,
    required String note,
  }) async {
    if (title.trim().isEmpty || note.trim().isEmpty) return;
    await _store.upsertCollectionItem(
      moduleKey: 'classTeaching',
      collectionKey: 'classNotes',
      payload: {
        'className': className.trim().isEmpty ? 'General' : className.trim(),
        'title': title.trim(),
        'note': note.trim(),
      },
    );
    await loadData();
    AppToast.show('Class note added');
  }

  Map<String, int> metrics() {
    return {
      'classes': classList.length,
      'students': studentList.length,
      'assignments': subjectAssignments.length,
      'schedules': classroomSchedule.length,
      'notes': classNotes.length,
    };
  }

  Future<List<Map<String, String>>> _loadRemoteClasses() async {
    final data = await _adminService.getClasses(page: 1, limit: 200);
    final rawItems = data['items'];
    if (rawItems is! List) {
      return const <Map<String, String>>[];
    }
    return rawItems.whereType<Map>().map((row) {
      final item = row.cast<String, dynamic>();
      return <String, String>{
        'id': _firstText([item['id'], item['name']]),
        'name': _firstText([item['name'], 'Class']),
        'section': _firstText([item['section'], 'A']),
      };
    }).toList(growable: false);
  }

  Future<List<Map<String, String>>> _loadRemoteStudents() async {
    final data = await _adminService.getStudents(page: 1, limit: 200, status: 'ACTIVE');
    final rawItems = data['items'];
    if (rawItems is! List) {
      return const <Map<String, String>>[];
    }
    return rawItems.whereType<Map>().map((row) {
      final item = row.cast<String, dynamic>();
      final fullName = _fullName(item['firstName'], item['lastName']);
      final className = _firstText([item['className'], 'Class']);
      final section = _firstText([item['section']]);
      return <String, String>{
        'id': _firstText([item['id'], item['admissionNo']]),
        'name': fullName.isEmpty ? 'Student' : fullName,
        'className': section.isEmpty ? className : '$className-$section',
      };
    }).toList(growable: false);
  }

  Future<({List<Map<String, String>> assignments, List<Map<String, String>> schedule})>
  _loadRemoteTeachingData() async {
    try {
      final profile = await _staffService.getProfile();
      final staffId = profile['staffId']?.toString().trim() ?? '';
      if (staffId.isEmpty) {
        return (assignments: <Map<String, String>>[], schedule: <Map<String, String>>[]);
      }
      final data = await _adminService.getTeacherTimetable(staffId: staffId);
      final rawItems = data['items'];
      if (rawItems is! List) {
        return (assignments: <Map<String, String>>[], schedule: <Map<String, String>>[]);
      }

      final assignments = <String, Map<String, String>>{};
      final schedule = <Map<String, String>>[];

      for (final raw in rawItems.whereType<Map>()) {
        final item = raw.cast<String, dynamic>();
        final classRoom = item['classRoom'] as Map<String, dynamic>? ?? const {};
        final subject = item['subject'] as Map<String, dynamic>? ?? const {};
        final className = _firstText([classRoom['name'], item['className']]);
        final section = _firstText([classRoom['section'], item['section']]);
        final classLabel = section.isEmpty ? className : '$className-$section';
        final subjectName = _firstText([subject['name'], item['title'], 'Class']);
        final teacherName = _firstText([profile['name'], 'Current Staff']);

        final assignmentId = '$classLabel|$subjectName';
        assignments[assignmentId] = {
          'id': assignmentId,
          'className': classLabel,
          'subject': subjectName,
          'teacher': teacherName,
        };

        final startsAt = DateTime.tryParse(item['startsAt']?.toString() ?? '');
        final endsAt = DateTime.tryParse(item['endsAt']?.toString() ?? '');
        schedule.add({
          'id': _firstText([item['id'], assignmentId]),
          'className': classLabel,
          'day': startsAt == null ? '' : _weekdayName(startsAt.toLocal().weekday),
          'period': _formatTimeRange(startsAt, endsAt),
          'subject': subjectName,
        });
      }

      return (
        assignments: assignments.values.toList(growable: false),
        schedule: schedule,
      );
    } catch (_) {
      return (assignments: <Map<String, String>>[], schedule: <Map<String, String>>[]);
    }
  }

  Future<List<Map<String, String>>> _loadCollection(String key) async {
    final rows = await _store.readCollection('classTeaching', key);
    return rows.map((row) {
      return row.map(
        (entryKey, value) => MapEntry(entryKey, value?.toString() ?? ''),
      );
    }).toList(growable: false);
  }

  List<Map<String, String>> _mergeRows(
    List<Map<String, String>> remote,
    List<Map<String, String>> local,
  ) {
    final merged = <String, Map<String, String>>{};
    for (final item in remote) {
      final id = item['id'] ?? '';
      if (id.isNotEmpty) {
        merged[id] = item;
      }
    }
    for (final item in local) {
      final id = item['id'] ?? '';
      if (id.isNotEmpty) {
        merged[id] = item;
      } else {
        merged['local-${merged.length}'] = item;
      }
    }
    return merged.values.toList(growable: false);
  }

  ({String first, String last}) _splitName(String value) {
    final parts = value
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return (first: 'Student', last: '');
    }
    if (parts.length == 1) {
      return (first: parts.first, last: '');
    }
    return (first: parts.first, last: parts.sublist(1).join(' '));
  }

  ({String className, String? section}) _splitClassLabel(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return (className: 'Class 1', section: null);
    }
    final dashParts = trimmed.split('-');
    if (dashParts.length >= 2) {
      return (
        className: dashParts.first.trim(),
        section: dashParts.last.trim().isEmpty ? null : dashParts.last.trim(),
      );
    }
    return (className: trimmed, section: null);
  }

  String _fullName(dynamic first, dynamic last) {
    return [
      first?.toString().trim() ?? '',
      last?.toString().trim() ?? '',
    ].where((part) => part.isNotEmpty).join(' ');
  }

  String _firstText(List<dynamic> values) {
    for (final value in values) {
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  String _weekdayName(int weekday) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    if (weekday < 1 || weekday > 7) {
      return '';
    }
    return names[weekday - 1];
  }

  String _formatTimeRange(DateTime? start, DateTime? end) {
    if (start == null) {
      return '';
    }
    final startText = _formatTime(start.toLocal());
    if (end == null) {
      return startText;
    }
    return '$startText-${_formatTime(end.toLocal())}';
  }

  String _formatTime(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final suffix = value.hour >= 12 ? 'PM' : 'AM';
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute $suffix';
  }
}
