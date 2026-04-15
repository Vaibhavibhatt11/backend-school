import 'package:erp_frontend/app/modules/admin/models/admin_class_option.dart';
import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminAdmissionApplication {
  const AdminAdmissionApplication({
    required this.id,
    required this.applicationNo,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.appliedClass,
    required this.appliedSection,
    required this.status,
    required this.registrationNo,
    required this.documentsCount,
    required this.createdAt,
    required this.admissionFeePaid,
  });

  final String id;
  final String applicationNo;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String appliedClass;
  final String appliedSection;
  final String status;
  final String registrationNo;
  final int documentsCount;
  final String createdAt;
  final bool admissionFeePaid;

  String get fullName => '$firstName $lastName'.trim();
  String get classLabel =>
      appliedSection.isEmpty ? appliedClass : '$appliedClass - $appliedSection';
  bool get canReview => status == 'UNDER_REVIEW';
  bool get canOnboard => status == 'APPROVED' && registrationNo.isEmpty;

  factory AdminAdmissionApplication.fromJson(Map<String, dynamic> json) {
    final countMap =
        json['_count'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    return AdminAdmissionApplication(
      id: json['id']?.toString() ?? '',
      applicationNo: json['applicationNo']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      appliedClass: json['appliedClass']?.toString() ?? '',
      appliedSection: json['appliedSection']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      registrationNo: json['registrationNo']?.toString() ?? '',
      documentsCount: (countMap['documents'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt']?.toString() ?? '',
      admissionFeePaid: json['admissionFeePaid'] == true,
    );
  }
}

class AdminAdmissionsController extends GetxController {
  AdminAdmissionsController(this._adminService);

  final AdminService _adminService;

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final applications = <AdminAdmissionApplication>[].obs;
  final classOptions = <AdminClassOption>[].obs;
  final selectedStatus = 'ALL'.obs;
  final searchText = ''.obs;
  final searchController = TextEditingController();
  final page = 1.obs;
  final totalPages = 1.obs;
  final totalItems = 0.obs;

  static const statusOptions = <String>[
    'ALL',
    'UNDER_REVIEW',
    'APPROVED',
    'REJECTED',
    'ONBOARDED',
  ];

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
    await loadApplications();
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
    } catch (_) {
      classOptions.clear();
    }
  }

  Future<void> loadApplications({int nextPage = 1}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _adminService.getAdmissionApplications(
        page: nextPage,
        limit: 20,
        status: selectedStatus.value == 'ALL' ? null : selectedStatus.value,
        search: searchText.value.trim().isEmpty
            ? null
            : searchText.value.trim(),
      );
      final rawItems = data['items'];
      final pagination =
          data['pagination'] as Map<String, dynamic>? ??
          const <String, dynamic>{};
      if (rawItems is List) {
        applications.assignAll(
          rawItems
              .whereType<Map>()
              .map(
                (item) => AdminAdmissionApplication.fromJson(
                  item.cast<String, dynamic>(),
                ),
              )
              .toList(),
        );
      } else {
        applications.clear();
      }
      totalItems.value =
          (pagination['total'] as num?)?.toInt() ?? applications.length;
      page.value = (pagination['page'] as num?)?.toInt() ?? nextPage;
      totalPages.value = (pagination['totalPages'] as num?)?.toInt() ?? 1;
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      applications.clear();
      totalItems.value = 0;
      AppToast.show(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changeStatusFilter(String status) async {
    selectedStatus.value = status;
    await loadApplications();
  }

  Future<void> search(String value) async {
    searchText.value = value.trim();
    await loadApplications();
  }

  Future<void> openCreateDialog() async {
    if (classOptions.isEmpty) {
      AppToast.show('Create classes first, then add admission applications.');
      return;
    }
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final genderController = TextEditingController();
    AdminClassOption? selectedClass = classOptions.isNotEmpty
        ? classOptions.first
        : null;
    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('New Admission Application'),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                      value: selectedClass,
                      decoration: const InputDecoration(
                        labelText: 'Applied class',
                      ),
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
                      controller: genderController,
                      decoration: const InputDecoration(labelText: 'Gender'),
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
                child: const Text('Create'),
              ),
            ],
          );
        },
      ),
    );
    if (ok != true) return;
    if (firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty ||
        selectedClass == null) {
      AppToast.show('First name, last name, and class are required.');
      return;
    }
    try {
      await _adminService.createAdmissionApplication(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        appliedClass: selectedClass!.name,
        appliedSection: selectedClass!.section.trim().isEmpty
            ? null
            : selectedClass!.section,
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        gender: genderController.text.trim(),
      );
      AppToast.show('Admission application created.');
      await loadApplications();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> reviewApplication(
    AdminAdmissionApplication item,
    String status,
  ) async {
    try {
      await _adminService.updateAdmissionApplicationStatus(
        id: item.id,
        status: status,
      );
      AppToast.show('Application updated to $status.');
      await loadApplications(nextPage: page.value);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> onboardApplication(AdminAdmissionApplication item) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Onboard Student'),
        content: Text(
          'Create a real student record for ${item.fullName} from this approved admission?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Onboard'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final data = await _adminService.onboardAdmissionApplication(item.id);
      final student =
          data['student'] as Map<String, dynamic>? ?? const <String, dynamic>{};
      AppToast.show(
        'Student created: ${student['admissionNo'] ?? student['id'] ?? 'record saved'}',
      );
      await loadApplications(nextPage: page.value);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> addDocument(AdminAdmissionApplication item) async {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    final typeController = TextEditingController(text: 'document');
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Add Document for ${item.applicationNo}'),
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
      await _adminService.addAdmissionApplicationDocument(
        id: item.id,
        name: nameController.text.trim(),
        url: urlController.text.trim(),
        type: typeController.text.trim(),
      );
      AppToast.show('Document added.');
      await loadApplications(nextPage: page.value);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> openDetails(AdminAdmissionApplication item) async {
    try {
      final data = await _adminService.getAdmissionApplicationById(item.id);
      final documents =
          (data['documents'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<Map>()
              .map((doc) => doc.cast<String, dynamic>())
              .toList();
      await Get.dialog<void>(
        AlertDialog(
          title: Text(
            item.applicationNo.isEmpty ? item.fullName : item.applicationNo,
          ),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text('Applied class: ${item.classLabel}'),
                  Text('Status: ${item.status}'),
                  if (item.email.isNotEmpty) Text('Email: ${item.email}'),
                  if (item.phone.isNotEmpty) Text('Phone: ${item.phone}'),
                  if (item.registrationNo.isNotEmpty)
                    Text('Registration no: ${item.registrationNo}'),
                  const SizedBox(height: 14),
                  const Text(
                    'Documents',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  if (documents.isEmpty)
                    const Text('No documents uploaded yet.')
                  else
                    ...documents.map(
                      (doc) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(doc['name']?.toString() ?? 'Document'),
                        subtitle: Text(doc['type']?.toString() ?? 'document'),
                        trailing: TextButton(
                          onPressed: () =>
                              _openDocumentUrl(doc['url']?.toString() ?? ''),
                          child: const Text('Open'),
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

  Future<void> _openDocumentUrl(String url) async {
    final normalizedUrl = url.trim();
    if (normalizedUrl.isEmpty) {
      AppToast.show('Document URL is missing.');
      return;
    }
    final uri = Uri.tryParse(normalizedUrl);
    if (uri == null || !uri.hasScheme) {
      AppToast.show('Document URL is invalid.');
      return;
    }
    try {
      if (!await canLaunchUrl(uri)) {
        AppToast.show('Unable to open this document.');
        return;
      }
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        AppToast.show('Unable to open this document.');
      }
    } catch (_) {
      AppToast.show('Unable to open this document.');
    }
  }
}
