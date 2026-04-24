import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class StaffProfileView extends StatefulWidget {
  const StaffProfileView({super.key});

  @override
  State<StaffProfileView> createState() => _StaffProfileViewState();
}

class _StaffProfileViewState extends State<StaffProfileView> {
  late final StaffProfileController controller;
  late final TextEditingController _nameController;
  late final TextEditingController _departmentController;
  late final TextEditingController _qualificationController;
  late final TextEditingController _experienceController;
  late final TextEditingController _contactController;
  late final TextEditingController _emailController;
  var _syncedInitial = false;

  @override
  void initState() {
    super.initState();
    controller = Get.find<StaffProfileController>();
    _nameController = TextEditingController();
    _departmentController = TextEditingController();
    _qualificationController = TextEditingController();
    _experienceController = TextEditingController();
    _contactController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _departmentController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _syncFormFromController() {
    _nameController.text = controller.name.value;
    _departmentController.text = controller.department.value;
    _qualificationController.text = controller.qualification.value;
    _experienceController.text = controller.experience.value;
    _contactController.text = controller.contact.value;
    _emailController.text = controller.email.value;
    _syncedInitial = true;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Obx(() {
        if (!_syncedInitial && controller.name.value.isNotEmpty) {
          _syncFormFromController();
        }
        if (controller.isLoading.value && controller.name.value.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value.isNotEmpty &&
            controller.name.value.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Staff Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: controller.loadProfile,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Reload'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _profileHeaderCard(isDark),
            const SizedBox(height: 12),
            _tabBar(isDark),
            const SizedBox(height: 12),
            _activePanel(isDark),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: controller.isSaving.value
                    ? null
                    : () => controller.saveProfile(
                          name: _nameController.text,
                          department: _departmentController.text,
                          qualification: _qualificationController.text,
                          experience: _experienceController.text,
                          contact: _contactController.text,
                          email: _emailController.text,
                        ),
                icon: controller.isSaving.value
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(
                  controller.isSaving.value ? 'Saving...' : 'Save Profile',
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _profileHeaderCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: Text(
                  _nameController.text.isEmpty
                      ? 'S'
                      : _nameController.text.trim()[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _nameController.text.isEmpty
                      ? 'Staff Profile'
                      : _nameController.text,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _infoChip('ID: ${controller.staffId.value.isEmpty ? 'N/A' : controller.staffId.value}'),
              _infoChip('Dept: ${_departmentController.text.isEmpty ? 'N/A' : _departmentController.text}'),
              _infoChip('${controller.documentRows.length} documents'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: AppColors.primary),
      ),
    );
  }

  Widget _tabBar(bool isDark) {
    final tabs = const [
      'Personal',
      'Qualification',
      'Experience',
      'Department',
      'Documents',
      'ID Card',
      'Contact',
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (index) {
            final selected = controller.activeTab.value == index;
            return GestureDetector(
              onTap: () => controller.setTab(index),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.14)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    color: selected ? AppColors.primary : null,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _activePanel(bool isDark) {
    switch (controller.activeTab.value) {
      case 0:
        return _panelCard(
          isDark,
          title: 'Personal Details',
          child: Column(
            children: [
              _input(_nameController, 'Full Name', Icons.person_rounded),
              const SizedBox(height: 10),
              _input(_emailController, 'Email', Icons.email_rounded),
            ],
          ),
        );
      case 1:
        return _panelCard(
          isDark,
          title: 'Qualification',
          child: _input(
            _qualificationController,
            'Highest Qualification',
            Icons.school_rounded,
            maxLines: 2,
          ),
        );
      case 2:
        return _panelCard(
          isDark,
          title: 'Experience',
          child: _input(
            _experienceController,
            'Experience (e.g. 6 years)',
            Icons.work_history_rounded,
            maxLines: 2,
          ),
        );
      case 3:
        return _panelCard(
          isDark,
          title: 'Department',
          child: _input(
            _departmentController,
            'Department',
            Icons.apartment_rounded,
          ),
        );
      case 4:
        return _documentsPanel(isDark);
      case 5:
        return _idCardPanel(isDark);
      default:
        return _panelCard(
          isDark,
          title: 'Contact Information',
          child: _input(_contactController, 'Contact Number', Icons.phone_rounded),
        );
    }
  }

  Widget _panelCard(bool isDark, {required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _input(
    TextEditingController textController,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: textController,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _documentsPanel(bool isDark) {
    return _panelCard(
      isDark,
      title: 'Documents',
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openDocumentDialog(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Document'),
            ),
          ),
          const SizedBox(height: 10),
          if (controller.documentRows.isEmpty)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('No documents added yet'),
            )
          else
            ...controller.documentRows.map((row) {
              final docId = row['id'] ?? '';
              final url = row['url'] ?? '';
              final canOpen =
                  url.isNotEmpty && Uri.tryParse(url)?.hasScheme == true;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.description_rounded,
                    color: AppColors.primary,
                  ),
                  title: Text(row['name'] ?? 'Document'),
                  subtitle: Text(row['type'] ?? 'General'),
                  onTap: canOpen
                      ? () async {
                          final uri = Uri.parse(url);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        }
                      : null,
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        tooltip: 'Edit',
                        onPressed: () => _openDocumentDialog(existing: row),
                        icon: const Icon(Icons.edit_rounded),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        onPressed: docId.isEmpty
                            ? null
                            : () => controller.deleteDocument(docId),
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Future<void> _openDocumentDialog({Map<String, String>? existing}) async {
    final name = TextEditingController(text: existing?['name'] ?? '');
    final type = TextEditingController(text: existing?['type'] ?? '');
    final url = TextEditingController(text: existing?['url'] ?? '');
    await Get.dialog(
      AlertDialog(
        title: Text(existing == null ? 'Add Document' : 'Edit Document'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _input(name, 'Document Name', Icons.description_rounded),
              const SizedBox(height: 10),
              _input(type, 'Type', Icons.category_rounded),
              const SizedBox(height: 10),
              _input(url, 'URL (optional)', Icons.link_rounded),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              controller.upsertDocument(
                documentId: existing?['id'],
                name: name.text,
                type: type.text,
                url: url.text,
              );
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _idCardPanel(bool isDark) {
    return _panelCard(
      isDark,
      title: 'ID Card',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'School Staff Identity Card',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              _nameController.text.isEmpty ? 'Staff Member' : _nameController.text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'ID: ${controller.staffId.value.isEmpty ? 'N/A' : controller.staffId.value}',
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              'Department: ${_departmentController.text.isEmpty ? 'N/A' : _departmentController.text}',
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              'Contact: ${_contactController.text.isEmpty ? 'N/A' : _contactController.text}',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
