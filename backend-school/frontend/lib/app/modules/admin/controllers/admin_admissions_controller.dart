import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/admin/models/admin_class_option.dart';
import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:erp_frontend/app/modules/admin/views/admin_add_document_view.dart';
import 'package:erp_frontend/app/modules/admin/views/admin_document_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    this.middleName = '',
    this.dob = '',
    this.gender = '',
    this.fatherName = '',
    this.motherName = '',
    this.fatherOccupation = '',
    this.motherOccupation = '',
    this.fatherDob = '',
    this.motherDob = '',
    this.contact1 = '',
    this.contact2 = '',
    this.address = '',
    this.permanentAddress = '',
    this.telephone = '',
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

  // New fields
  final String middleName;
  final String dob;
  final String gender;
  final String fatherName;
  final String motherName;
  final String fatherOccupation;
  final String motherOccupation;
  final String fatherDob;
  final String motherDob;
  final String contact1;
  final String contact2;
  final String address;
  final String permanentAddress;
  final String telephone;

  String get fullName =>
      '$firstName $middleName $lastName'.replaceAll(RegExp(r'\s+'), ' ').trim();
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
      middleName: json['middleName']?.toString() ?? '',
      dob: json['dob']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      fatherName: json['fatherName']?.toString() ?? '',
      motherName: json['motherName']?.toString() ?? '',
      fatherOccupation: json['fatherOccupation']?.toString() ?? '',
      motherOccupation: json['motherOccupation']?.toString() ?? '',
      fatherDob: json['fatherDob']?.toString() ?? '',
      motherDob: json['motherDob']?.toString() ?? '',
      contact1: json['contact1']?.toString() ?? '',
      contact2: json['contact2']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      permanentAddress: json['permanentAddress']?.toString() ?? '',
      telephone: json['telephone']?.toString() ?? '',
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
    'WAITING',
  ];

  final currentAdmissionFee = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    searchController.text = searchText.value;
    loadInitialData();
  }

  Future<void> openSetFeesDialog() async {
    final feeController = TextEditingController(
      text: currentAdmissionFee.value.toString(),
    );
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Set Admission Fees'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the fee amount to be accepted for new admissions:',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: feeController,
              decoration: const InputDecoration(
                labelText: 'Fee Amount',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Save Fees'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final val = double.tryParse(feeController.text.trim()) ?? 0.0;
      try {
        isLoading.value = true;
        await _adminService.updateAdmissionFees(val);
        currentAdmissionFee.value = val;
        AppToast.show('Admission fee updated and saved.');
      } catch (e) {
        AppToast.show('Failed to save fee: ${dioOrApiErrorMessage(e)}');
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> deleteApplication(AdminAdmissionApplication item) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Application'),
        content: Text(
          'Are you sure you want to permanently delete the application for ${item.fullName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        isLoading.value = true;
        await _adminService.deleteAdmissionApplication(item.id);
        AppToast.show('Application deleted successfully.');
        await loadApplications(nextPage: page.value);
      } catch (e) {
        AppToast.show('Failed to delete: ${dioOrApiErrorMessage(e)}');
      } finally {
        isLoading.value = false;
      }
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadInitialData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Fetch classes, applications, and school settings
      final results = await Future.wait([
        loadClassOptions(),
        loadApplications(),
        _adminService.getFeeStructures(page: 1, limit: 100),
      ]);

      final feeData = results[2] as Map<String, dynamic>;
      final items = (feeData['items'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      final admissionFee = items.firstWhere(
        (item) =>
            ((item['name'] ?? '').toString().trim().toLowerCase() ==
                'admission fee'),
        orElse: () => const <String, dynamic>{},
      );
      currentAdmissionFee.value =
          double.tryParse((admissionFee['amount'] ?? '0').toString()) ?? 0.0;
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
    } finally {
      isLoading.value = false;
    }
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
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final genderController = TextEditingController();
    AdminClassOption? selectedClass;
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
                      initialValue: selectedClass,
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
    if (ok == true) {
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
    Get.to(() => AdminAddDocumentView(item: item));
  }

  Future<void> submitDocument({
    required String id,
    required String name,
    required String url,
    required String type,
  }) async {
    try {
      isLoading.value = true;
      await _adminService.addAdmissionApplicationDocument(
        id: id,
        name: name,
        url: url,
        type: type,
      );
      AppToast.show('Document added.');
      Get.back(); // Return to previous screen
      await loadApplications(nextPage: page.value);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    } finally {
      isLoading.value = false;
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

      final fullItem = AdminAdmissionApplication.fromJson(data);
      final isDark = Get.isDarkMode;

      await Get.to(
        () => Scaffold(
          backgroundColor: isDark
              ? AppColors.backgroundDark
              : AppColors.backgroundLight,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    fullItem.fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 80,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),
                actions: [
                  _buildStatusPill(fullItem.status),
                  const SizedBox(width: 16),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPremiumSection(
                        context: Get.context!,
                        title: 'Admission Info',
                        children: [
                          _buildPremiumRow(
                            Icons.tag_rounded,
                            'App No',
                            fullItem.applicationNo.isEmpty
                                ? 'Pending'
                                : fullItem.applicationNo,
                          ),
                          _buildPremiumRow(
                            Icons.school_rounded,
                            'Applied Class',
                            fullItem.classLabel,
                          ),
                          if (fullItem.registrationNo.isNotEmpty)
                            _buildPremiumRow(
                              Icons.badge_rounded,
                              'Reg No',
                              fullItem.registrationNo,
                              color: AppColors.primary,
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildPremiumSection(
                        context: Get.context!,
                        title: 'Student Details',
                        children: [
                          _buildPremiumRow(
                            Icons.person_rounded,
                            'Full Name',
                            fullItem.fullName,
                          ),
                          _buildPremiumRow(
                            Icons.email_rounded,
                            'Email',
                            fullItem.email,
                          ),
                          _buildPremiumRow(
                            Icons.phone_rounded,
                            'Phone',
                            fullItem.phone,
                          ),
                          _buildPremiumRow(
                            Icons.wc_rounded,
                            'Gender',
                            fullItem.gender,
                          ),
                          _buildPremiumRow(
                            Icons.cake_rounded,
                            'Date of Birth',
                            fullItem.dob,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildPremiumSection(
                        context: Get.context!,
                        title: 'Parent Details',
                        children: [
                          _buildPremiumRow(
                            Icons.man_rounded,
                            'Father\'s Name',
                            fullItem.fatherName,
                          ),
                          _buildPremiumRow(
                            Icons.woman_rounded,
                            'Mother\'s Name',
                            fullItem.motherName,
                          ),
                          _buildPremiumRow(
                            Icons.work_rounded,
                            'Father\'s Job',
                            fullItem.fatherOccupation,
                          ),
                          _buildPremiumRow(
                            Icons.work_outline_rounded,
                            'Mother\'s Job',
                            fullItem.motherOccupation,
                          ),
                          _buildPremiumRow(
                            Icons.contact_phone_rounded,
                            'Contact 1',
                            fullItem.contact1,
                          ),
                          _buildPremiumRow(
                            Icons.contact_phone_rounded,
                            'Contact 2',
                            fullItem.contact2,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildPremiumSection(
                        context: Get.context!,
                        title: 'Address',
                        children: [
                          _buildPremiumRow(
                            Icons.home_rounded,
                            'Current',
                            fullItem.address,
                          ),
                          _buildPremiumRow(
                            Icons.location_on_rounded,
                            'Permanent',
                            fullItem.permanentAddress,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Documents',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => addDocument(fullItem),
                            icon: const Icon(
                              Icons.add_circle_outline_rounded,
                              size: 20,
                            ),
                            label: const Text('Upload Document'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (documents.isEmpty)
                        const Center(child: Text('No documents uploaded yet.'))
                      else
                        ...documents.map((doc) => _buildDocumentCard(doc)),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: fullItem.status != 'ONBOARDED'
              ? _buildActionBar(fullItem)
              : null,
        ),
      );
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Widget _buildActionBar(AdminAdmissionApplication item) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => reviewApplication(item, 'REJECTED'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text('Reject'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: () => reviewApplication(item, 'WAITING'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
              ),
              child: const Text('Waitlist'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton(
              onPressed: () => reviewApplication(item, 'APPROVED'),
              style: FilledButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Approve'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSection({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPremiumRow(
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color ?? Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value.isEmpty ? 'N/A' : value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> doc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(
          Icons.description_outlined,
          color: AppColors.primary,
        ),
        title: Text(
          doc['name']?.toString() ?? 'Document',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          doc['type']?.toString() ?? 'document',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new_rounded),
          onPressed: () => _viewDocument(
            doc['url']?.toString() ?? '',
            doc['name']?.toString() ?? 'Document',
          ),
        ),
      ),
    );
  }

  Future<void> _viewDocument(String url, String title) async {
    final normalizedUrl = url.trim();
    if (normalizedUrl.isEmpty) {
      AppToast.show('Document URL is missing.');
      return;
    }
    Get.to(() => AdminDocumentView(url: normalizedUrl, title: title));
  }

  Widget _buildStatusPill(String label) {
    final color = switch (label) {
      'APPROVED' => Colors.green,
      'REJECTED' => Colors.red,
      'ONBOARDED' => Colors.blue,
      'WAITING' => Colors.orange,
      _ => Colors.orange,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label == 'UNDER_REVIEW' ? 'PENDING' : label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
