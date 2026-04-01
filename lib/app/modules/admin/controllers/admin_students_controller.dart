import 'package:erp_frontend/app/modules/admin/models/admin_class_option.dart';
import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminStudentRecord {
  const AdminStudentRecord({
    required this.id,
    required this.admissionNo,
    required this.firstName,
    required this.lastName,
    required this.classId,
    required this.className,
    required this.section,
    required this.rollNo,
    required this.status,
    required this.guardianPhone,
    required this.gender,
  });

  final String id;
  final String admissionNo;
  final String firstName;
  final String lastName;
  final String classId;
  final String className;
  final String section;
  final int? rollNo;
  final String status;
  final String guardianPhone;
  final String gender;

  String get fullName => '$firstName $lastName'.trim();
  String get classLabel =>
      section.isEmpty ? className : '$className - $section';

  factory AdminStudentRecord.fromJson(Map<String, dynamic> json) {
    return AdminStudentRecord(
      id: json['id']?.toString() ?? '',
      admissionNo: json['admissionNo']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      classId: json['classId']?.toString() ?? '',
      className: json['className']?.toString() ?? '',
      section: json['section']?.toString() ?? '',
      rollNo: (json['rollNo'] as num?)?.toInt(),
      status: json['status']?.toString() ?? 'ACTIVE',
      guardianPhone: json['guardianPhone']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
    );
  }
}

class AdminStudentsController extends GetxController {
  AdminStudentsController(this._adminService);

  final AdminService _adminService;

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final students = <AdminStudentRecord>[].obs;
  final classOptions = <AdminClassOption>[].obs;
  final selectedStatus = 'ALL'.obs;
  final selectedClassFilter = 'ALL_CLASSES'.obs;
  final searchText = ''.obs;
  final searchController = TextEditingController();
  final page = 1.obs;
  final totalPages = 1.obs;
  final totalItems = 0.obs;

  static const statusOptions = <String>['ALL', 'ACTIVE', 'INACTIVE'];

  @override
  void onInit() {
    super.onInit();
    searchController.text = searchText.value;
    loadInitialData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadInitialData() async {
    await loadClassOptions();
    await loadStudents();
  }

  Future<void> loadClassOptions() async {
    try {
      final data = await _adminService.getClasses(page: 1, limit: 100);
      final rawItems = data['items'];
      if (rawItems is! List) {
        classOptions.clear();
        return;
      }
      classOptions.assignAll(
        rawItems
            .whereType<Map>()
            .map(
              (item) => AdminClassOption.fromJson(item.cast<String, dynamic>()),
            )
            .where((item) => item.name.trim().isNotEmpty)
            .toList(),
      );
      if (selectedClassFilter.value != 'ALL_CLASSES' &&
          classOptions.every(
            (item) => item.label != selectedClassFilter.value,
          )) {
        selectedClassFilter.value = 'ALL_CLASSES';
      }
    } catch (_) {
      classOptions.clear();
      selectedClassFilter.value = 'ALL_CLASSES';
    }
  }

  Future<void> loadStudents({int nextPage = 1}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final classFilter = selectedClassFilter.value;
      final classOption = classOptions.firstWhereOrNull(
        (item) => item.label == classFilter,
      );
      final data = await _adminService.getStudents(
        page: nextPage,
        limit: 20,
        search: searchText.value.trim().isEmpty
            ? null
            : searchText.value.trim(),
        status: selectedStatus.value == 'ALL' ? null : selectedStatus.value,
        className: classOption?.name,
        section: classOption?.section.isEmpty == true
            ? null
            : classOption?.section,
      );
      final rawItems = data['items'];
      final pagination =
          data['pagination'] as Map<String, dynamic>? ??
          const <String, dynamic>{};
      if (rawItems is List) {
        students.assignAll(
          rawItems
              .whereType<Map>()
              .map(
                (item) =>
                    AdminStudentRecord.fromJson(item.cast<String, dynamic>()),
              )
              .toList(),
        );
      } else {
        students.clear();
      }
      totalItems.value =
          (pagination['total'] as num?)?.toInt() ?? students.length;
      page.value = (pagination['page'] as num?)?.toInt() ?? nextPage;
      totalPages.value = (pagination['totalPages'] as num?)?.toInt() ?? 1;
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      students.clear();
      totalItems.value = 0;
      AppToast.show(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changeStatusFilter(String status) async {
    selectedStatus.value = status;
    await loadStudents();
  }

  Future<void> changeClassFilter(String value) async {
    selectedClassFilter.value = value;
    await loadStudents();
  }

  Future<void> search(String value) async {
    searchText.value = value.trim();
    await loadStudents();
  }

  Future<void> openCreateDialog({AdminStudentRecord? existing}) async {
    if (classOptions.isEmpty) {
      AppToast.show('Create classes first, then add students.');
      return;
    }
    final admissionNoController = TextEditingController(
      text: existing?.admissionNo ?? '',
    );
    final firstNameController = TextEditingController(
      text: existing?.firstName ?? '',
    );
    final lastNameController = TextEditingController(
      text: existing?.lastName ?? '',
    );
    final guardianPhoneController = TextEditingController(
      text: existing?.guardianPhone ?? '',
    );
    final genderController = TextEditingController(
      text: existing?.gender ?? '',
    );
    final rollNoController = TextEditingController(
      text: existing?.rollNo?.toString() ?? '',
    );
    String status = existing?.status ?? 'ACTIVE';
    AdminClassOption? selectedClass =
        classOptions.firstWhereOrNull(
          (item) =>
              item.name == existing?.className &&
              item.section == existing?.section,
        ) ??
        (classOptions.isNotEmpty ? classOptions.first : null);
    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(existing == null ? 'Add Student' : 'Edit Student'),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: admissionNoController,
                      decoration: const InputDecoration(
                        labelText: 'Admission no',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First name',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: lastNameController,
                      decoration: const InputDecoration(labelText: 'Last name'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<AdminClassOption>(
                      initialValue: selectedClass,
                      decoration: const InputDecoration(labelText: 'Class'),
                      items: classOptions
                          .map(
                            (item) => DropdownMenuItem<AdminClassOption>(
                              value: item,
                              child: Text(item.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedClass = value),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: rollNoController,
                      decoration: const InputDecoration(labelText: 'Roll no'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: guardianPhoneController,
                      decoration: const InputDecoration(
                        labelText: 'Guardian phone',
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: genderController,
                      decoration: const InputDecoration(labelText: 'Gender'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: const ['ACTIVE', 'INACTIVE']
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => status = value ?? 'ACTIVE'),
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
    if (admissionNoController.text.trim().isEmpty ||
        firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty ||
        selectedClass == null) {
      AppToast.show('Admission no, names, and class are required.');
      return;
    }

    final rollNo = int.tryParse(rollNoController.text.trim());
    try {
      if (existing == null) {
        await _adminService.createStudent(
          admissionNo: admissionNoController.text.trim(),
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          className: selectedClass!.name,
          classId: selectedClass!.id,
          section: selectedClass!.section,
          rollNo: rollNo,
          guardianPhone: guardianPhoneController.text.trim(),
          gender: genderController.text.trim(),
          status: status,
        );
        AppToast.show('Student created.');
      } else {
        await _adminService.updateStudent(
          id: existing.id,
          payload: {
            'admissionNo': admissionNoController.text.trim(),
            'firstName': firstNameController.text.trim(),
            'lastName': lastNameController.text.trim(),
            'className': selectedClass!.name,
            'classId': selectedClass!.id,
            'section': selectedClass!.section.isEmpty
                ? null
                : selectedClass!.section,
            'rollNo': rollNo,
            'guardianPhone': guardianPhoneController.text.trim().isEmpty
                ? null
                : guardianPhoneController.text.trim(),
            'gender': genderController.text.trim().isEmpty
                ? null
                : genderController.text.trim(),
          },
        );
        if (existing.status != status) {
          await _adminService.updateStudentStatus(
            id: existing.id,
            status: status,
          );
        }
        AppToast.show('Student updated.');
      }
      await loadStudents(nextPage: page.value);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> openDetails(AdminStudentRecord item) async {
    try {
      final data = await _adminService.getStudentById(item.id);
      final student =
          data['student'] as Map<String, dynamic>? ?? const <String, dynamic>{};
      final className = student['className']?.toString() ?? item.className;
      final section = student['section']?.toString() ?? item.section;
      await Get.dialog<void>(
        AlertDialog(
          title: Text(item.fullName),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    student['admissionNo']?.toString() ?? item.admissionNo,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    section.trim().isEmpty
                        ? 'Class: $className'
                        : 'Class: $className - $section',
                  ),
                  Text('Status: ${student['status'] ?? item.status}'),
                  if ((student['rollNo']?.toString() ?? '').isNotEmpty)
                    Text('Roll no: ${student['rollNo']}'),
                  if ((student['gender']?.toString() ?? item.gender)
                      .trim()
                      .isNotEmpty)
                    Text('Gender: ${student['gender'] ?? item.gender}'),
                  if ((student['guardianPhone']?.toString() ??
                          item.guardianPhone)
                      .trim()
                      .isNotEmpty)
                    Text(
                      'Guardian phone: ${student['guardianPhone'] ?? item.guardianPhone}',
                    ),
                  if ((student['dob']?.toString() ?? '').isNotEmpty)
                    Text('DOB: ${student['dob'].toString().substring(0, 10)}'),
                  if ((student['createdAt']?.toString() ?? '').isNotEmpty)
                    Text(
                      'Created: ${student['createdAt'].toString().substring(0, 10)}',
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Close')),
          ],
        ),
      );
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> addDocument(AdminStudentRecord item) async {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    final typeController = TextEditingController(text: 'OTHER');
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Add Document for ${item.admissionNo}'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Document name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(labelText: 'Document URL'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(labelText: 'Type'),
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
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (nameController.text.trim().isEmpty ||
        urlController.text.trim().isEmpty) {
      AppToast.show('Document name and URL are required.');
      return;
    }
    try {
      await _adminService.addStudentDocument(
        id: item.id,
        name: nameController.text.trim(),
        url: urlController.text.trim(),
        type: typeController.text.trim(),
      );
      AppToast.show('Student document added.');
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> toggleStatus(AdminStudentRecord item) async {
    final nextStatus = item.status == 'ACTIVE' ? 'INACTIVE' : 'ACTIVE';
    try {
      await _adminService.updateStudentStatus(id: item.id, status: nextStatus);
      AppToast.show('Student status updated to $nextStatus.');
      await loadStudents(nextPage: page.value);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> moveClass(AdminStudentRecord item) async {
    if (classOptions.isEmpty) {
      AppToast.show('Create classes first, then move students.');
      return;
    }
    AdminClassOption? selectedClass =
        classOptions.firstWhereOrNull(
          (option) =>
              option.name == item.className && option.section == item.section,
        ) ??
        (classOptions.isNotEmpty ? classOptions.first : null);
    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Move ${item.fullName}'),
            content: SizedBox(
              width: 420,
              child: DropdownButtonFormField<AdminClassOption>(
                initialValue: selectedClass,
                decoration: const InputDecoration(labelText: 'New class'),
                items: classOptions
                    .map(
                      (option) => DropdownMenuItem<AdminClassOption>(
                        value: option,
                        child: Text(option.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => selectedClass = value),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Move'),
              ),
            ],
          );
        },
      ),
    );
    if (ok != true || selectedClass == null) return;
    try {
      await _adminService.moveStudentClass(
        id: item.id,
        className: selectedClass!.name,
        classId: selectedClass!.id,
        section: selectedClass!.section,
      );
      AppToast.show('Student moved to ${selectedClass!.label}.');
      await loadStudents(nextPage: page.value);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> deleteStudent(AdminStudentRecord item) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Delete ${item.fullName} (${item.admissionNo})?'),
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
      await _adminService.deleteStudent(item.id);
      AppToast.show('Student deleted.');
      await loadStudents(nextPage: page.value);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }
}
