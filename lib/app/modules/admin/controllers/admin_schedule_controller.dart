import 'package:erp_frontend/app/modules/admin/models/admin_class_option.dart';
import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminScheduleSessionRecord {
  const AdminScheduleSessionRecord({
    required this.id,
    required this.title,
    required this.classId,
    required this.className,
    required this.section,
    required this.subjectId,
    required this.subjectName,
    required this.subjectCode,
    required this.teacherId,
    required this.teacherName,
    required this.platform,
    required this.joinUrl,
    required this.status,
    required this.startsAt,
    required this.endsAt,
  });

  final String id;
  final String title;
  final String classId;
  final String className;
  final String section;
  final String subjectId;
  final String subjectName;
  final String subjectCode;
  final String teacherId;
  final String teacherName;
  final String platform;
  final String joinUrl;
  final String status;
  final DateTime? startsAt;
  final DateTime? endsAt;

  String get classLabel =>
      section.trim().isEmpty ? className : '$className - $section';

  String get subjectLabel =>
      subjectCode.trim().isEmpty ? subjectName : '$subjectName | $subjectCode';

  factory AdminScheduleSessionRecord.fromJson(Map<String, dynamic> json) {
    final classRoom =
        json['classRoom'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final subject =
        json['subject'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final teacher =
        json['teacher'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    return AdminScheduleSessionRecord(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      classId: json['classId']?.toString() ?? classRoom['id']?.toString() ?? '',
      className:
          classRoom['name']?.toString() ?? json['className']?.toString() ?? '',
      section:
          classRoom['section']?.toString() ?? json['section']?.toString() ?? '',
      subjectId:
          json['subjectId']?.toString() ?? subject['id']?.toString() ?? '',
      subjectName:
          subject['name']?.toString() ?? json['subjectName']?.toString() ?? '',
      subjectCode:
          subject['code']?.toString() ?? json['subjectCode']?.toString() ?? '',
      teacherId:
          json['teacherId']?.toString() ?? teacher['id']?.toString() ?? '',
      teacherName:
          teacher['fullName']?.toString() ??
          json['teacherName']?.toString() ??
          '',
      platform: json['platform']?.toString() ?? '',
      joinUrl: json['joinUrl']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      startsAt: _parseDate(json['startsAt']),
      endsAt: _parseDate(json['endsAt']),
    );
  }
}

class AdminExamRecord {
  const AdminExamRecord({
    required this.id,
    required this.name,
    required this.classId,
    required this.className,
    required this.section,
    required this.subjectId,
    required this.subjectName,
    required this.subjectCode,
    required this.maxMarks,
    required this.status,
    required this.isPublished,
    required this.resultsCount,
    required this.examDate,
  });

  final String id;
  final String name;
  final String classId;
  final String className;
  final String section;
  final String subjectId;
  final String subjectName;
  final String subjectCode;
  final double maxMarks;
  final String status;
  final bool isPublished;
  final int resultsCount;
  final DateTime? examDate;

  String get classLabel =>
      section.trim().isEmpty ? className : '$className - $section';

  String get subjectLabel =>
      subjectCode.trim().isEmpty ? subjectName : '$subjectName | $subjectCode';

  factory AdminExamRecord.fromJson(Map<String, dynamic> json) {
    final classRoom =
        json['classRoom'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final subject =
        json['subject'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final counts =
        json['_count'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    return AdminExamRecord(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      classId: json['classId']?.toString() ?? classRoom['id']?.toString() ?? '',
      className:
          classRoom['name']?.toString() ?? json['className']?.toString() ?? '',
      section:
          classRoom['section']?.toString() ?? json['section']?.toString() ?? '',
      subjectId:
          json['subjectId']?.toString() ?? subject['id']?.toString() ?? '',
      subjectName:
          subject['name']?.toString() ?? json['subjectName']?.toString() ?? '',
      subjectCode:
          subject['code']?.toString() ?? json['subjectCode']?.toString() ?? '',
      maxMarks: (json['maxMarks'] as num?)?.toDouble() ?? 0,
      status: json['status']?.toString() ?? 'DRAFT',
      isPublished: json['isPublished'] == true,
      resultsCount: (counts['results'] as num?)?.toInt() ?? 0,
      examDate: _parseDate(json['examDate']),
    );
  }
}

class AdminScheduleController extends GetxController {
  AdminScheduleController(this._adminService);

  final AdminService _adminService;

  final currentTab = 0.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final timetableSlots = <AdminScheduleSessionRecord>[].obs;
  final liveSessions = <AdminScheduleSessionRecord>[].obs;
  final exams = <AdminExamRecord>[].obs;
  final classOptions = <AdminClassOption>[].obs;
  final subjectOptions = <Map<String, String>>[].obs;
  final staffOptions = <Map<String, String>>[].obs;

  bool _scheduleLoaded = false;
  bool _examLoaded = false;

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments as Map?)?.cast<String, dynamic>() ?? const {};
    currentTab.value = _clampTab((args['initialTab'] as num?)?.toInt() ?? 0);
    loadSupportOptions();
    loadCurrentTab(force: true);
  }

  Future<void> loadSupportOptions() async {
    try {
      final results = await Future.wait([
        _adminService.getClasses(page: 1, limit: 100),
        _adminService.getSubjects(page: 1, limit: 100),
        _adminService.getStaff(page: 1, limit: 100),
      ]);
      final rawClasses = results[0]['items'];
      final rawSubjects = results[1]['items'];
      final rawStaff = results[2]['items'];

      if (rawClasses is List) {
        classOptions.assignAll(
          rawClasses
              .whereType<Map>()
              .map(
                (item) =>
                    AdminClassOption.fromJson(item.cast<String, dynamic>()),
              )
              .where((item) => item.id.isNotEmpty)
              .toList(),
        );
      }

      if (rawSubjects is List) {
        subjectOptions.assignAll(
          rawSubjects
              .whereType<Map>()
              .map((item) {
                final json = item.cast<String, dynamic>();
                return <String, String>{
                  'id': json['id']?.toString() ?? '',
                  'name': json['name']?.toString() ?? '',
                  'code': json['code']?.toString() ?? '',
                };
              })
              .where((item) => item['id']!.isNotEmpty)
              .toList(),
        );
      }

      if (rawStaff is List) {
        staffOptions.assignAll(
          rawStaff
              .whereType<Map>()
              .map((item) {
                final json = item.cast<String, dynamic>();
                return <String, String>{
                  'id': json['id']?.toString() ?? '',
                  'fullName': json['fullName']?.toString() ?? '',
                  'employeeCode': json['employeeCode']?.toString() ?? '',
                };
              })
              .where((item) => item['id']!.isNotEmpty)
              .toList(),
        );
      }
    } catch (_) {
      classOptions.clear();
      subjectOptions.clear();
      staffOptions.clear();
    }
  }

  Future<void> changeTab(int index) async {
    currentTab.value = _clampTab(index);
    await loadCurrentTab();
  }

  Future<void> refreshCurrentTab() async {
    await loadCurrentTab(force: true);
  }

  Future<void> loadCurrentTab({bool force = false}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      if (currentTab.value == 0) {
        if (force || !_scheduleLoaded) {
          await Future.wait([loadTimetableSlots(), loadLiveSessions()]);
          _scheduleLoaded = true;
        }
      } else {
        if (force || !_examLoaded) {
          await loadExams();
          _examLoaded = true;
        }
      }
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      AppToast.show(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadTimetableSlots() async {
    final data = await _adminService.getTimetable();
    final rawItems = data['items'];
    if (rawItems is! List) {
      timetableSlots.clear();
      return;
    }
    timetableSlots.assignAll(
      rawItems
          .whereType<Map>()
          .map(
            (item) => AdminScheduleSessionRecord.fromJson(
              item.cast<String, dynamic>(),
            ),
          )
          .toList(),
    );
  }

  Future<void> loadLiveSessions() async {
    final data = await _adminService.getLiveClassSessions(page: 1, limit: 50);
    final rawItems = data['items'];
    if (rawItems is! List) {
      liveSessions.clear();
      return;
    }
    liveSessions.assignAll(
      rawItems
          .whereType<Map>()
          .map(
            (item) => AdminScheduleSessionRecord.fromJson(
              item.cast<String, dynamic>(),
            ),
          )
          .toList(),
    );
  }

  Future<void> loadExams() async {
    final data = await _adminService.getExams(page: 1, limit: 50);
    final rawItems = data['items'];
    if (rawItems is! List) {
      exams.clear();
      return;
    }
    exams.assignAll(
      rawItems
          .whereType<Map>()
          .map((item) => AdminExamRecord.fromJson(item.cast<String, dynamic>()))
          .toList(),
    );
  }

  Future<void> openTimetableDialog({
    AdminScheduleSessionRecord? existing,
  }) async {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final platformController = TextEditingController(
      text: existing?.platform ?? '',
    );
    final joinUrlController = TextEditingController(
      text: existing?.joinUrl ?? '',
    );
    final startsAtController = TextEditingController(
      text: _formatDateTimeInput(existing?.startsAt),
    );
    final endsAtController = TextEditingController(
      text: _formatDateTimeInput(existing?.endsAt),
    );
    String classId = existing?.classId ?? '';
    String subjectId = existing?.subjectId ?? '';
    String teacherId = existing?.teacherId ?? '';

    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return _buildSessionDialog(
            title: existing == null ? 'Add Timetable Slot' : 'Edit Slot',
            titleController: titleController,
            platformController: platformController,
            joinUrlController: joinUrlController,
            startsAtController: startsAtController,
            endsAtController: endsAtController,
            classId: classId,
            subjectId: subjectId,
            teacherId: teacherId,
            onClassChanged: (value) => setState(() => classId = value ?? ''),
            onSubjectChanged: (value) =>
                setState(() => subjectId = value ?? ''),
            onTeacherChanged: (value) =>
                setState(() => teacherId = value ?? ''),
            saveLabel: existing == null ? 'Create' : 'Save',
          );
        },
      ),
    );

    if (ok != true) return;
    final startsAt = _parseUserDateTime(startsAtController.text);
    final endsAt = _parseUserDateTime(endsAtController.text);
    if (titleController.text.trim().isEmpty || startsAt == null) {
      AppToast.show('Title and valid start time are required.');
      return;
    }

    try {
      final payload = _buildSessionPayload(
        title: titleController.text.trim(),
        classId: classId,
        subjectId: subjectId,
        teacherId: teacherId,
        platform: platformController.text.trim(),
        joinUrl: joinUrlController.text.trim(),
        startsAt: startsAt,
        endsAt: endsAt,
      );
      if (existing == null) {
        await _adminService.createTimetableSlot(payload: payload);
        AppToast.show('Timetable slot created.');
      } else {
        await _adminService.updateTimetableSlot(
          id: existing.id,
          payload: payload,
        );
        AppToast.show('Timetable slot updated.');
      }
      await Future.wait([loadTimetableSlots(), loadLiveSessions()]);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> deleteTimetableSlot(AdminScheduleSessionRecord item) async {
    final confirmed = await _confirm(
      title: 'Delete Slot',
      message: 'Delete ${item.title}?',
    );
    if (!confirmed) return;
    try {
      await _adminService.deleteTimetableSlot(item.id);
      AppToast.show('Timetable slot deleted.');
      await loadTimetableSlots();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> publishTimetable() async {
    try {
      await _adminService.publishTimetable();
      AppToast.show('Timetable published.');
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> openLiveSessionDialog({
    AdminScheduleSessionRecord? existing,
  }) async {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final platformController = TextEditingController(
      text: existing?.platform ?? '',
    );
    final joinUrlController = TextEditingController(
      text: existing?.joinUrl ?? '',
    );
    final startsAtController = TextEditingController(
      text: _formatDateTimeInput(existing?.startsAt),
    );
    final endsAtController = TextEditingController(
      text: _formatDateTimeInput(existing?.endsAt),
    );
    String classId = existing?.classId ?? '';
    String subjectId = existing?.subjectId ?? '';
    String teacherId = existing?.teacherId ?? '';
    String status = existing?.status.isEmpty == false
        ? existing!.status
        : 'UPCOMING';

    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(existing == null ? 'Add Live Session' : 'Edit Session'),
            content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _sessionFormFields(
                      titleController: titleController,
                      platformController: platformController,
                      joinUrlController: joinUrlController,
                      startsAtController: startsAtController,
                      endsAtController: endsAtController,
                      classId: classId,
                      subjectId: subjectId,
                      teacherId: teacherId,
                      onClassChanged: (value) =>
                          setState(() => classId = value ?? ''),
                      onSubjectChanged: (value) =>
                          setState(() => subjectId = value ?? ''),
                      onTeacherChanged: (value) =>
                          setState(() => teacherId = value ?? ''),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: const ['UPCOMING', 'LIVE', 'ENDED']
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => status = value ?? 'UPCOMING'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: Text(existing == null ? 'Create' : 'Save'),
              ),
            ],
          );
        },
      ),
    );

    if (ok != true) return;
    final startsAt = _parseUserDateTime(startsAtController.text);
    final endsAt = _parseUserDateTime(endsAtController.text);
    if (titleController.text.trim().isEmpty || startsAt == null) {
      AppToast.show('Title and valid start time are required.');
      return;
    }

    try {
      final payload = _buildSessionPayload(
        title: titleController.text.trim(),
        classId: classId,
        subjectId: subjectId,
        teacherId: teacherId,
        platform: platformController.text.trim(),
        joinUrl: joinUrlController.text.trim(),
        startsAt: startsAt,
        endsAt: endsAt,
        status: status,
      );
      if (existing == null) {
        await _adminService.createLiveClassSession(payload);
        AppToast.show('Live session created.');
      } else {
        await _adminService.updateLiveClassSession(
          id: existing.id,
          payload: payload,
        );
        AppToast.show('Live session updated.');
      }
      await loadLiveSessions();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> endLiveSession(AdminScheduleSessionRecord item) async {
    try {
      await _adminService.endLiveClassSession(item.id);
      AppToast.show('Live session ended.');
      await loadLiveSessions();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> openExamDialog({AdminExamRecord? existing}) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final maxMarksController = TextEditingController(
      text: existing == null ? '100' : existing.maxMarks.toStringAsFixed(0),
    );
    final examDateController = TextEditingController(
      text: _formatDateInput(existing?.examDate),
    );
    String classId = existing?.classId ?? '';
    String subjectId = existing?.subjectId ?? '';
    String status = existing?.status ?? 'DRAFT';
    bool isPublished = existing?.isPublished ?? false;

    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(existing == null ? 'Create Exam' : 'Edit Exam'),
            content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Exam name'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: classId,
                      decoration: const InputDecoration(labelText: 'Class'),
                      items: [
                        const DropdownMenuItem<String>(
                          value: '',
                          child: Text('No class'),
                        ),
                        ...classOptions.map(
                          (item) => DropdownMenuItem<String>(
                            value: item.id,
                            child: Text(item.label),
                          ),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => classId = value ?? ''),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: subjectId,
                      decoration: const InputDecoration(labelText: 'Subject'),
                      items: [
                        const DropdownMenuItem<String>(
                          value: '',
                          child: Text('No subject'),
                        ),
                        ...subjectOptions.map(
                          (item) => DropdownMenuItem<String>(
                            value: item['id'],
                            child: Text(_subjectLabel(item)),
                          ),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => subjectId = value ?? ''),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: examDateController,
                      decoration: const InputDecoration(
                        labelText: 'Exam date',
                        helperText: 'YYYY-MM-DD',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: maxMarksController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Max marks'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items:
                          const ['DRAFT', 'SCHEDULED', 'COMPLETED', 'PUBLISHED']
                              .map(
                                (item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                ),
                              )
                              .toList(),
                      onChanged: (value) =>
                          setState(() => status = value ?? 'DRAFT'),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: isPublished,
                      onChanged: (value) => setState(() => isPublished = value),
                      title: const Text('Published'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: Text(existing == null ? 'Create' : 'Save'),
              ),
            ],
          );
        },
      ),
    );

    if (ok != true) return;
    final examDate = _parseUserDate(examDateController.text);
    final maxMarks = double.tryParse(maxMarksController.text.trim());
    if (nameController.text.trim().isEmpty ||
        examDate == null ||
        maxMarks == null ||
        maxMarks <= 0) {
      AppToast.show('Name, valid date, and max marks are required.');
      return;
    }

    try {
      final payload = <String, dynamic>{
        'name': nameController.text.trim(),
        'classId': classId.isEmpty ? null : classId,
        'subjectId': subjectId.isEmpty ? null : subjectId,
        'examDate': examDate.toIso8601String(),
        'maxMarks': maxMarks,
        'status': status,
        'isPublished': isPublished,
      };
      if (existing == null) {
        await _adminService.createExam(payload);
        AppToast.show('Exam created.');
      } else {
        await _adminService.updateExam(id: existing.id, payload: payload);
        AppToast.show('Exam updated.');
      }
      await loadExams();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> deleteExam(AdminExamRecord item) async {
    final confirmed = await _confirm(
      title: 'Delete Exam',
      message: 'Delete ${item.name}?',
    );
    if (!confirmed) return;
    try {
      await _adminService.deleteExam(item.id);
      AppToast.show('Exam deleted.');
      await loadExams();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> publishExam(AdminExamRecord item) async {
    try {
      await _adminService.publishExam(item.id);
      AppToast.show('Exam published.');
      await loadExams();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> openMarksStatus(AdminExamRecord item) async {
    try {
      final data = await _adminService.getExamMarksStatus(item.id);
      final marksStatus =
          data['marksStatus'] as Map<String, dynamic>? ??
          const <String, dynamic>{};
      final totalExpected =
          (marksStatus['totalExpected'] as num?)?.toInt() ?? 0;
      final entered = (marksStatus['entered'] as num?)?.toInt() ?? 0;
      final missing = (marksStatus['missing'] as num?)?.toInt() ?? 0;
      await Get.dialog<void>(
        AlertDialog(
          title: Text(item.name),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Expected students: $totalExpected'),
                Text('Marks entered: $entered'),
                Text('Pending marks: $missing'),
                const SizedBox(height: 10),
                Text('Published: ${item.isPublished ? 'Yes' : 'No'}'),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Close')),
            FilledButton(
              onPressed: () {
                Get.back();
                openMarksEntryDialog(item);
              },
              child: const Text('Enter Marks'),
            ),
          ],
        ),
      );
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> openMarksEntryDialog(AdminExamRecord exam) async {
    if (exam.className.trim().isEmpty) {
      AppToast.show('Assign a class to this exam before entering marks.');
      return;
    }
    try {
      final results = await Future.wait([
        _adminService.getExamMarksStatus(exam.id),
        _adminService.getStudents(
          page: 1,
          limit: 100,
          status: 'ACTIVE',
          className: exam.className,
          section: exam.section.trim().isEmpty ? null : exam.section,
        ),
      ]);
      final existingResultsRaw = results[0]['results'];
      final studentsRaw = results[1]['items'];
      if (studentsRaw is! List || studentsRaw.isEmpty) {
        AppToast.show('No active students found for this exam class.');
        return;
      }

      final existingMarks = <String, String>{};
      final existingGrades = <String, String>{};
      if (existingResultsRaw is List) {
        for (final item in existingResultsRaw.whereType<Map>()) {
          final json = item.cast<String, dynamic>();
          final studentId = json['studentId']?.toString() ?? '';
          if (studentId.isEmpty) continue;
          existingMarks[studentId] = json['marks']?.toString() ?? '';
          existingGrades[studentId] = json['grade']?.toString() ?? '';
        }
      }

      final students = studentsRaw
          .whereType<Map>()
          .map((item) {
            final json = item.cast<String, dynamic>();
            return <String, String>{
              'id': json['id']?.toString() ?? '',
              'name':
                  '${json['firstName']?.toString() ?? ''} ${json['lastName']?.toString() ?? ''}'
                      .trim(),
              'admissionNo': json['admissionNo']?.toString() ?? '',
            };
          })
          .where((item) => item['id']!.isNotEmpty)
          .toList();

      final markControllers = <String, TextEditingController>{};
      final gradeControllers = <String, TextEditingController>{};
      for (final student in students) {
        final id = student['id']!;
        markControllers[id] = TextEditingController(
          text: existingMarks[id] ?? '',
        );
        gradeControllers[id] = TextEditingController(
          text: existingGrades[id] ?? '',
        );
      }

      final ok = await Get.dialog<bool>(
        AlertDialog(
          title: Text('Marks Entry | ${exam.name}'),
          content: SizedBox(
            width: 620,
            height: 420,
            child: ListView.separated(
              itemCount: students.length,
              separatorBuilder: (_, __) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final student = students[index];
                final id = student['id']!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student['name']!.isEmpty
                          ? student['admissionNo']!
                          : student['name']!,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    if (student['admissionNo']!.isNotEmpty)
                      Text(
                        student['admissionNo']!,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: markControllers[id],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Marks',
                              helperText: 'Out of ${exam.maxMarks.toInt()}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: gradeControllers[id],
                            decoration: const InputDecoration(
                              labelText: 'Grade',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Save Marks'),
            ),
          ],
        ),
      );

      if (ok != true) return;
      final payload = <Map<String, dynamic>>[];
      for (final student in students) {
        final id = student['id']!;
        final marksText = markControllers[id]!.text.trim();
        if (marksText.isEmpty) continue;
        final marks = double.tryParse(marksText);
        if (marks == null || marks < 0 || marks > exam.maxMarks) {
          AppToast.show('Enter valid marks for ${student['name']}.');
          return;
        }
        payload.add({
          'studentId': id,
          'marks': marks,
          if (gradeControllers[id]!.text.trim().isNotEmpty)
            'grade': gradeControllers[id]!.text.trim(),
        });
      }
      if (payload.isEmpty) {
        AppToast.show('Enter marks for at least one student.');
        return;
      }
      await _adminService.saveExamMarks(id: exam.id, results: payload);
      AppToast.show('Exam marks saved.');
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<bool> _confirm({
    required String title,
    required String message,
  }) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Map<String, dynamic> _buildSessionPayload({
    required String title,
    required String classId,
    required String subjectId,
    required String teacherId,
    required String platform,
    required String joinUrl,
    required DateTime startsAt,
    DateTime? endsAt,
    String? status,
  }) {
    return <String, dynamic>{
      'title': title,
      'classId': classId.isEmpty ? null : classId,
      'subjectId': subjectId.isEmpty ? null : subjectId,
      'teacherId': teacherId.isEmpty ? null : teacherId,
      'platform': platform.isEmpty ? null : platform,
      'joinUrl': joinUrl.isEmpty ? null : joinUrl,
      'startsAt': startsAt.toIso8601String(),
      'endsAt': endsAt?.toIso8601String(),
      if (status != null && status.isNotEmpty) 'status': status,
    };
  }

  Widget _buildSessionDialog({
    required String title,
    required TextEditingController titleController,
    required TextEditingController platformController,
    required TextEditingController joinUrlController,
    required TextEditingController startsAtController,
    required TextEditingController endsAtController,
    required String classId,
    required String subjectId,
    required String teacherId,
    required ValueChanged<String?> onClassChanged,
    required ValueChanged<String?> onSubjectChanged,
    required ValueChanged<String?> onTeacherChanged,
    required String saveLabel,
  }) {
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: _sessionFormFields(
            titleController: titleController,
            platformController: platformController,
            joinUrlController: joinUrlController,
            startsAtController: startsAtController,
            endsAtController: endsAtController,
            classId: classId,
            subjectId: subjectId,
            teacherId: teacherId,
            onClassChanged: onClassChanged,
            onSubjectChanged: onSubjectChanged,
            onTeacherChanged: onTeacherChanged,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Get.back(result: true),
          child: Text(saveLabel),
        ),
      ],
    );
  }

  Widget _sessionFormFields({
    required TextEditingController titleController,
    required TextEditingController platformController,
    required TextEditingController joinUrlController,
    required TextEditingController startsAtController,
    required TextEditingController endsAtController,
    required String classId,
    required String subjectId,
    required String teacherId,
    required ValueChanged<String?> onClassChanged,
    required ValueChanged<String?> onSubjectChanged,
    required ValueChanged<String?> onTeacherChanged,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: classId,
          decoration: const InputDecoration(labelText: 'Class'),
          items: [
            const DropdownMenuItem<String>(value: '', child: Text('No class')),
            ...classOptions.map(
              (item) => DropdownMenuItem<String>(
                value: item.id,
                child: Text(item.label),
              ),
            ),
          ],
          onChanged: onClassChanged,
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: subjectId,
          decoration: const InputDecoration(labelText: 'Subject'),
          items: [
            const DropdownMenuItem<String>(
              value: '',
              child: Text('No subject'),
            ),
            ...subjectOptions.map(
              (item) => DropdownMenuItem<String>(
                value: item['id'],
                child: Text(_subjectLabel(item)),
              ),
            ),
          ],
          onChanged: onSubjectChanged,
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: teacherId,
          decoration: const InputDecoration(labelText: 'Teacher'),
          items: [
            const DropdownMenuItem<String>(
              value: '',
              child: Text('No teacher'),
            ),
            ...staffOptions.map(
              (item) => DropdownMenuItem<String>(
                value: item['id'],
                child: Text(_staffLabel(item)),
              ),
            ),
          ],
          onChanged: onTeacherChanged,
        ),
        const SizedBox(height: 10),
        TextField(
          controller: platformController,
          decoration: const InputDecoration(labelText: 'Platform'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: joinUrlController,
          decoration: const InputDecoration(labelText: 'Join URL'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: startsAtController,
          decoration: const InputDecoration(
            labelText: 'Starts at',
            helperText: 'YYYY-MM-DD HH:MM',
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: endsAtController,
          decoration: const InputDecoration(
            labelText: 'Ends at',
            helperText: 'YYYY-MM-DD HH:MM',
          ),
        ),
      ],
    );
  }

  int _clampTab(int value) {
    if (value < 0) return 0;
    if (value > 1) return 1;
    return value;
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

DateTime? _parseUserDate(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text);
}

DateTime? _parseUserDateTime(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return null;
  return DateTime.tryParse(
    text.contains('T') ? text : text.replaceFirst(' ', 'T'),
  );
}

String _formatDateInput(DateTime? value) {
  if (value == null) return '';
  return value.toIso8601String().substring(0, 10);
}

String _formatDateTimeInput(DateTime? value) {
  if (value == null) return '';
  return value.toIso8601String().substring(0, 16).replaceFirst('T', ' ');
}

String _subjectLabel(Map<String, String> item) {
  final name = item['name'] ?? '';
  final code = item['code'] ?? '';
  return code.trim().isEmpty ? name : '$name | $code';
}

String _staffLabel(Map<String, String> item) {
  final fullName = item['fullName'] ?? '';
  final employeeCode = item['employeeCode'] ?? '';
  return employeeCode.trim().isEmpty ? fullName : '$fullName | $employeeCode';
}
