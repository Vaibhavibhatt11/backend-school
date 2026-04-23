import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/fonts/common_textstyle.dart';
import '../../../common/theme/app_color.dart';
import '../../../common/utils/responsive.dart';
import '../../../widgets/app_scaffold.dart';
import 'models/study_material_models.dart';
import 'student_ai_learning_tools_screen.dart';
import 'student_study_material_detail_screen.dart';
import 'student_study_materials_controller.dart';

class StudentStudyMaterialsScreen
    extends GetView<StudentStudyMaterialsController> {
  const StudentStudyMaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Study Materials',
      body: Obx(
        () => RefreshIndicator(
          onRefresh: () => controller.loadMaterials(showErrors: false),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(Responsive.w(context, 16)),
            children: [
              _buildHeader(context),
              SizedBox(height: Responsive.h(context, 18)),
              _buildSearchField(context),
              SizedBox(height: Responsive.h(context, 16)),
              _buildFilterChips(context),
              SizedBox(height: Responsive.h(context, 18)),
              _buildSummaryCards(context),
              SizedBox(height: Responsive.h(context, 20)),
              _buildAiToolsSection(context),
              SizedBox(height: Responsive.h(context, 20)),
              _buildSectionTitle(context),
              SizedBox(height: Responsive.h(context, 12)),
              _buildMaterialBody(context),
              SizedBox(height: Responsive.h(context, 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(context, 18)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.primary,
            AppColor.primaryDark.withValues(alpha: 0.94),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(Responsive.w(context, 22)),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withValues(alpha: 0.24),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(Responsive.w(context, 12)),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: Responsive.w(context, 28),
            ),
          ),
          SizedBox(width: Responsive.w(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Study Material Library',
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 18),
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: Responsive.h(context, 4)),
                Text(
                  'Browse published notes, videos, PDFs, and learning resources.',
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 13),
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.base,
        borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
        border: Border.all(color: AppColor.borderLight),
      ),
      child: TextField(
        onChanged: controller.setSearchQuery,
        decoration: InputDecoration(
          hintText: 'Search by title, subject, class, or source',
          hintStyle: TextStyle(
            color: AppColor.textMuted,
            fontSize: Responsive.sp(context, 13),
          ),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColor.primary),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: Responsive.w(context, 14),
            vertical: Responsive.h(context, 14),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: StudyMaterialCategory.values.map((category) {
          final selected = controller.selectedCategory.value == category;
          final color = _colorForCategory(category);
          return Padding(
            padding: EdgeInsets.only(right: Responsive.w(context, 10)),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.setCategory(category),
                borderRadius: BorderRadius.circular(Responsive.w(context, 20)),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(context, 16),
                    vertical: Responsive.h(context, 12),
                  ),
                  decoration: BoxDecoration(
                    color: selected ? color : AppColor.base,
                    borderRadius: BorderRadius.circular(
                      Responsive.w(context, 20),
                    ),
                    border: Border.all(
                      color: selected ? color : AppColor.borderLight,
                    ),
                  ),
                  child: Text(
                    category.label,
                    style: AppTextStyle.titleSmall(context).copyWith(
                      color: selected ? Colors.white : AppColor.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    final categories = [
      StudyMaterialCategory.all,
      StudyMaterialCategory.notes,
      StudyMaterialCategory.videos,
      StudyMaterialCategory.pdfs,
      StudyMaterialCategory.resources,
      StudyMaterialCategory.chapterResources,
    ];
    return Wrap(
      spacing: Responsive.w(context, 10),
      runSpacing: Responsive.h(context, 10),
      children: categories.map((category) {
        final count = controller.countForCategory(category);
        final color = _colorForCategory(category);
        return Container(
          width: Responsive.w(context, 108),
          padding: EdgeInsets.all(Responsive.w(context, 14)),
          decoration: BoxDecoration(
            color: AppColor.base,
            borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
            border: Border.all(color: color.withValues(alpha: 0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category == StudyMaterialCategory.all
                    ? 'Total'
                    : category.label,
                style: AppTextStyle.caption(context).copyWith(
                  color: AppColor.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: Responsive.h(context, 8)),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: Responsive.sp(context, 22),
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: Responsive.h(context, 24),
          decoration: BoxDecoration(
            color: AppColor.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: Responsive.w(context, 12)),
        Text(
          'Lecture Materials',
          style: AppTextStyle.titleLarge(
            context,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildAiToolsSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(context, 14)),
      decoration: BoxDecoration(
        color: AppColor.base,
        borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
        border: Border.all(color: AppColor.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Learning Assistant',
            style: AppTextStyle.titleMedium(context).copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: Responsive.h(context, 4)),
          Text(
            'Explain math problems, summarize chapters, solve doubts, and create quiz/paper.',
            style: AppTextStyle.bodySmall(context).copyWith(color: AppColor.textSecondary),
          ),
          SizedBox(height: Responsive.h(context, 10)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Get.to(
                () => StudentAiLearningToolsScreen(items: controller.materials.toList()),
              ),
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('Open AI Student Assistant'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialBody(BuildContext context) {
    final list = controller.filteredMaterials;
    if (controller.isLoading.value && controller.materials.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 36)),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.errorMessage.value.isNotEmpty &&
        controller.materials.isEmpty) {
      return _StateCard(
        icon: Icons.error_outline_rounded,
        title: 'Unable to load study materials',
        message: controller.errorMessage.value,
      );
    }

    if (list.isEmpty) {
      return _StateCard(
        icon: Icons.folder_open_rounded,
        title: 'Nothing to show',
        message: controller.selectedCategory.value.emptyLabel,
      );
    }

    return Column(
      children: list
          .map(
            (item) => _MaterialCard(
              item: item,
              onOpen: () =>
                  Get.to(() => StudentStudyMaterialDetailScreen(item: item)),
            ),
          )
          .toList(),
    );
  }

  static Color _colorForCategory(StudyMaterialCategory category) {
    switch (category) {
      case StudyMaterialCategory.all:
        return AppColor.primary;
      case StudyMaterialCategory.notes:
        return AppColor.primary;
      case StudyMaterialCategory.videos:
        return AppColor.orange;
      case StudyMaterialCategory.pdfs:
        return AppColor.error;
      case StudyMaterialCategory.resources:
        return AppColor.info;
      case StudyMaterialCategory.chapterResources:
        return AppColor.success;
    }
  }
}

class _MaterialCard extends StatelessWidget {
  const _MaterialCard({required this.item, required this.onOpen});

  final StudyMaterialItem item;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final color = _colorForCategory(item.category);
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.h(context, 12)),
      decoration: BoxDecoration(
        color: AppColor.base,
        borderRadius: BorderRadius.circular(Responsive.w(context, 18)),
        border: Border.all(color: color.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(Responsive.w(context, 18)),
          child: Padding(
            padding: EdgeInsets.all(Responsive.w(context, 16)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(Responsive.w(context, 12)),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(
                      Responsive.w(context, 14),
                    ),
                  ),
                  child: Icon(
                    _iconForCategory(item.category),
                    color: color,
                    size: Responsive.w(context, 28),
                  ),
                ),
                SizedBox(width: Responsive.w(context, 14)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: Responsive.w(context, 8),
                        runSpacing: Responsive.h(context, 8),
                        children: [
                          _CategoryPill(
                            label: item.category.label.toUpperCase(),
                            color: color,
                          ),
                          _CategoryPill(
                            label: item.hostLabel.toUpperCase(),
                            color: AppColor.primary,
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.h(context, 10)),
                      Text(
                        item.title,
                        style: AppTextStyle.titleMedium(
                          context,
                        ).copyWith(fontWeight: FontWeight.w700),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.subtitle.isNotEmpty) ...[
                        SizedBox(height: Responsive.h(context, 6)),
                        Text(
                          item.subtitle,
                          style: AppTextStyle.bodySmall(context).copyWith(
                            color: AppColor.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if (item.description.isNotEmpty) ...[
                        SizedBox(height: Responsive.h(context, 8)),
                        Text(
                          item.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.bodyMedium(context).copyWith(
                            color: AppColor.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: Responsive.w(context, 12)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(context, 14),
                    vertical: Responsive.h(context, 10),
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(
                      Responsive.w(context, 12),
                    ),
                    border: Border.all(
                      color: AppColor.primary.withValues(alpha: 0.28),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.open_in_new_rounded,
                        size: Responsive.w(context, 18),
                        color: AppColor.primary,
                      ),
                      SizedBox(width: Responsive.w(context, 6)),
                      Text(
                        'Open',
                        style: TextStyle(
                          fontSize: Responsive.sp(context, 13),
                          fontWeight: FontWeight.w700,
                          color: AppColor.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Color _colorForCategory(StudyMaterialCategory category) {
    switch (category) {
      case StudyMaterialCategory.all:
        return AppColor.primary;
      case StudyMaterialCategory.notes:
        return AppColor.primary;
      case StudyMaterialCategory.videos:
        return AppColor.orange;
      case StudyMaterialCategory.pdfs:
        return AppColor.error;
      case StudyMaterialCategory.resources:
        return AppColor.info;
      case StudyMaterialCategory.chapterResources:
        return AppColor.success;
    }
  }

  static IconData _iconForCategory(StudyMaterialCategory category) {
    switch (category) {
      case StudyMaterialCategory.all:
      case StudyMaterialCategory.notes:
        return Icons.sticky_note_2_rounded;
      case StudyMaterialCategory.videos:
        return Icons.play_circle_fill_rounded;
      case StudyMaterialCategory.pdfs:
        return Icons.picture_as_pdf_rounded;
      case StudyMaterialCategory.resources:
        return Icons.link_rounded;
      case StudyMaterialCategory.chapterResources:
        return Icons.topic_rounded;
    }
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(context, 8),
        vertical: Responsive.h(context, 4),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Responsive.w(context, 999)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: Responsive.sp(context, 10),
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(context, 20)),
      decoration: BoxDecoration(
        color: AppColor.base,
        borderRadius: BorderRadius.circular(Responsive.w(context, 18)),
        border: Border.all(color: AppColor.borderLight),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: Responsive.w(context, 42),
            color: AppColor.textMuted,
          ),
          SizedBox(height: Responsive.h(context, 12)),
          Text(
            title,
            style: AppTextStyle.titleMedium(
              context,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: Responsive.h(context, 8)),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyle.bodyMedium(
              context,
            ).copyWith(color: AppColor.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }
}
