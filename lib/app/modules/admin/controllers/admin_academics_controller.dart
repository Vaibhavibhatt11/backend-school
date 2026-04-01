import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminAcademicStaffOption {
  const AdminAcademicStaffOption({
    required this.id,
    required this.fullName,
    required this.employeeCode,
  });

  final String id;
  final String fullName;
  final String employeeCode;

  String get label =>
      employeeCode.isEmpty ? fullName : '$fullName | $employeeCode';

  factory AdminAcademicStaffOption.fromJson(Map<String, dynamic> json) {
    return AdminAcademicStaffOption(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      employeeCode: json['employeeCode']?.toString() ?? '',
    );
  }
}

class AdminClassRecord {
  const AdminClassRecord({
    required this.id,
    required this.name,
    required this.section,
    required this.capacity,
    required this.studentsCount,
    required this.classTeacherId,
    required this.classTeacherName,
  });

  final String id;
  final String name;
  final String section;
  final int? capacity;
  final int studentsCount;
  final String classTeacherId;
  final String classTeacherName;

  String get label => '$name - $section';

  factory AdminClassRecord.fromJson(Map<String, dynamic> json) {
    final count = json['_count'] as Map<String, dynamic>? ?? const {};
    final teacher = json['classTeacher'] as Map<String, dynamic>? ?? const {};
    return AdminClassRecord(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      section: json['section']?.toString() ?? '',
      capacity: (json['capacity'] as num?)?.toInt(),
      studentsCount: (count['students'] as num?)?.toInt() ?? 0,
      classTeacherId: teacher['id']?.toString() ?? '',
      classTeacherName: teacher['fullName']?.toString() ?? '',
    );
  }
}

class AdminSubjectRecord {
  const AdminSubjectRecord({
    required this.id,
    required this.name,
    required this.code,
    required this.isActive,
  });

  final String id;
  final String name;
  final String code;
  final bool isActive;

  factory AdminSubjectRecord.fromJson(Map<String, dynamic> json) {
    return AdminSubjectRecord(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      isActive: json['isActive'] != false,
    );
  }
}

class AdminAcademicsController extends GetxController {
  AdminAcademicsController(this._adminService);

  final AdminService _adminService;

  final classes = <AdminClassRecord>[].obs;
  final subjects = <AdminSubjectRecord>[].obs;
  final staffOptions = <AdminAcademicStaffOption>[].obs;

  final isClassesLoading = false.obs;
  final isSubjectsLoading = false.obs;
  final classesError = ''.obs;
  final subjectsError = ''.obs;

  final classesSearchText = ''.obs;
  final subjectsSearchText = ''.obs;
  final classesSearchController = TextEditingController();
  final subjectsSearchController = TextEditingController();

  final classesPage = 1.obs;
  final classesTotalPages = 1.obs;
  final classesTotalItems = 0.obs;
  final subjectsPage = 1.obs;
  final subjectsTotalPages = 1.obs;
  final subjectsTotalItems = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  @override
  void onClose() {
    classesSearchController.dispose();
    subjectsSearchController.dispose();
    super.onClose();
  }

  Future<void> loadInitialData() async {
    await Future.wait([loadClasses(), loadSubjects(), loadStaffOptions()]);
  }

  Future<void> loadStaffOptions() async {
    try {
      final data = await _adminService.getStaff(page: 1, limit: 100);
      final rawItems = data['items'];
      if (rawItems is! List) {
        staffOptions.clear();
        return;
      }
      staffOptions.assignAll(
        rawItems
            .whereType<Map>()
            .map(
              (item) => AdminAcademicStaffOption.fromJson(
                item.cast<String, dynamic>(),
              ),
            )
            .where((item) => item.id.isNotEmpty)
            .toList(),
      );
    } catch (_) {
      staffOptions.clear();
    }
  }

  Future<void> loadClasses({int nextPage = 1}) async {
    isClassesLoading.value = true;
    classesError.value = '';
    try {
      final data = await _adminService.getClasses(
        page: nextPage,
        limit: 20,
        search: classesSearchText.value.trim().isEmpty
            ? null
            : classesSearchText.value.trim(),
      );
      final rawItems = data['items'];
      final pagination =
          data['pagination'] as Map<String, dynamic>? ?? const {};
      if (rawItems is List) {
        classes.assignAll(
          rawItems
              .whereType<Map>()
              .map(
                (item) =>
                    AdminClassRecord.fromJson(item.cast<String, dynamic>()),
              )
              .toList(),
        );
      } else {
        classes.clear();
      }
      classesTotalItems.value =
          (pagination['total'] as num?)?.toInt() ?? classes.length;
      classesPage.value = (pagination['page'] as num?)?.toInt() ?? nextPage;
      classesTotalPages.value =
          (pagination['totalPages'] as num?)?.toInt() ?? 1;
    } catch (e) {
      classesError.value = dioOrApiErrorMessage(e);
      classes.clear();
      classesTotalItems.value = 0;
      AppToast.show(classesError.value);
    } finally {
      isClassesLoading.value = false;
    }
  }

  Future<void> loadSubjects({int nextPage = 1}) async {
    isSubjectsLoading.value = true;
    subjectsError.value = '';
    try {
      final data = await _adminService.getSubjects(
        page: nextPage,
        limit: 20,
        search: subjectsSearchText.value.trim().isEmpty
            ? null
            : subjectsSearchText.value.trim(),
      );
      final rawItems = data['items'];
      final pagination =
          data['pagination'] as Map<String, dynamic>? ?? const {};
      if (rawItems is List) {
        subjects.assignAll(
          rawItems
              .whereType<Map>()
              .map(
                (item) =>
                    AdminSubjectRecord.fromJson(item.cast<String, dynamic>()),
              )
              .toList(),
        );
      } else {
        subjects.clear();
      }
      subjectsTotalItems.value =
          (pagination['total'] as num?)?.toInt() ?? subjects.length;
      subjectsPage.value = (pagination['page'] as num?)?.toInt() ?? nextPage;
      subjectsTotalPages.value =
          (pagination['totalPages'] as num?)?.toInt() ?? 1;
    } catch (e) {
      subjectsError.value = dioOrApiErrorMessage(e);
      subjects.clear();
      subjectsTotalItems.value = 0;
      AppToast.show(subjectsError.value);
    } finally {
      isSubjectsLoading.value = false;
    }
  }

  Future<void> searchClasses(String value) async {
    classesSearchText.value = value.trim();
    await loadClasses();
  }

  Future<void> searchSubjects(String value) async {
    subjectsSearchText.value = value.trim();
    await loadSubjects();
  }

  Future<void> openClassDialog({AdminClassRecord? existing}) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final sectionController = TextEditingController(
      text: existing?.section ?? '',
    );
    final capacityController = TextEditingController(
      text: existing?.capacity?.toString() ?? '',
    );
    String teacherId = existing?.classTeacherId ?? '';
    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(existing == null ? 'Add Class' : 'Edit Class'),
            content: SizedBox(
              width: 460,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Class name',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: sectionController,
                      decoration: const InputDecoration(labelText: 'Section'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: teacherId,
                      decoration: const InputDecoration(
                        labelText: 'Class teacher',
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: '',
                          child: Text('No class teacher'),
                        ),
                        ...staffOptions.map(
                          (staff) => DropdownMenuItem<String>(
                            value: staff.id,
                            child: Text(staff.label),
                          ),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => teacherId = value ?? ''),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: capacityController,
                      decoration: const InputDecoration(labelText: 'Capacity'),
                      keyboardType: TextInputType.number,
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
    if (nameController.text.trim().isEmpty ||
        sectionController.text.trim().isEmpty) {
      AppToast.show('Class name and section are required.');
      return;
    }
    final capacity = int.tryParse(capacityController.text.trim());
    try {
      if (existing == null) {
        await _adminService.createClass(
          name: nameController.text.trim(),
          section: sectionController.text.trim(),
          classTeacherId: teacherId,
          capacity: capacity,
        );
        AppToast.show('Class created.');
      } else {
        await _adminService.updateClass(
          id: existing.id,
          payload: {
            'name': nameController.text.trim(),
            'section': sectionController.text.trim(),
            'classTeacherId': teacherId.isEmpty ? null : teacherId,
            'capacity': capacityController.text.trim().isEmpty
                ? null
                : capacity,
          },
        );
        AppToast.show('Class updated.');
      }
      await loadClasses(nextPage: classesPage.value);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> deleteClass(AdminClassRecord item) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Class'),
        content: Text('Delete ${item.label}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _adminService.deleteClass(item.id);
      AppToast.show('Class deleted.');
      await loadClasses(nextPage: classesPage.value);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> openSubjectDialog({AdminSubjectRecord? existing}) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final codeController = TextEditingController(text: existing?.code ?? '');
    bool isActive = existing?.isActive ?? true;
    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(existing == null ? 'Add Subject' : 'Edit Subject'),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Subject name',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: codeController,
                      decoration: const InputDecoration(
                        labelText: 'Subject code',
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: isActive,
                      onChanged: (value) => setState(() => isActive = value),
                      title: const Text('Active'),
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
    if (nameController.text.trim().isEmpty ||
        codeController.text.trim().isEmpty) {
      AppToast.show('Subject name and code are required.');
      return;
    }
    try {
      if (existing == null) {
        await _adminService.createSubject(
          name: nameController.text.trim(),
          code: codeController.text.trim(),
          isActive: isActive,
        );
        AppToast.show('Subject created.');
      } else {
        await _adminService.updateSubject(
          id: existing.id,
          payload: {
            'name': nameController.text.trim(),
            'code': codeController.text.trim(),
            'isActive': isActive,
          },
        );
        AppToast.show('Subject updated.');
      }
      await loadSubjects(nextPage: subjectsPage.value);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> toggleSubjectActive(AdminSubjectRecord item) async {
    try {
      await _adminService.updateSubject(
        id: item.id,
        payload: {'isActive': !item.isActive},
      );
      AppToast.show(
        !item.isActive ? 'Subject activated.' : 'Subject deactivated.',
      );
      await loadSubjects(nextPage: subjectsPage.value);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> deleteSubject(AdminSubjectRecord item) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Subject'),
        content: Text('Delete ${item.name} (${item.code})?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _adminService.deleteSubject(item.id);
      AppToast.show('Subject deleted.');
      await loadSubjects(nextPage: subjectsPage.value);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }
}
