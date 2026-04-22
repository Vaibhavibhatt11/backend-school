import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/core/widgets/custom_app_bar.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_study_material_controller.dart';
import 'package:erp_frontend/app/modules/staff/models/staff_study_material_models.dart';
import 'package:erp_frontend/app/modules/staff/utils/staff_study_material_visuals.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffStudyMaterialComposeView extends StatefulWidget {
  const StaffStudyMaterialComposeView({super.key});

  @override
  State<StaffStudyMaterialComposeView> createState() =>
      _StaffStudyMaterialComposeViewState();
}

class _StaffStudyMaterialComposeViewState
    extends State<StaffStudyMaterialComposeView> {
  late final StaffStudyMaterialController controller;
  late final StaffStudyMaterialCategory category;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  String _selectedClassId = '';
  String _selectedSubjectId = '';

  @override
  void initState() {
    super.initState();
    controller = Get.find<StaffStudyMaterialController>();
    final rawArgs = (Get.arguments as Map?)?.cast<String, dynamic>() ?? const {};
    category = StaffStudyMaterialCategoryX.fromValue(
      (rawArgs['category'] ?? 'notes').toString(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.classOptions.isEmpty || controller.subjectOptions.isEmpty) {
        controller.loadInitialData(showErrors: true);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = staffStudyMaterialColor(category);
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
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
                    child: Icon(
                      staffStudyMaterialIcon(category),
                      color: color,
                    ),
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
                          staffStudyMaterialHelperText(category),
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
                    'Publish ${category.singularLabel}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: '${category.singularLabel} title',
                      hintText: _hintTitle(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _urlController,
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                      labelText: '${category.singularLabel} URL',
                      hintText: _hintUrl(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedClassId,
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
                    value: _selectedSubjectId,
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
                      'This flow publishes the ${category.singularLabel.toLowerCase()} as a live study material record for staff and students to access.',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: controller.isPublishing.value ? null : _publishMaterial,
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
                      ? 'Publishing...'
                      : 'Publish ${category.singularLabel}',
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
      url: _urlController.text,
      classId: _selectedClassId,
      subjectId: _selectedSubjectId,
    );
    if (created && mounted) {
      Get.back(result: true);
    }
  }

  String _hintTitle() {
    switch (category) {
      case StaffStudyMaterialCategory.notes:
        return 'Chapter 4 revision notes';
      case StaffStudyMaterialCategory.videos:
        return 'Trigonometry explanation video';
      case StaffStudyMaterialCategory.pdfs:
        return 'Unit test question bank PDF';
      case StaffStudyMaterialCategory.resources:
        return 'Interactive grammar practice resource';
    }
  }

  String _hintUrl() {
    switch (category) {
      case StaffStudyMaterialCategory.notes:
        return 'https://drive.google.com/...';
      case StaffStudyMaterialCategory.videos:
        return 'https://youtu.be/...';
      case StaffStudyMaterialCategory.pdfs:
        return 'https://example.com/material.pdf';
      case StaffStudyMaterialCategory.resources:
        return 'https://example.com/learning-resource';
    }
  }
}
