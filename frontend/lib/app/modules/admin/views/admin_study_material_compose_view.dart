import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/core/widgets/custom_app_bar.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_study_material_controller.dart';
import 'package:erp_frontend/app/modules/admin/models/admin_study_material_models.dart';
import 'package:erp_frontend/app/modules/admin/utils/admin_study_material_visuals.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminStudyMaterialComposeView extends StatefulWidget {
  const AdminStudyMaterialComposeView({super.key});

  @override
  State<AdminStudyMaterialComposeView> createState() =>
      _AdminStudyMaterialComposeViewState();
}

class _AdminStudyMaterialComposeViewState
    extends State<AdminStudyMaterialComposeView> {
  late final AdminStudyMaterialController controller;
  late final AdminStudyMaterialCategory category;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedClassId = '';
  String _selectedSubjectId = '';
  List<int>? _pickedFileBytes;
  String? _pickedFileName;
  String? _pickedFileSize;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AdminStudyMaterialController>();
    final rawArgs =
        (Get.arguments as Map?)?.cast<String, dynamic>() ?? const {};
    category = AdminStudyMaterialCategoryX.fromValue(
      (rawArgs['category'] ?? 'notes').toString(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.classOptions.isEmpty ||
          controller.subjectOptions.isEmpty) {
        controller.loadInitialData(showErrors: true);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = adminStudyMaterialColor(category);
    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: CustomAppBar(title: category.title),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(adminStudyMaterialIcon(category), color: color),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.textDark
                                : AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          adminStudyMaterialHelperText(category),
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Material Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _titleController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: '${category.singularLabel} title',
                      hintText: _hintTitle(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _urlController,
                    onChanged: (val) {
                      if (val.isNotEmpty) {
                        setState(() {
                          _pickedFileBytes = null;
                          _pickedFileName = null;
                        });
                      }
                      setState(() {});
                    },
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                      labelText: '${category.singularLabel} URL',
                      hintText: _hintUrl(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_pickedFileName != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.insert_drive_file_rounded, color: color),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _pickedFileName!,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  _pickedFileSize ?? '',
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _pickedFileBytes = null;
                                _pickedFileName = null;
                              });
                            },
                            icon: const Icon(Icons.close_rounded, size: 20),
                          ),
                        ],
                      ),
                    ),
                  OutlinedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.file_present_rounded),
                    label: Text(_pickedFileName == null ? 'Upload File' : 'Change File'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      side: BorderSide(color: color),
                      foregroundColor: color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    onChanged: (_) => setState(() {}),
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      hintText:
                          'Add a short summary so students and staff know what this material covers.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Audience',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedClassId,
                    decoration: const InputDecoration(
                      labelText: 'Class (optional)',
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: '',
                        child: Text('All classes / general'),
                      ),
                      ...controller.classOptions.map(
                        (item) => DropdownMenuItem<String>(
                          value: item.id,
                          child: Text(
                            item.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedClassId = value ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSubjectId,
                    decoration: const InputDecoration(
                      labelText: 'Subject (optional)',
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: '',
                        child: Text('All subjects / general'),
                      ),
                      ...controller.subjectOptions.map(
                        (item) => DropdownMenuItem<String>(
                          value: item.id,
                          child: Text(
                            item.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedSubjectId = value ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'This flow publishes the ${category.singularLabel.toLowerCase()} as a live study material record for admin and students to access.',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Student Preview',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.backgroundDark
                          : AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            adminStudyMaterialIcon(category),
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _titleController.text.trim().isEmpty
                                    ? _hintTitle()
                                    : _titleController.text.trim(),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? AppColors.textDark
                                      : AppColors.textLight,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _previewSubtitle(),
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                              if (_descriptionController.text
                                  .trim()
                                  .isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  _descriptionController.text.trim(),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _ComposePreviewPill(
                                    label: category.singularLabel.toUpperCase(),
                                    color: color,
                                  ),
                                  _ComposePreviewPill(
                                    label: _selectedClassId.isEmpty
                                        ? 'ALL CLASSES'
                                        : 'TARGET CLASS',
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: controller.isPublishing.value
                    ? null
                    : _publishMaterial,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: controller.isPublishing.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.cloud_upload_rounded),
                label: Text(
                  controller.isPublishing.value
                      ? Column(
                          children: [
                            Text(
                              controller.isUploading.value
                                  ? 'Uploading File...'
                                  : 'Publishing...',
                              style: const TextStyle(color: Colors.white),
                            ),
                            if (controller.isUploading.value) ...[
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: controller.uploadProgress.value,
                                backgroundColor: Colors.white24,
                                color: Colors.white,
                              ),
                            ],
                          ],
                        )
                      : Text('Publish ${category.singularLabel}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _publishMaterial() async {
    final created = await controller.createMaterial(
      category: category,
      title: _titleController.text,
      url: _urlController.text.trim().isEmpty ? null : _urlController.text.trim(),
      fileBytes: _pickedFileBytes,
      fileName: _pickedFileName,
      description: _descriptionController.text,
      classId: _selectedClassId,
      subjectId: _selectedSubjectId,
    );
    if (created && mounted) {
      Get.back(result: true);
    }
  }

  Future<void> _pickFile() async {
    final file = await controller.pickFile(category);
    if (file != null) {
      setState(() {
        _pickedFileBytes = file.bytes;
        _pickedFileName = file.name;
        _pickedFileSize = '${(file.size / 1024).toStringAsFixed(1)} KB';
        _urlController.clear();
      });
    }
  }

  String _hintTitle() {
    switch (category) {
      case AdminStudyMaterialCategory.notes:
        return 'Chapter 4 revision notes';
      case AdminStudyMaterialCategory.videos:
        return 'Trigonometry explanation video';
      case AdminStudyMaterialCategory.pdfs:
        return 'Unit test question bank PDF';
      case AdminStudyMaterialCategory.resources:
        return 'Interactive grammar practice resource';
    }
  }

  String _hintUrl() {
    switch (category) {
      case AdminStudyMaterialCategory.notes:
        return 'https://drive.google.com/...';
      case AdminStudyMaterialCategory.videos:
        return 'https://youtu.be/...';
      case AdminStudyMaterialCategory.pdfs:
        return 'https://example.com/material.pdf';
      case AdminStudyMaterialCategory.resources:
        return 'https://example.com/learning-resource';
    }
  }

  String _previewSubtitle() {
    final classLabel =
        controller.findClassOption(_selectedClassId)?.label ?? 'All classes';
    final subjectLabel =
        controller.findSubjectOption(_selectedSubjectId)?.label ??
        'General subject';
    return '$subjectLabel | $classLabel';
  }
}

class _ComposePreviewPill extends StatelessWidget {
  const _ComposePreviewPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
