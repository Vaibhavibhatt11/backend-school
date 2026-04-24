import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    this.classesCount = 0,
    this.documentsCount = 0,
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
  final int classesCount;
  final int documentsCount;

  factory AdminStaffRecord.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final classes = json['classesAsTeacher'] as List? ?? const [];
    final docs = json['documents'] as List? ?? const [];
    
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
      classesCount: classes.length,
      documentsCount: docs.length,
    );
  }

  bool get isTeacher => userRole.toUpperCase() == 'TEACHER' || designation.toUpperCase().contains('TEACHER');
}

class AdminStaffController extends GetxController {
  AdminStaffController(this._adminService);
  final AdminService _adminService;

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final staffMembers = <AdminStaffRecord>[].obs;
  final searchController = TextEditingController();
  final searchText = ''.obs;

  // Pagination
  final page = 1.obs;
  final totalPages = 1.obs;
  final totalItems = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadInitialData() async {
    await loadStaff();
  }

  Future<void> loadStaff({int nextPage = 1}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _adminService.getStaff(
        page: nextPage,
        limit: 20,
        search: searchText.value.trim().isEmpty ? null : searchText.value.trim(),
      );
      
      final rawItems = data['items'];
      final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
      
      if (rawItems is List) {
        staffMembers.assignAll(
          rawItems.whereType<Map>().map((e) => AdminStaffRecord.fromJson(e.cast<String, dynamic>())).toList(),
        );
      } else {
        staffMembers.clear();
      }

      totalItems.value = (pagination['total'] as num?)?.toInt() ?? staffMembers.length;
      page.value = (pagination['page'] as num?)?.toInt() ?? nextPage;
      totalPages.value = (pagination['totalPages'] as num?)?.toInt() ?? 1;
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      AppToast.show(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  void onSearch(String value) {
    searchText.value = value;
    loadStaff();
  }

  Future<void> openAddStaff() async => _openStaffDialog();

  Future<void> openEditStaff(AdminStaffRecord item) async => _openStaffDialog(existing: item);

  Future<void> _openStaffDialog({AdminStaffRecord? existing}) async {
    final codeCtrl = TextEditingController(text: existing?.employeeCode ?? '');
    final nameCtrl = TextEditingController(text: existing?.fullName ?? '');
    final emailCtrl = TextEditingController(text: existing?.email ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final desCtrl = TextEditingController(text: existing?.designation ?? '');
    final depCtrl = TextEditingController(text: existing?.department ?? '');
    final dateCtrl = TextEditingController(text: existing?.joinDate.split('T').first ?? '');
    final passCtrl = TextEditingController();

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(existing == null ? 'New Staff Member' : 'Edit Staff Details'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Employee Code *')),
                const SizedBox(height: 12),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name *')),
                const SizedBox(height: 12),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address')),
                const SizedBox(height: 12),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number')),
                const SizedBox(height: 12),
                TextField(controller: desCtrl, decoration: const InputDecoration(labelText: 'Designation (e.g. Teacher)')),
                const SizedBox(height: 12),
                TextField(controller: depCtrl, decoration: const InputDecoration(labelText: 'Department')),
                const SizedBox(height: 12),
                TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Join Date (YYYY-MM-DD)')),
                if (existing == null) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: passCtrl,
                    decoration: const InputDecoration(labelText: 'Login Password *'),
                    obscureText: true,
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Get.back(result: true), child: Text(existing == null ? 'Create' : 'Save')),
        ],
      ),
    );

    if (confirmed == true) {
      if (codeCtrl.text.trim().isEmpty || nameCtrl.text.trim().isEmpty) {
        AppToast.show('Employee code and name are required.');
        return;
      }
      try {
        isLoading.value = true;
        final payload = {
          'employeeCode': codeCtrl.text.trim(),
          'fullName': nameCtrl.text.trim(),
          'email': emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
          'phone': phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
          'designation': desCtrl.text.trim().isEmpty ? null : desCtrl.text.trim(),
          'department': depCtrl.text.trim().isEmpty ? null : depCtrl.text.trim(),
          'joinDate': dateCtrl.text.trim().isEmpty ? null : dateCtrl.text.trim(),
          'password': passCtrl.text.trim(),
        };

        if (existing == null) {
          await _adminService.createStaff(
            employeeCode: payload['employeeCode']!,
            fullName: payload['fullName']!,
            email: payload['email'],
            phone: payload['phone'],
            designation: payload['designation'],
            department: payload['department'],
            joinDate: payload['joinDate'],
            password: payload['password'],
          );
          AppToast.show('Staff member added.');
        } else {
          await _adminService.updateStaff(id: existing.id, payload: payload);
          AppToast.show('Staff profile updated.');
        }
        await loadStaff(nextPage: page.value);
      } catch (e) {
        AppToast.show(dioOrApiErrorMessage(e));
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> toggleStatus(AdminStaffRecord item) async {
    try {
      isLoading.value = true;
      await _adminService.updateStaff(id: item.id, payload: {'isActive': !item.isActive});
      AppToast.show(item.isActive ? 'Staff deactivated' : 'Staff activated');
      await loadStaff(nextPage: page.value);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteStaff(AdminStaffRecord item) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Remove Staff'),
        content: Text('Are you sure you want to permanently remove ${item.fullName}?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Get.back(result: true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        isLoading.value = true;
        await _adminService.deleteStaff(item.id);
        AppToast.show('Staff record deleted.');
        await loadStaff();
      } catch (e) {
        AppToast.show(dioOrApiErrorMessage(e));
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> viewDetails(AdminStaffRecord item) async {
    try {
      isLoading.value = true;
      final data = await _adminService.getStaffById(item.id);
      final staff = data['staff'] as Map<String, dynamic>? ?? {};
      
      // Open a detailed profile bottom sheet or dialog
      _showDetailProfile(item, staff);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  void _showDetailProfile(AdminStaffRecord item, Map<String, dynamic> detail) {
    final isDark = Get.isDarkMode;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.blue.withValues(alpha: 0.1),
                    child: Text(
                      item.fullName.isNotEmpty ? item.fullName[0].toUpperCase() : 'S',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.fullName,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '${item.designation} • ${item.employeeCode}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildInfoSection('Professional Details', [
                _InfoRow(Icons.business_rounded, 'Department', item.department),
                _InfoRow(Icons.work_rounded, 'Role', item.userRole),
                _InfoRow(Icons.calendar_today_rounded, 'Joining Date', item.joinDate.split('T').first),
              ]),
              const SizedBox(height: 24),
              _buildInfoSection('Contact Information', [
                _InfoRow(Icons.email_rounded, 'Email', item.email),
                _InfoRow(Icons.phone_rounded, 'Phone', item.phone),
              ]),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                        openEditStaff(item);
                      },
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text('Edit Profile'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Get.back();
                        toggleStatus(item);
                      },
                      icon: Icon(item.isActive ? Icons.block_rounded : Icons.check_circle_rounded),
                      label: Text(item.isActive ? 'Deactivate' : 'Activate'),
                      style: FilledButton.styleFrom(
                        backgroundColor: item.isActive ? Colors.orange : Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue, letterSpacing: 1.2),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value.isEmpty ? 'Not set' : value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
