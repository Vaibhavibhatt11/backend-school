import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/core/widgets/custom_app_bar.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_study_material_controller.dart';
import 'package:erp_frontend/app/modules/admin/models/admin_study_material_models.dart';
import 'package:erp_frontend/app/modules/admin/utils/admin_study_material_visuals.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminStudyMaterialLibraryView extends StatefulWidget {
  const AdminStudyMaterialLibraryView({super.key});

  @override
  State<AdminStudyMaterialLibraryView> createState() =>
      _AdminStudyMaterialLibraryViewState();
}

class _AdminStudyMaterialLibraryViewState
    extends State<AdminStudyMaterialLibraryView> {
  late final AdminStudyMaterialController controller;
  late final AdminStudyMaterialCategory category;
  final TextEditingController _searchController = TextEditingController();
  String _selectedClassId = '';
  String _selectedSubjectId = '';

  @override
  void initState() {
    super.initState();
    controller = Get.find<AdminStudyMaterialController>();
    final rawArgs = (Get.arguments as Map?)?.cast<String, dynamic>() ?? const {};
    category = AdminStudyMaterialCategoryX.fromValue(
      (rawArgs['category'] ?? 'notes').toString(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.materials.isEmpty ||
          controller.classOptions.isEmpty ||
          controller.subjectOptions.isEmpty) {
        controller.loadInitialData(showErrors: true);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = adminStudyMaterialColor(category);
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: CustomAppBar(
        title: category.title,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => controller.loadMaterials(showErrors: true),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openComposer,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded),
        label: Text('Add ${category.singularLabel}'),
      ),
      body: Obx(() {
        final items = controller.materialsForCategory(
          category,
          query: _searchController.text,
          classId: _selectedClassId,
          subjectId: _selectedSubjectId,
        );

        return RefreshIndicator(
          onRefresh: () => controller.loadInitialData(showErrors: false),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
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
                                category.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? AppColors.textDark
                                      : AppColors.textLight,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                adminStudyMaterialDescription(category),
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
                    const SizedBox(height: 14),
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search title, class, or subject',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchController.text.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.close_rounded),
                              ),
                        filled: true,
                        fillColor:
                            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedClassId,
                            decoration: const InputDecoration(
                              labelText: 'Class filter',
                            ),
                            items: [
                              const DropdownMenuItem<String>(
                                value: '',
                                child: Text('All classes'),
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
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedSubjectId,
                            decoration: const InputDecoration(
                              labelText: 'Subject filter',
                            ),
                            items: [
                              const DropdownMenuItem<String>(
                                value: '',
                                child: Text('All subjects'),
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
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (controller.isLoading.value && controller.materials.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (items.isEmpty)
                _EmptyLibraryState(
                  label: adminStudyMaterialEmptyLabel(category),
                  ctaLabel: 'Add ${category.singularLabel}',
                  onTap: _openComposer,
                )
              else
                ...items.map(
                  (item) => _MaterialCard(
                    item: item,
                    onTap: () async {
                      final result = await Get.toNamed<bool>(
                        AppRoutes.ADMIN_STUDY_MATERIAL_DETAIL,
                        arguments: {'materialId': item.id},
                      );
                      if (result == true && mounted) {
                        setState(() {});
                      }
                    },
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _openComposer() async {
    final result = await Get.toNamed<bool>(
      AppRoutes.ADMIN_STUDY_MATERIAL_COMPOSER,
      arguments: {'category': category.value},
    );
    if (result == true && mounted) {
      setState(() {});
    }
  }
}

class _MaterialCard extends StatelessWidget {
  const _MaterialCard({required this.item, required this.onTap});

  final AdminStudyMaterialRecord item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = adminStudyMaterialColor(item.category);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(adminStudyMaterialIcon(item.category), color: color),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            if (item.subtitleParts.isNotEmpty)
              Text(
                item.subtitleParts,
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Pill(label: item.type.toUpperCase(), color: color),
                _Pill(
                  label: item.isPublished ? 'PUBLISHED' : 'DRAFT',
                  color: item.isPublished ? Colors.green : Colors.orange,
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

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

class _EmptyLibraryState extends StatelessWidget {
  const _EmptyLibraryState({
    required this.label,
    required this.ctaLabel,
    required this.onTap,
  });

  final String label;
  final String ctaLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(22),
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
          Text(
            label,
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: onTap,
            child: Text(ctaLabel),
          ),
        ],
      ),
    );
  }
}

