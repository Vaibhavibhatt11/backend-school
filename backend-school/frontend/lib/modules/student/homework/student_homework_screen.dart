import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../../common/theme/app_color.dart';
import '../../../common/fonts/common_textstyle.dart';
import '../../../common/utils/responsive.dart';
import '../../../widgets/app_scaffold.dart';
import 'models/homework_item.dart';
import 'student_homework_controller.dart';

class StudentHomeworkScreen extends GetView<StudentHomeworkController> {
  const StudentHomeworkScreen({super.key});

  static const List<String> _viewModes = ['By date', 'By week', 'By subject'];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Homework',
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.w(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ViewModeChips(controller: controller),
            SizedBox(height: Responsive.h(context, 20)),
            Obx(() {
              final mode = controller.viewMode.value;
              if (mode == 'week') {
                return _WeekView(controller: controller);
              }
              if (mode == 'subject') {
                return _SubjectView(controller: controller);
              }
              return _DateView(controller: controller);
            }),
            SizedBox(height: Responsive.h(context, 24)),
          ],
        ),
      ),
    );
  }
}

class _ViewModeChips extends StatelessWidget {
  const _ViewModeChips({required this.controller});
  final StudentHomeworkController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.viewMode.value;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: StudentHomeworkScreen._viewModes.map((label) {
            final key = label.toLowerCase().replaceAll(' ', '_').replaceAll('by_', '');
            final isSelected = selected == key;
            return Padding(
              padding: EdgeInsets.only(right: Responsive.w(context, 10)),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => controller.setViewMode(key),
                  borderRadius: BorderRadius.circular(Responsive.w(context, 20)),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.w(context, 16),
                      vertical: Responsive.h(context, 10),
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColor.primary : AppColor.cardBackground,
                      borderRadius: BorderRadius.circular(Responsive.w(context, 20)),
                      border: Border.all(
                        color: isSelected ? AppColor.primary : AppColor.borderLight,
                      ),
                    ),
                    child: Text(
                      label,
                      style: AppTextStyle.titleSmall(context).copyWith(
                        color: isSelected ? AppColor.base : AppColor.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}

class _DateView extends StatelessWidget {
  const _DateView({required this.controller});
  final StudentHomeworkController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final byDate = controller.homeworkByDate;
      if (byDate.isEmpty) {
        return _EmptyState();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: byDate.entries.map((e) {
          final dateLabel = controller.dateKeyToLabel(e.key);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                title: dateLabel,
                count: e.value.length,
              ),
              SizedBox(height: Responsive.h(context, 8)),
              ...e.value.map((h) => _HomeworkCard(item: h, controller: controller)),
              SizedBox(height: Responsive.h(context, 16)),
            ],
          );
        }).toList(),
      );
    });
  }
}

class _WeekView extends StatelessWidget {
  const _WeekView({required this.controller});
  final StudentHomeworkController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final byWeek = controller.homeworkByWeek;
      if (byWeek.isEmpty) {
        return _EmptyState();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: byWeek.entries.map((e) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(title: e.key, count: e.value.length),
              SizedBox(height: Responsive.h(context, 8)),
              ...e.value.map((h) => _HomeworkCard(item: h, controller: controller)),
              SizedBox(height: Responsive.h(context, 16)),
            ],
          );
        }).toList(),
      );
    });
  }
}

class _SubjectView extends StatelessWidget {
  const _SubjectView({required this.controller});
  final StudentHomeworkController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bySubject = controller.homeworkBySubject;
      if (bySubject.isEmpty) {
        return _EmptyState();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: bySubject.entries.map((e) {
          final color = controller.colorForSubject(e.key);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: Responsive.w(context, 4),
                  bottom: Responsive.h(context, 8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: Responsive.h(context, 20),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: Responsive.w(context, 10)),
                    Text(
                      e.key,
                      style: AppTextStyle.titleLarge(context).copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: Responsive.w(context, 8)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.w(context, 8),
                        vertical: Responsive.h(context, 2),
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(Responsive.w(context, 10)),
                      ),
                      child: Text(
                        '${e.value.length}',
                        style: AppTextStyle.caption(context).copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...e.value.map((h) => _HomeworkCard(item: h, controller: controller)),
              SizedBox(height: Responsive.h(context, 20)),
            ],
          );
        }).toList(),
      );
    });
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: AppTextStyle.titleMedium(context).copyWith(
            color: AppColor.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(width: Responsive.w(context, 8)),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(context, 8),
            vertical: Responsive.h(context, 2),
          ),
          decoration: BoxDecoration(
            color: AppColor.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(Responsive.w(context, 10)),
          ),
          child: Text(
            '$count',
            style: AppTextStyle.caption(context).copyWith(
              color: AppColor.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeworkCard extends StatelessWidget {
  const _HomeworkCard({required this.item, required this.controller});
  final HomeworkItem item;
  final StudentHomeworkController controller;

  @override
  Widget build(BuildContext context) {
    final subjectColor = controller.colorForSubject(item.subject);
    Color dueColor;
    IconData dueIcon;
    if (item.isOverdue) {
      dueColor = AppColor.error;
      dueIcon = Icons.warning_amber_rounded;
    } else if (item.isDueToday) {
      dueColor = AppColor.orange;
      dueIcon = Icons.today_rounded;
    } else {
      dueColor = AppColor.textSecondary;
      dueIcon = Icons.event_rounded;
    }
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.h(context, 10)),
      child: Material(
        color: AppColor.base,
        borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
        elevation: 0,
        shadowColor: AppColor.black.withValues(alpha: 0.06),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
            border: Border.all(color: AppColor.border.withValues(alpha: 0.8)),
            boxShadow: [
              BoxShadow(
                color: AppColor.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: () => _showHomeworkDetailsSheet(context, item, subjectColor, controller),
            borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
            child: Padding(
              padding: EdgeInsets.all(Responsive.w(context, 14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.w(context, 10),
                          vertical: Responsive.h(context, 4),
                        ),
                        decoration: BoxDecoration(
                          color: subjectColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(Responsive.w(context, 8)),
                        ),
                        child: Text(
                          item.subject,
                          style: AppTextStyle.label(context).copyWith(
                            color: subjectColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.w(context, 8),
                          vertical: Responsive.h(context, 4),
                        ),
                        decoration: BoxDecoration(
                          color: dueColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(Responsive.w(context, 8)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(dueIcon, size: 14, color: dueColor),
                            SizedBox(width: 4),
                            Text(
                              item.dueLabel,
                              style: AppTextStyle.caption(context).copyWith(
                                color: dueColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(context, 10)),
                  Text(
                    item.title,
                    style: AppTextStyle.bodyMedium(context).copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (item.status != HomeworkStatus.pending) ...[
                    SizedBox(height: Responsive.h(context, 8)),
                    Row(
                      children: [
                        Icon(
                          item.status == HomeworkStatus.graded
                              ? Icons.check_circle_rounded
                              : Icons.upload_rounded,
                          size: 14,
                          color: AppColor.tokenGreenFont,
                        ),
                        SizedBox(width: 4),
                        Text(
                          item.status == HomeworkStatus.graded ? 'Graded' : 'Submitted',
                          style: AppTextStyle.caption(context).copyWith(
                            color: AppColor.tokenGreenFont,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void _showHomeworkDetailsSheet(
  BuildContext context,
  HomeworkItem item,
  Color subjectColor,
  StudentHomeworkController controller,
) {
  final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final dueDate = '${item.dueDate.day} ${months[item.dueDate.month - 1]} ${item.dueDate.year}';
  final description = (item.description ?? '').trim().isEmpty
      ? 'No additional description provided by teacher.'
      : item.description!.trim();

  String statusText;
  Color statusColor;
  IconData statusIcon;
  if (item.status == HomeworkStatus.graded) {
    statusText = 'Graded';
    statusColor = AppColor.success;
    statusIcon = Icons.check_circle_rounded;
  } else if (item.status == HomeworkStatus.submitted) {
    statusText = 'Submitted';
    statusColor = AppColor.success;
    statusIcon = Icons.upload_rounded;
  } else {
    statusText = item.isOverdue ? 'Pending • Overdue' : 'Pending';
    statusColor = item.isOverdue ? AppColor.error : AppColor.orange;
    statusIcon = item.isOverdue ? Icons.warning_amber_rounded : Icons.pending_actions_rounded;
  }

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      padding: EdgeInsets.fromLTRB(
        Responsive.w(ctx, 16),
        Responsive.h(ctx, 16),
        Responsive.w(ctx, 16),
        MediaQuery.of(ctx).padding.bottom + Responsive.h(ctx, 16),
      ),
      decoration: BoxDecoration(
        color: AppColor.base,
        borderRadius: BorderRadius.vertical(top: Radius.circular(Responsive.w(ctx, 20))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: Responsive.w(ctx, 38),
              height: 4,
              decoration: BoxDecoration(
                color: AppColor.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: Responsive.h(ctx, 14)),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(ctx, 10),
                  vertical: Responsive.h(ctx, 4),
                ),
                decoration: BoxDecoration(
                  color: subjectColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(Responsive.w(ctx, 8)),
                ),
                child: Text(
                  item.subject,
                  style: AppTextStyle.label(ctx).copyWith(
                    color: subjectColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Icon(statusIcon, size: 18, color: statusColor),
              SizedBox(width: Responsive.w(ctx, 6)),
              Text(
                statusText,
                style: AppTextStyle.bodySmall(ctx).copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(ctx, 12)),
          Text(item.title, style: AppTextStyle.titleLarge(ctx)),
          SizedBox(height: Responsive.h(ctx, 10)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(Responsive.w(ctx, 10)),
            decoration: BoxDecoration(
              color: AppColor.cardBackground,
              borderRadius: BorderRadius.circular(Responsive.w(ctx, 10)),
              border: Border.all(color: AppColor.border.withValues(alpha: 0.8)),
            ),
            child: Row(
              children: [
                Icon(Icons.event_rounded, color: AppColor.primary, size: Responsive.w(ctx, 18)),
                SizedBox(width: Responsive.w(ctx, 8)),
                Expanded(
                  child: Text(
                    'Due: $dueDate (${item.dueLabel})',
                    style: AppTextStyle.bodySmall(ctx),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: Responsive.h(ctx, 12)),
          Text(
            'Homework details',
            style: AppTextStyle.titleSmall(ctx).copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: Responsive.h(ctx, 6)),
          Text(
            description,
            style: AppTextStyle.bodySmall(ctx).copyWith(height: 1.45),
          ),
          SizedBox(height: Responsive.h(ctx, 12)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(Responsive.w(ctx, 10)),
            decoration: BoxDecoration(
              color: AppColor.cardBackground,
              borderRadius: BorderRadius.circular(Responsive.w(ctx, 10)),
              border: Border.all(color: AppColor.border.withValues(alpha: 0.7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deadline',
                  style: AppTextStyle.bodySmall(ctx).copyWith(
                    color: AppColor.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: Responsive.h(ctx, 4)),
                Text(
                  item.isOverdue ? 'Overdue' : item.dueLabel,
                  style: AppTextStyle.bodyMedium(ctx).copyWith(
                    color: item.isOverdue ? AppColor.error : AppColor.primaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (item.submissionFiles.isNotEmpty) ...[
            SizedBox(height: Responsive.h(ctx, 12)),
            Text(
              'Uploaded files',
              style: AppTextStyle.titleSmall(ctx).copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: Responsive.h(ctx, 6)),
            ...item.submissionFiles.map(
              (f) => Padding(
                padding: EdgeInsets.only(bottom: Responsive.h(ctx, 4)),
                child: Text('• $f', style: AppTextStyle.bodySmall(ctx)),
              ),
            ),
          ],
          if (item.aiPlagiarismScore != null) ...[
            SizedBox(height: Responsive.h(ctx, 10)),
            Text(
              'AI plagiarism detection',
              style: AppTextStyle.titleSmall(ctx).copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: Responsive.h(ctx, 6)),
            Text(
              'Score: ${item.aiPlagiarismScore!.toStringAsFixed(1)}%  •  Risk: ${item.aiPlagiarismFlag ?? '-'}',
              style: AppTextStyle.bodySmall(ctx).copyWith(
                color: AppColor.textSecondary,
              ),
            ),
          ],
          if ((item.teacherFeedback ?? '').trim().isNotEmpty) ...[
            SizedBox(height: Responsive.h(ctx, 10)),
            Text(
              'Teacher feedback',
              style: AppTextStyle.titleSmall(ctx).copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: Responsive.h(ctx, 6)),
            Text(
              item.teacherFeedback!,
              style: AppTextStyle.bodySmall(ctx).copyWith(height: 1.45),
            ),
          ],
          SizedBox(height: Responsive.h(ctx, 14)),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Close'),
                ),
              ),
              SizedBox(width: Responsive.w(ctx, 8)),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: item.status == HomeworkStatus.graded
                      ? null
                      : () async {
                          Navigator.of(ctx).pop();
                          await showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (sheetCtx) => _SubmitHomeworkSheet(
                              item: item,
                              controller: controller,
                            ),
                          );
                        },
                  icon: const Icon(Icons.upload_file_rounded),
                  label: Text(item.status == HomeworkStatus.pending ? 'Submit' : 'Resubmit'),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(ctx, 6)),
          Text(
            'Submission supports file upload and photo-to-PDF option.',
            style: AppTextStyle.caption(ctx).copyWith(color: AppColor.textSecondary),
          ),
        ],
      ),
    ),
  );
}

class _SubmitHomeworkSheet extends StatefulWidget {
  const _SubmitHomeworkSheet({required this.item, required this.controller});
  final HomeworkItem item;
  final StudentHomeworkController controller;

  @override
  State<_SubmitHomeworkSheet> createState() => _SubmitHomeworkSheetState();
}

class _SubmitHomeworkSheetState extends State<_SubmitHomeworkSheet> {
  final List<String> _files = [];
  bool _photoToPdf = true;
  bool _isSubmitting = false;

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
    );
    if (result == null) return;
    setState(() {
      _files.addAll(result.files.map((f) => f.name));
    });
  }

  Future<void> _submit() async {
    if (_files.isEmpty) {
      Get.snackbar('Missing files', 'Please upload at least one file.');
      return;
    }
    setState(() => _isSubmitting = true);
    final normalized = _files.map((f) {
      final lower = f.toLowerCase();
      final isPhoto = lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png');
      if (_photoToPdf && isPhoto) {
        return '${f.split('.').first}_converted.pdf';
      }
      return f;
    }).toList();
    await widget.controller.submitHomework(
      homeworkId: widget.item.id,
      files: normalized,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
    Get.snackbar('Submitted', 'Assignment uploaded successfully.');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.base,
        borderRadius: BorderRadius.vertical(top: Radius.circular(Responsive.w(context, 20))),
      ),
      padding: EdgeInsets.fromLTRB(
        Responsive.w(context, 16),
        Responsive.h(context, 16),
        Responsive.w(context, 16),
        MediaQuery.of(context).padding.bottom + Responsive.h(context, 16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Submit Assignment',
            style: AppTextStyle.titleLarge(context).copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: Responsive.h(context, 8)),
          Text(widget.item.title, style: AppTextStyle.bodySmall(context).copyWith(color: AppColor.textSecondary)),
          SizedBox(height: Responsive.h(context, 12)),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Convert photos to PDF'),
            subtitle: const Text('If enabled, JPG/PNG uploads will be submitted as PDF.'),
            value: _photoToPdf,
            onChanged: (v) => setState(() => _photoToPdf = v),
          ),
          SizedBox(height: Responsive.h(context, 6)),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickFiles,
              icon: const Icon(Icons.attach_file_rounded),
              label: const Text('Upload files'),
            ),
          ),
          SizedBox(height: Responsive.h(context, 10)),
          if (_files.isEmpty)
            Text('No files selected yet.', style: AppTextStyle.bodySmall(context).copyWith(color: AppColor.textSecondary))
          else
            ..._files.map((f) => Padding(
                  padding: EdgeInsets.only(bottom: Responsive.h(context, 4)),
                  child: Text('• $f', style: AppTextStyle.bodySmall(context)),
                )),
          SizedBox(height: Responsive.h(context, 14)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(_isSubmitting ? 'Submitting...' : 'Submit assignment'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 40)),
        child: Column(
          children: [
            Icon(
              Icons.assignment_outlined,
              size: Responsive.w(context, 56),
              color: AppColor.textMuted,
            ),
            SizedBox(height: Responsive.h(context, 12)),
            Text(
              'No homework',
              style: AppTextStyle.titleMedium(context).copyWith(color: AppColor.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
