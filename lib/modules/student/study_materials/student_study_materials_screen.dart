import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/theme/app_color.dart';
import '../../../common/fonts/common_textstyle.dart';
import '../../../common/utils/responsive.dart';
import '../../../widgets/app_scaffold.dart';
import 'models/study_material_models.dart';
import 'student_study_materials_controller.dart';

class StudentStudyMaterialsScreen extends GetView<StudentStudyMaterialsController> {
  const StudentStudyMaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Study Materials',
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.w(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            SizedBox(height: Responsive.h(context, 20)),
            _buildFilterChips(context),
            SizedBox(height: Responsive.h(context, 20)),
            _buildSectionTitle(context),
            SizedBox(height: Responsive.h(context, 12)),
            _buildMaterialList(context),
            SizedBox(height: Responsive.h(context, 24)),
          ],
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
            AppColor.primaryDark.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(Responsive.w(context, 20)),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(Responsive.w(context, 12)),
            decoration: BoxDecoration(
              color: AppColor.base.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              color: AppColor.base,
              size: Responsive.w(context, 28),
            ),
          ),
          SizedBox(width: Responsive.w(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notes, PDFs & slides',
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 18),
                    fontWeight: FontWeight.w700,
                    color: AppColor.base,
                  ),
                ),
                SizedBox(height: Responsive.h(context, 4)),
                Text(
                  'Open and read PDF, PPT & images',
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 13),
                    color: AppColor.base.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(() {
        return Row(
          children: StudentStudyMaterialsController.categories.map((cat) {
            final selected = controller.selectedCategory.value == cat;
            return Padding(
              padding: EdgeInsets.only(right: Responsive.w(context, 10)),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => controller.setCategory(cat),
                  borderRadius: BorderRadius.circular(Responsive.w(context, 20)),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.w(context, 18),
                      vertical: Responsive.h(context, 12),
                    ),
                    decoration: BoxDecoration(
                      gradient: selected
                          ? LinearGradient(
                              colors: [
                                AppColor.primary,
                                AppColor.primaryDark.withValues(alpha: 0.9),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: selected ? null : AppColor.cardBackground,
                      borderRadius: BorderRadius.circular(Responsive.w(context, 20)),
                      border: Border.all(
                        color: selected ? AppColor.primary : AppColor.borderLight,
                        width: 1.5,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: AppColor.primary.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      cat,
                      style: AppTextStyle.titleSmall(context).copyWith(
                        color: selected ? AppColor.base : AppColor.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }),
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
          'Materials',
          style: AppTextStyle.titleLarge(context).copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialList(BuildContext context) {
    return Obx(() {
      final list = controller.filteredMaterials;
      if (list.isEmpty) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 40)),
          alignment: Alignment.center,
          child: Column(
            children: [
              Icon(
                Icons.folder_open_rounded,
                size: Responsive.w(context, 56),
                color: AppColor.textMuted.withValues(alpha: 0.6),
              ),
              SizedBox(height: Responsive.h(context, 12)),
              Text(
                'No materials in this category',
                style: AppTextStyle.bodyMedium(context).copyWith(
                  color: AppColor.textMuted,
                ),
              ),
            ],
          ),
        );
      }
      return Column(
        children: list.map((item) => _MaterialCard(
          item: item,
          onOpen: () => controller.openMaterial(item),
        )).toList(),
      );
    });
  }
}

class _MaterialCard extends StatelessWidget {
  const _MaterialCard({required this.item, required this.onOpen});
  final StudyMaterialItem item;
  final VoidCallback onOpen;

  static Color _colorForType(StudyMaterialFileType t) {
    switch (t) {
      case StudyMaterialFileType.pdf:
        return AppColor.error;
      case StudyMaterialFileType.ppt:
        return AppColor.orange;
      case StudyMaterialFileType.image:
        return AppColor.info;
    }
  }

  static IconData _iconForType(StudyMaterialFileType t) {
    switch (t) {
      case StudyMaterialFileType.pdf:
        return Icons.picture_as_pdf_rounded;
      case StudyMaterialFileType.ppt:
        return Icons.slideshow_rounded;
      case StudyMaterialFileType.image:
        return Icons.image_rounded;
    }
  }

  static String _labelForType(StudyMaterialFileType t) {
    return t.name.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForType(item.type);
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.h(context, 12)),
      decoration: BoxDecoration(
        color: AppColor.base,
        borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
        border: Border.all(color: color.withValues(alpha: 0.25)),
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
          borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
          child: Padding(
            padding: EdgeInsets.all(Responsive.w(context, 16)),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(Responsive.w(context, 12)),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
                  ),
                  child: Icon(
                    _iconForType(item.type),
                    color: color,
                    size: Responsive.w(context, 28),
                  ),
                ),
                SizedBox(width: Responsive.w(context, 14)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.w(context, 8),
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _labelForType(item.type),
                          style: TextStyle(
                            fontSize: Responsive.sp(context, 10),
                            fontWeight: FontWeight.w700,
                            color: color,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      SizedBox(height: Responsive.h(context, 8)),
                      Text(
                        item.title,
                        style: AppTextStyle.titleMedium(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.subject != null) ...[
                        SizedBox(height: Responsive.h(context, 4)),
                        Text(
                          item.subject!,
                          style: AppTextStyle.caption(context).copyWith(
                            color: AppColor.primary,
                            fontWeight: FontWeight.w600,
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
                    borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
                    border: Border.all(color: AppColor.primary.withValues(alpha: 0.4)),
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
}
