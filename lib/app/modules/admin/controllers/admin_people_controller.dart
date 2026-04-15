import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminPeopleStudentOption {
  const AdminPeopleStudentOption({
    required this.id,
    required this.admissionNo,
    required this.fullName,
    required this.classLabel,
  });

  final String id;
  final String admissionNo;
  final String fullName;
  final String classLabel;

  String get label =>
      '$admissionNo | $fullName${classLabel.isEmpty ? '' : ' | $classLabel'}';

  factory AdminPeopleStudentOption.fromJson(Map<String, dynamic> json) {
    final className = json['className']?.toString() ?? '';
    final section = json['section']?.toString() ?? '';
    return AdminPeopleStudentOption(
      id: json['id']?.toString() ?? '',
      admissionNo: json['admissionNo']?.toString() ?? '',
      fullName:
          '${json['firstName']?.toString() ?? ''} ${json['lastName']?.toString() ?? ''}'
              .trim(),
      classLabel: section.isEmpty ? className : '$className - $section',
    );
  }
}

class AdminParentRecord {
  const AdminParentRecord({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.isActive,
    required this.studentsCount,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final bool isActive;
  final int studentsCount;

  factory AdminParentRecord.fromJson(Map<String, dynamic> json) {
    final students = json['students'] as List<dynamic>? ?? const <dynamic>[];
    return AdminParentRecord(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      isActive: json['isActive'] != false,
      studentsCount: students.length,
    );
  }
}

class AdminParentLinkedStudent {
  const AdminParentLinkedStudent({
    required this.fullName,
    required this.admissionNo,
    required this.classLabel,
    required this.relationType,
    required this.isPrimary,
  });

  final String fullName;
  final String admissionNo;
  final String classLabel;
  final String relationType;
  final bool isPrimary;

  factory AdminParentLinkedStudent.fromJson(Map<String, dynamic> json) {
    final student =
        json['student'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final className = student['className']?.toString() ?? '';
    final section = student['section']?.toString() ?? '';
    return AdminParentLinkedStudent(
      fullName:
          '${student['firstName']?.toString() ?? ''} ${student['lastName']?.toString() ?? ''}'
              .trim(),
      admissionNo: student['admissionNo']?.toString() ?? '',
      classLabel: section.isEmpty ? className : '$className - $section',
      relationType: json['relationType']?.toString() ?? 'GUARDIAN',
      isPrimary: json['isPrimary'] == true,
    );
  }
}

class AdminStaffRecord {
  const AdminStaffRecord({
    required this.id,
    required this.employeeCode,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.designation,
    required this.department,
    required this.isActive,
    required this.joinDate,
    required this.userRole,
  });

  final String id;
  final String employeeCode;
  final String fullName;
  final String email;
  final String phone;
  final String designation;
  final String department;
  final bool isActive;
  final String joinDate;
  final String userRole;

  factory AdminStaffRecord.fromJson(Map<String, dynamic> json) {
    final user =
        json['user'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    return AdminStaffRecord(
      id: json['id']?.toString() ?? '',
      employeeCode: json['employeeCode']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      isActive: json['isActive'] != false,
      joinDate: json['joinDate']?.toString() ?? '',
      userRole: user['role']?.toString() ?? '',
    );
  }
}

class AdminPeopleController extends GetxController {
  AdminPeopleController(this._adminService);

  final AdminService _adminService;

  final parents = <AdminParentRecord>[].obs;
  final staffMembers = <AdminStaffRecord>[].obs;
  final studentOptions = <AdminPeopleStudentOption>[].obs;

  final isParentsLoading = false.obs;
  final isStaffLoading = false.obs;
  final parentsError = ''.obs;
  final staffError = ''.obs;

  final parentSearchText = ''.obs;
  final staffSearchText = ''.obs;
  final parentSearchController = TextEditingController();
  final staffSearchController = TextEditingController();

  final parentsPage = 1.obs;
  final parentsTotalPages = 1.obs;
  final parentsTotalItems = 0.obs;
  final staffPage = 1.obs;
  final staffTotalPages = 1.obs;
  final staffTotalItems = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  @override
  void onClose() {
    parentSearchController.dispose();
    staffSearchController.dispose();
    super.onClose();
  }

  Future<void> loadInitialData() async {
    await Future.wait([loadParents(), loadStaff(), loadStudentOptions()]);
  }

  Future<void> loadStudentOptions() async {
    try {
      final data = await _adminService.getStudents(page: 1, limit: 100);
      final rawItems = data['items'];
      if (rawItems is! List) {
        studentOptions.clear();
        return;
      }
      studentOptions.assignAll(
        rawItems
            .whereType<Map>()
            .map(
              (item) => AdminPeopleStudentOption.fromJson(
                item.cast<String, dynamic>(),
              ),
            )
            .where((item) => item.id.isNotEmpty)
            .toList(),
      );
    } catch (_) {
      studentOptions.clear();
    }
  }

  Future<void> loadParents({int nextPage = 1}) async {
    isParentsLoading.value = true;
    parentsError.value = '';
    try {
      final data = await _adminService.getParents(
        page: nextPage,
        limit: 20,
        search: parentSearchText.value.trim().isEmpty
            ? null
            : parentSearchText.value.trim(),
      );
      final rawItems = data['items'];
      final pagination =
          data['pagination'] as Map<String, dynamic>? ??
          const <String, dynamic>{};
      if (rawItems is List) {
        parents.assignAll(
          rawItems
              .whereType<Map>()
              .map(
                (item) =>
                    AdminParentRecord.fromJson(item.cast<String, dynamic>()),
              )
              .toList(),
        );
      } else {
        parents.clear();
      }
      parentsTotalItems.value =
          (pagination['total'] as num?)?.toInt() ?? parents.length;
      parentsPage.value = (pagination['page'] as num?)?.toInt() ?? nextPage;
      parentsTotalPages.value =
          (pagination['totalPages'] as num?)?.toInt() ?? 1;
    } catch (e) {
      parentsError.value = dioOrApiErrorMessage(e);
      parents.clear();
      parentsTotalItems.value = 0;
      AppToast.show(parentsError.value);
    } finally {
      isParentsLoading.value = false;
    }
  }

  Future<void> loadStaff({int nextPage = 1}) async {
    isStaffLoading.value = true;
    staffError.value = '';
    try {
      final data = await _adminService.getStaff(
        page: nextPage,
        limit: 20,
        search: staffSearchText.value.trim().isEmpty
            ? null
            : staffSearchText.value.trim(),
      );
      final rawItems = data['items'];
      final pagination =
          data['pagination'] as Map<String, dynamic>? ??
          const <String, dynamic>{};
      if (rawItems is List) {
        staffMembers.assignAll(
          rawItems
              .whereType<Map>()
              .map(
                (item) =>
                    AdminStaffRecord.fromJson(item.cast<String, dynamic>()),
              )
              .toList(),
        );
      } else {
        staffMembers.clear();
      }
      staffTotalItems.value =
          (pagination['total'] as num?)?.toInt() ?? staffMembers.length;
      staffPage.value = (pagination['page'] as num?)?.toInt() ?? nextPage;
      staffTotalPages.value = (pagination['totalPages'] as num?)?.toInt() ?? 1;
    } catch (e) {
      staffError.value = dioOrApiErrorMessage(e);
      staffMembers.clear();
      staffTotalItems.value = 0;
      AppToast.show(staffError.value);
    } finally {
      isStaffLoading.value = false;
    }
  }

  Future<void> searchParents(String value) async {
    parentSearchText.value = value.trim();
    await loadParents();
  }

  Future<void> searchStaff(String value) async {
    staffSearchText.value = value.trim();
    await loadStaff();
  }

  Future<void> openParentDialog({AdminParentRecord? existing}) async {
    final fullNameController = TextEditingController(
      text: existing?.fullName ?? '',
    );
    final emailController = TextEditingController(text: existing?.email ?? '');
    final phoneController = TextEditingController(text: existing?.phone ?? '');
    bool isActive = existing?.isActive ?? true;
    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(existing == null ? 'Add Parent' : 'Edit Parent'),
            content: SizedBox(
              width: 440,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: fullNameController,
                      decoration: const InputDecoration(labelText: 'Full name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Phone'),
                      keyboardType: TextInputType.phone,
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
    if (fullNameController.text.trim().isEmpty ||
        (emailController.text.trim().isEmpty &&
            phoneController.text.trim().isEmpty)) {
      AppToast.show('Name and at least one contact field are required.');
      return;
    }
    try {
      if (existing == null) {
        await _adminService.createParent(
          fullName: fullNameController.text.trim(),
          email: emailController.text.trim(),
          phone: phoneController.text.trim(),
          isActive: isActive,
        );
        AppToast.show('Parent created.');
      } else {
        await _adminService.updateParent(
          id: existing.id,
          payload: {
            'fullName': fullNameController.text.trim(),
            'email': emailController.text.trim().isEmpty
                ? null
                : emailController.text.trim(),
            'phone': phoneController.text.trim().isEmpty
                ? null
                : phoneController.text.trim(),
            'isActive': isActive,
          },
        );
        AppToast.show('Parent updated.');
      }
      await loadParents(nextPage: parentsPage.value);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> inviteParent() async {
    final fullNameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final relationController = TextEditingController(text: 'GUARDIAN');
    String studentId = '';
    bool isPrimary = false;
    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Invite Parent'),
            content: SizedBox(
              width: 460,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: fullNameController,
                      decoration: const InputDecoration(labelText: 'Full name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Phone'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: '',
                      decoration: const InputDecoration(
                        labelText: 'Link student (optional)',
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: '',
                          child: Text('No linked student'),
                        ),
                        ...studentOptions.map(
                          (item) => DropdownMenuItem<String>(
                            value: item.id,
                            child: Text(
                              item.label,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => studentId = value ?? ''),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: relationController,
                      decoration: const InputDecoration(
                        labelText: 'Relation type',
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: isPrimary,
                      onChanged: (value) => setState(() => isPrimary = value),
                      title: const Text('Primary guardian'),
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
                child: const Text('Invite'),
              ),
            ],
          );
        },
      ),
    );
    if (ok != true) return;
    if (fullNameController.text.trim().isEmpty ||
        (emailController.text.trim().isEmpty &&
            phoneController.text.trim().isEmpty)) {
      AppToast.show('Name and at least one contact field are required.');
      return;
    }
    try {
      final data = await _adminService.inviteParent(
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        studentId: studentId,
        relationType: relationController.text.trim(),
        isPrimary: isPrimary,
      );
      final invitation =
          data['invitation'] as Map<String, dynamic>? ??
          const <String, dynamic>{};
      final debugOtp = invitation['debugOtp']?.toString() ?? '';
      AppToast.show(
        debugOtp.isEmpty
            ? 'Parent invited successfully.'
            : 'Parent invited. OTP: $debugOtp',
      );
      await loadParents();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> openParentDetails(AdminParentRecord item) async {
    try {
      final data = await _adminService.getParentById(item.id);
      final parent =
          data['parent'] as Map<String, dynamic>? ?? const <String, dynamic>{};
      final linkedStudents =
          (parent['students'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<Map>()
              .map(
                (student) => AdminParentLinkedStudent.fromJson(
                  student.cast<String, dynamic>(),
                ),
              )
              .toList();
      await Get.dialog<void>(
        AlertDialog(
          title: Text(item.fullName),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.email.isNotEmpty) Text('Email: ${item.email}'),
                  if (item.phone.isNotEmpty) Text('Phone: ${item.phone}'),
                  Text('Status: ${item.isActive ? 'Active' : 'Inactive'}'),
                  const SizedBox(height: 14),
                  const Text(
                    'Linked Students',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  if (linkedStudents.isEmpty)
                    const Text('No student is linked yet.')
                  else
                    ...linkedStudents.map(
                      (student) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(student.fullName),
                        subtitle: Text(
                          '${student.admissionNo}${student.classLabel.isEmpty ? '' : ' | ${student.classLabel}'}',
                        ),
                        trailing: Text(
                          student.isPrimary
                              ? '${student.relationType} | Primary'
                              : student.relationType,
                        ),
                      ),
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

  Future<void> resendParentOtp(AdminParentRecord item) async {
    try {
      final data = await _adminService.resendParentOtp(item.id);
      final debugOtp = data['debugOtp']?.toString() ?? '';
      AppToast.show(
        debugOtp.isEmpty ? 'OTP resent successfully.' : 'OTP resent: $debugOtp',
      );
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> openStaffDialog({AdminStaffRecord? existing}) async {
    final codeController = TextEditingController(
      text: existing?.employeeCode ?? '',
    );
    final nameController = TextEditingController(
      text: existing?.fullName ?? '',
    );
    final emailController = TextEditingController(text: existing?.email ?? '');
    final phoneController = TextEditingController(text: existing?.phone ?? '');
    final designationController = TextEditingController(
      text: existing?.designation ?? '',
    );
    final departmentController = TextEditingController(
      text: existing?.department ?? '',
    );
    final joinDateController = TextEditingController(
      text: (existing?.joinDate.length ?? 0) >= 10
          ? existing!.joinDate.substring(0, 10)
          : existing?.joinDate ?? '',
    );
    bool isActive = existing?.isActive ?? true;
    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(existing == null ? 'Add Staff' : 'Edit Staff'),
            content: SizedBox(
              width: 460,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: codeController,
                      decoration: const InputDecoration(
                        labelText: 'Employee code',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Full name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Phone'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: designationController,
                      decoration: const InputDecoration(
                        labelText: 'Designation',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: departmentController,
                      decoration: const InputDecoration(
                        labelText: 'Department',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: joinDateController,
                      decoration: const InputDecoration(
                        labelText: 'Join date (YYYY-MM-DD)',
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
    if (codeController.text.trim().isEmpty ||
        nameController.text.trim().isEmpty) {
      AppToast.show('Employee code and full name are required.');
      return;
    }
    try {
      if (existing == null) {
        await _adminService.createStaff(
          employeeCode: codeController.text.trim(),
          fullName: nameController.text.trim(),
          email: emailController.text.trim(),
          phone: phoneController.text.trim(),
          designation: designationController.text.trim(),
          department: departmentController.text.trim(),
          isActive: isActive,
          joinDate: joinDateController.text.trim(),
        );
        AppToast.show('Staff created.');
      } else {
        await _adminService.updateStaff(
          id: existing.id,
          payload: {
            'employeeCode': codeController.text.trim(),
            'fullName': nameController.text.trim(),
            'email': emailController.text.trim().isEmpty
                ? null
                : emailController.text.trim(),
            'phone': phoneController.text.trim().isEmpty
                ? null
                : phoneController.text.trim(),
            'designation': designationController.text.trim().isEmpty
                ? null
                : designationController.text.trim(),
            'department': departmentController.text.trim().isEmpty
                ? null
                : departmentController.text.trim(),
            'joinDate': joinDateController.text.trim().isEmpty
                ? null
                : joinDateController.text.trim(),
            'isActive': isActive,
          },
        );
        AppToast.show('Staff updated.');
      }
      await loadStaff(nextPage: staffPage.value);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> openStaffDetails(AdminStaffRecord item) async {
    try {
      final data = await _adminService.getStaffById(item.id);
      final staff =
          data['staff'] as Map<String, dynamic>? ?? const <String, dynamic>{};
      final classes = staff['classesAsTeacher'] as List<dynamic>? ?? const [];
      final documents = staff['documents'] as List<dynamic>? ?? const [];
      await Get.dialog<void>(
        AlertDialog(
          title: Text(item.fullName),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Employee code: ${item.employeeCode}'),
                  if (item.designation.isNotEmpty)
                    Text('Designation: ${item.designation}'),
                  if (item.department.isNotEmpty)
                    Text('Department: ${item.department}'),
                  if (item.email.isNotEmpty) Text('Email: ${item.email}'),
                  if (item.phone.isNotEmpty) Text('Phone: ${item.phone}'),
                  if (item.userRole.isNotEmpty)
                    Text('Linked role: ${item.userRole}'),
                  Text('Status: ${item.isActive ? 'Active' : 'Inactive'}'),
                  const SizedBox(height: 14),
                  Text('Assigned classes: ${classes.length}'),
                  Text('Documents: ${documents.length}'),
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

  Future<void> toggleStaffActive(AdminStaffRecord item) async {
    try {
      await _adminService.updateStaff(
        id: item.id,
        payload: {'isActive': !item.isActive},
      );
      AppToast.show(!item.isActive ? 'Staff activated.' : 'Staff deactivated.');
      await loadStaff(nextPage: staffPage.value);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> deleteStaff(AdminStaffRecord item) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Staff'),
        content: Text('Delete ${item.fullName} (${item.employeeCode})?'),
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
      await _adminService.deleteStaff(item.id);
      AppToast.show('Staff deleted.');
      await loadStaff(nextPage: staffPage.value);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }
}
