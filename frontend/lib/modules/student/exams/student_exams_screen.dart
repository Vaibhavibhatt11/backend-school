import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/theme/app_color.dart';
import '../../../common/fonts/common_textstyle.dart';
import '../../../common/utils/responsive.dart';
import '../../../widgets/app_scaffold.dart';
import 'models/exam_models.dart';
import 'student_exams_controller.dart';

class StudentExamsScreen extends GetView<StudentExamsController> {
  const StudentExamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Exams',
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.w(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            SizedBox(height: Responsive.h(context, 24)),
            _buildSectionTitle(context, 'Upcoming exams', 'Timeline'),
            SizedBox(height: Responsive.h(context, 16)),
            _buildUpcomingTimeline(context),
            SizedBox(height: Responsive.h(context, 24)),
            _buildSectionTitle(context, 'Previous exams & marks', 'Results'),
            SizedBox(height: Responsive.h(context, 16)),
            _buildPastExamsList(context),
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
              Icons.quiz_rounded,
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
                  'Exam schedule & results',
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 18),
                    fontWeight: FontWeight.w700,
                    color: AppColor.base,
                  ),
                ),
                SizedBox(height: Responsive.h(context, 4)),
                Text(
                  'Timeline and marks',
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

  Widget _buildSectionTitle(BuildContext context, String title, String subtitle) {
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyle.titleLarge(context).copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: Responsive.h(context, 2)),
            Text(
              subtitle,
              style: AppTextStyle.caption(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUpcomingTimeline(BuildContext context) {
    return Obx(() {
      final list = controller.upcomingExams;
      if (list.isEmpty) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 24)),
          alignment: Alignment.center,
          child: Text(
            'No upcoming exams',
            style: AppTextStyle.bodyMedium(context).copyWith(
              color: AppColor.textMuted,
            ),
          ),
        );
      }
      return Column(
        children: List.generate(list.length, (i) {
          final exam = list[i];
          final isLast = i == list.length - 1;
          return _TimelineRow(
            exam: exam,
            showLine: !isLast,
          );
        }),
      );
    });
  }

  Widget _buildPastExamsList(BuildContext context) {
    return Obx(() {
      final list = controller.pastExams;
      if (list.isEmpty) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 24)),
          alignment: Alignment.center,
          child: Text(
            'No past exam results',
            style: AppTextStyle.bodyMedium(context).copyWith(
              color: AppColor.textMuted,
            ),
          ),
        );
      }
      return Column(
        children: list.map((exam) => _PastExamCard(exam: exam)).toList(),
      );
    });
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.exam, required this.showLine});
  final UpcomingExam exam;
  final bool showLine;

  static String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: Responsive.w(context, 44),
                height: Responsive.w(context, 44),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColor.primary,
                      AppColor.primaryDark.withValues(alpha: 0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primary.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${exam.date.day}',
                    style: TextStyle(
                      fontSize: Responsive.sp(context, 16),
                      fontWeight: FontWeight.w700,
                      color: AppColor.base,
                    ),
                  ),
                ),
              ),
              if (showLine)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColor.primary.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: Responsive.w(context, 16)),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: Responsive.h(context, 16)),
              padding: EdgeInsets.all(Responsive.w(context, 16)),
              decoration: BoxDecoration(
                color: AppColor.base,
                borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
                border: Border.all(color: AppColor.primary.withValues(alpha: 0.25)),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exam.subject,
                    style: AppTextStyle.titleMedium(context).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: Responsive.h(context, 6)),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: AppColor.textMuted,
                      ),
                      SizedBox(width: Responsive.w(context, 6)),
                      Text(
                        _formatDate(exam.date) + (exam.time != null ? ' • ${exam.time}' : ''),
                        style: AppTextStyle.caption(context),
                      ),
                    ],
                  ),
                  if (exam.syllabus != null && exam.syllabus!.isNotEmpty) ...[
                    SizedBox(height: Responsive.h(context, 6)),
                    Text(
                      'Syllabus: ${exam.syllabus}',
                      style: AppTextStyle.caption(context).copyWith(
                        color: AppColor.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PastExamCard extends StatelessWidget {
  const _PastExamCard({required this.exam});
  final PastExam exam;

  static String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  static Color _colorForPercentage(double pct) {
    if (pct >= 90) return AppColor.success;
    if (pct >= 75) return AppColor.primary;
    if (pct >= 60) return AppColor.info;
    if (pct >= 40) return AppColor.orange;
    return AppColor.error;
  }

  @override
  Widget build(BuildContext context) {
    final pct = exam.percentage;
    final color = _colorForPercentage(pct);
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.h(context, 12)),
      padding: EdgeInsets.all(Responsive.w(context, 16)),
      decoration: BoxDecoration(
        color: AppColor.base,
        borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
        border: Border.all(color: AppColor.border.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: Responsive.w(context, 52),
            height: Responsive.w(context, 52),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${exam.marksObtained.toInt()}/${exam.maxMarks.toInt()}',
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 13),
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                if (exam.grade != null)
                  Text(
                    exam.grade!,
                    style: TextStyle(
                      fontSize: Responsive.sp(context, 11),
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: Responsive.w(context, 14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam.subject,
                  style: AppTextStyle.titleMedium(context).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: Responsive.h(context, 4)),
                Text(
                  exam.examName,
                  style: AppTextStyle.bodySmall(context).copyWith(
                    color: AppColor.textSecondary,
                  ),
                ),
                SizedBox(height: Responsive.h(context, 4)),
                Text(
                  _formatDate(exam.date),
                  style: AppTextStyle.caption(context),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.w(context, 12),
              vertical: Responsive.h(context, 8),
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Text(
              '${pct.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: Responsive.sp(context, 16),
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
