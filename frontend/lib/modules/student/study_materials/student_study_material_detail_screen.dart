import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/fonts/common_textstyle.dart';
import '../../../common/theme/app_color.dart';
import '../../../common/utils/app_toast.dart';
import '../../../common/utils/responsive.dart';
import '../../../widgets/app_scaffold.dart';
import 'models/study_material_models.dart';

class StudentStudyMaterialDetailScreen extends StatelessWidget {
  const StudentStudyMaterialDetailScreen({super.key, required this.item});

  final StudyMaterialItem item;

  @override
  Widget build(BuildContext context) {
    final accent = _colorForCategory(item.category);
    return AppScaffold(
      title: item.category.label,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.w(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
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
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(Responsive.w(context, 12)),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(
                        Responsive.w(context, 16),
                      ),
                    ),
                    child: Icon(
                      _iconForCategory(item.category),
                      color: Colors.white,
                      size: Responsive.w(context, 28),
                    ),
                  ),
                  SizedBox(width: Responsive.w(context, 14)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: Responsive.sp(context, 18),
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: Responsive.h(context, 8)),
                        Wrap(
                          spacing: Responsive.w(context, 8),
                          runSpacing: Responsive.h(context, 8),
                          children: [
                            _DetailChip(
                              label: item.category.label.toUpperCase(),
                              textColor: Colors.white,
                            ),
                            _DetailChip(
                              label: item.subject.isEmpty
                                  ? 'GENERAL SUBJECT'
                                  : item.subject.toUpperCase(),
                              textColor: Colors.white,
                            ),
                            _DetailChip(
                              label: item.classLabel.isEmpty
                                  ? 'ALL CLASSES'
                                  : item.classLabel.toUpperCase(),
                              textColor: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.h(context, 18)),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Material Details',
                    style: AppTextStyle.titleMedium(
                      context,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: Responsive.h(context, 14)),
                  _DetailRow(
                    label: 'Published',
                    value: _formatDate(item.createdAt),
                    accent: accent,
                  ),
                  _DetailRow(
                    label: 'Visibility',
                    value: item.classLabel.isEmpty
                        ? 'All classes'
                        : item.classLabel,
                    accent: accent,
                  ),
                  _DetailRow(
                    label: 'Source',
                    value: item.hostLabel,
                    accent: accent,
                  ),
                  if (item.subject.isNotEmpty)
                    _DetailRow(
                      label: 'Subject',
                      value: item.subject,
                      accent: accent,
                    ),
                ],
              ),
            ),
            if (item.description.isNotEmpty) ...[
              SizedBox(height: Responsive.h(context, 14)),
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: AppTextStyle.titleMedium(
                        context,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: Responsive.h(context, 10)),
                    Text(
                      item.description,
                      style: AppTextStyle.bodyMedium(
                        context,
                      ).copyWith(color: AppColor.textSecondary, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: Responsive.h(context, 14)),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resource Link',
                    style: AppTextStyle.titleMedium(
                      context,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: Responsive.h(context, 10)),
                  Container(
                    padding: EdgeInsets.all(Responsive.w(context, 14)),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(
                        Responsive.w(context, 14),
                      ),
                      border: Border.all(color: accent.withValues(alpha: 0.18)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.link_rounded,
                          color: accent,
                          size: Responsive.w(context, 20),
                        ),
                        SizedBox(width: Responsive.w(context, 10)),
                        Expanded(
                          child: Text(
                            item.url,
                            style: AppTextStyle.bodySmall(
                              context,
                            ).copyWith(color: AppColor.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.h(context, 20)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openMaterial(item.url),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: Responsive.h(context, 14),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      Responsive.w(context, 14),
                    ),
                  ),
                ),
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Open Resource'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openMaterial(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      AppToast.show('Invalid study material link.');
      return;
    }
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      AppToast.show('Could not open this resource.');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
    }
  }

  static Color _colorForCategory(StudyMaterialCategory category) {
    switch (category) {
      case StudyMaterialCategory.all:
      case StudyMaterialCategory.notes:
        return AppColor.primary;
      case StudyMaterialCategory.videos:
        return AppColor.orange;
      case StudyMaterialCategory.pdfs:
        return AppColor.error;
      case StudyMaterialCategory.resources:
        return AppColor.info;
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(context, 16)),
      decoration: BoxDecoration(
        color: AppColor.base,
        borderRadius: BorderRadius.circular(Responsive.w(context, 18)),
        border: Border.all(color: AppColor.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.label, required this.textColor});

  final String label;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(context, 10),
        vertical: Responsive.h(context, 6),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(Responsive.w(context, 999)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: Responsive.sp(context, 11),
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.h(context, 12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: Responsive.w(context, 8),
            height: Responsive.w(context, 8),
            margin: EdgeInsets.only(top: Responsive.h(context, 6)),
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          SizedBox(width: Responsive.w(context, 10)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyle.bodyMedium(
                  context,
                ).copyWith(color: AppColor.textSecondary, height: 1.5),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: AppTextStyle.bodyMedium(context).copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
