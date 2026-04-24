import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/fonts/common_textstyle.dart';
import '../../../common/theme/app_color.dart';
import '../../../common/utils/responsive.dart';
import '../../../widgets/app_scaffold.dart';
import 'student_exams_controller.dart';

class StudentExamsScreen extends GetView<StudentExamsController> {
  const StudentExamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Exam Center',
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              Responsive.w(context, 16),
              Responsive.h(context, 14),
              Responsive.w(context, 16),
              Responsive.h(context, 10),
            ),
            child: Column(
              children: [
                _buildHeader(context),
                SizedBox(height: Responsive.h(context, 12)),
                _buildSearchField(context),
                SizedBox(height: Responsive.h(context, 10)),
                _buildTabs(context),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              switch (controller.selectedTab.value) {
                case 1:
                  return _ResultsTab(controller: controller);
                case 2:
                  return _ReportCardsTab(controller: controller);
                case 3:
                  return _SubjectPerformanceTab(controller: controller);
                case 4:
                  return _GradeHistoryTab(controller: controller);
                default:
                  return _ScheduleTab(controller: controller);
              }
            }),
          ),
        ],
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
              Icons.school_rounded,
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
                  'Exam, Results, Report Cards',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 17),
                    fontWeight: FontWeight.w700,
                    color: AppColor.base,
                  ),
                ),
                SizedBox(height: Responsive.h(context, 4)),
                Text(
                  'Schedule to grade history in one place',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

  Widget _buildSearchField(BuildContext context) {
    return TextField(
      onChanged: controller.setSearchQuery,
      decoration: InputDecoration(
        hintText: 'Search by subject, exam, or grade',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: AppColor.base,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
          borderSide: BorderSide(color: AppColor.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
          borderSide: BorderSide(color: AppColor.border),
        ),
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    const tabs = [
      'Exam Schedule',
      'Marks View',
      'Report Cards',
      'Subject Performance',
      'Grade History',
    ];
    return SizedBox(
      height: Responsive.h(context, 36),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => SizedBox(width: Responsive.w(context, 8)),
        itemBuilder: (context, index) {
          return Obx(() {
            final active = controller.selectedTab.value == index;
            return InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => controller.setTab(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(context, 14),
                  vertical: Responsive.h(context, 8),
                ),
                decoration: BoxDecoration(
                  color: active ? AppColor.primary : AppColor.cardBackground,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  tabs[index],
                  style: AppTextStyle.bodySmall(context).copyWith(
                    color: active ? AppColor.base : AppColor.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }
}

class _ScheduleTab extends StatelessWidget {
  const _ScheduleTab({required this.controller});
  final StudentExamsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final exams = controller.filteredUpcoming;
      if (exams.isEmpty) return const _EmptyState(text: 'No upcoming exams');
      return ListView.builder(
        padding: EdgeInsets.fromLTRB(
          Responsive.w(context, 16),
          0,
          Responsive.w(context, 16),
          Responsive.h(context, 16),
        ),
        itemCount: exams.length,
        itemBuilder: (context, index) {
          final exam = exams[index];
          return Container(
            margin: EdgeInsets.only(bottom: Responsive.h(context, 10)),
            padding: EdgeInsets.all(Responsive.w(context, 14)),
            decoration: BoxDecoration(
              color: AppColor.base,
              borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
              border: Border.all(color: AppColor.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam.subject,
                  style: AppTextStyle.titleMedium(context).copyWith(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: Responsive.h(context, 6)),
                Text(
                  _formatDate(exam.date),
                  style: AppTextStyle.bodySmall(context).copyWith(color: AppColor.textSecondary),
                ),
                if (exam.time != null) ...[
                  SizedBox(height: Responsive.h(context, 4)),
                  Text('Time: ${exam.time}', style: AppTextStyle.caption(context)),
                ],
                if (exam.syllabus != null && exam.syllabus!.isNotEmpty) ...[
                  SizedBox(height: Responsive.h(context, 4)),
                  Text('Syllabus: ${exam.syllabus}', style: AppTextStyle.caption(context)),
                ],
              ],
            ),
          );
        },
      );
    });
  }
}

class _ResultsTab extends StatelessWidget {
  const _ResultsTab({required this.controller});
  final StudentExamsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final results = controller.filteredPast;
      if (results.isEmpty) return const _EmptyState(text: 'No results found');
      return ListView.builder(
        padding: EdgeInsets.fromLTRB(
          Responsive.w(context, 16),
          0,
          Responsive.w(context, 16),
          Responsive.h(context, 16),
        ),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final item = results[index];
          return _CardShell(
            child: Row(
              children: [
                _scoreChip(context, item.percentage),
                SizedBox(width: Responsive.w(context, 12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.subject, style: AppTextStyle.titleMedium(context).copyWith(fontWeight: FontWeight.w700)),
                      SizedBox(height: Responsive.h(context, 4)),
                      Text(item.examName, style: AppTextStyle.bodySmall(context)),
                      SizedBox(height: Responsive.h(context, 4)),
                      Text(
                        '${item.marksObtained.toInt()}/${item.maxMarks.toInt()}${item.grade == null ? '' : ' • Grade ${item.grade}'}',
                        style: AppTextStyle.caption(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _scoreChip(BuildContext context, double pct) {
    final color = pct >= 80
        ? AppColor.success
        : pct >= 65
            ? AppColor.primary
            : pct >= 40
                ? AppColor.orange
                : AppColor.error;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(context, 12),
        vertical: Responsive.h(context, 8),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
      ),
      child: Text(
        '${pct.toStringAsFixed(0)}%',
        style: AppTextStyle.titleSmall(context).copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ReportCardsTab extends StatelessWidget {
  const _ReportCardsTab({required this.controller});
  final StudentExamsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cards = controller.reportCards;
      if (cards.isEmpty) return const _EmptyState(text: 'No report cards yet');
      return ListView.builder(
        padding: EdgeInsets.fromLTRB(
          Responsive.w(context, 16),
          0,
          Responsive.w(context, 16),
          Responsive.h(context, 16),
        ),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final item = cards[index];
          return _CardShell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item.term} (${item.academicYear})',
                        style: AppTextStyle.titleMedium(context).copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.w(context, 10),
                        vertical: Responsive.h(context, 6),
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${item.overallPercentage.toStringAsFixed(1)}% • ${item.overallGrade}',
                        style: AppTextStyle.caption(context).copyWith(
                          color: AppColor.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(context, 8)),
                Text(
                  'Published: ${_formatDate(item.publishedOn)}',
                  style: AppTextStyle.bodySmall(context),
                ),
                SizedBox(height: Responsive.h(context, 8)),
                OutlinedButton.icon(
                  onPressed: () {
                    Get.snackbar('Report Card', 'Opening ${item.pdfName}');
                  },
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  label: Text(item.pdfName, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}

class _SubjectPerformanceTab extends StatelessWidget {
  const _SubjectPerformanceTab({required this.controller});
  final StudentExamsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.subjectPerformance;
      if (items.isEmpty) return const _EmptyState(text: 'No subject performance data');
      return ListView.builder(
        padding: EdgeInsets.fromLTRB(
          Responsive.w(context, 16),
          0,
          Responsive.w(context, 16),
          Responsive.h(context, 16),
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _CardShell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.subject,
                        style: AppTextStyle.titleMedium(context).copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      'Grade ${item.currentGrade}',
                      style: AppTextStyle.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColor.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(context, 8)),
                LinearProgressIndicator(
                  value: (item.averagePercentage / 100).clamp(0, 1),
                  backgroundColor: AppColor.border.withValues(alpha: 0.5),
                  color: AppColor.primary,
                ),
                SizedBox(height: Responsive.h(context, 6)),
                Text(
                  '${item.averagePercentage.toStringAsFixed(1)}% average • ${item.examsTaken} exams',
                  style: AppTextStyle.caption(context),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}

class _GradeHistoryTab extends StatelessWidget {
  const _GradeHistoryTab({required this.controller});
  final StudentExamsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final history = controller.gradeHistory;
      if (history.isEmpty) return const _EmptyState(text: 'No grade history available');
      return ListView.builder(
        padding: EdgeInsets.fromLTRB(
          Responsive.w(context, 16),
          0,
          Responsive.w(context, 16),
          Responsive.h(context, 16),
        ),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];
          return _CardShell(
            child: Row(
              children: [
                SizedBox(
                  width: Responsive.w(context, 88),
                  child: Text(
                    _formatDate(item.date),
                    style: AppTextStyle.caption(context),
                  ),
                ),
                SizedBox(width: Responsive.w(context, 10)),
                Expanded(
                  child: Text(
                    '${item.subject} • ${item.examName}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.bodySmall(context),
                  ),
                ),
                SizedBox(width: Responsive.w(context, 10)),
                Text(
                  item.grade ?? '${item.percentage.toStringAsFixed(0)}%',
                  style: AppTextStyle.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColor.primary,
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.h(context, 10)),
      padding: EdgeInsets.all(Responsive.w(context, 14)),
      decoration: BoxDecoration(
        color: AppColor.base,
        borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
        border: Border.all(color: AppColor.border),
      ),
      child: child,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Responsive.w(context, 24)),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyle.bodyMedium(context).copyWith(color: AppColor.textMuted),
        ),
      ),
    );
  }
}

String _formatDate(DateTime d) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}
