import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_schedule_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminScheduleView extends GetView<AdminScheduleController> {
  const AdminScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = (Get.arguments as Map?)?.cast<String, dynamic>() ?? const {};
    final initialTab = _tabFromArgs(args);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      initialIndex: initialTab,
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('Schedule & Exams'),
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          bottom: TabBar(
            onTap: (value) => controller.changeTab(value),
            tabs: const [
              Tab(text: 'Schedule'),
              Tab(text: 'Exams'),
            ],
          ),
          actions: [
            IconButton(
              onPressed: controller.refreshCurrentTab,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _ScheduleTab(controller: controller),
            _ExamsTab(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _ScheduleTab extends StatelessWidget {
  const _ScheduleTab({required this.controller});

  final AdminScheduleController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value &&
          controller.timetableSlots.isEmpty &&
          controller.liveSessions.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.errorMessage.value.isNotEmpty &&
          controller.timetableSlots.isEmpty &&
          controller.liveSessions.isEmpty) {
        return _ErrorState(
          message: controller.errorMessage.value,
          onRetry: controller.refreshCurrentTab,
        );
      }
      return RefreshIndicator(
        onRefresh: controller.refreshCurrentTab,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SummaryChip(
                  label: 'Timetable Slots',
                  value: '${controller.timetableSlots.length}',
                ),
                _SummaryChip(
                  label: 'Live Sessions',
                  value: '${controller.liveSessions.length}',
                ),
                FilledButton.icon(
                  onPressed: () => controller.openTimetableDialog(),
                  icon: const Icon(Icons.add_alarm_rounded),
                  label: const Text('Add Slot'),
                ),
                FilledButton.icon(
                  onPressed: () => controller.openLiveSessionDialog(),
                  icon: const Icon(Icons.video_call_rounded),
                  label: const Text('Add Live'),
                ),
                OutlinedButton.icon(
                  onPressed: controller.publishTimetable,
                  icon: const Icon(Icons.publish_rounded),
                  label: const Text('Publish'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const _SectionTitle(title: 'Timetable Slots'),
            const SizedBox(height: 12),
            if (controller.timetableSlots.isEmpty)
              const _EmptyState(
                icon: Icons.schedule_rounded,
                title: 'No timetable slots',
                message:
                    'Create live timetable entries and they will appear here.',
              )
            else
              ...controller.timetableSlots.map(
                (item) => _SessionCard(
                  item: item,
                  primaryAction: () =>
                      controller.openTimetableDialog(existing: item),
                  secondaryAction: () => controller.deleteTimetableSlot(item),
                  primaryLabel: 'Edit',
                  secondaryLabel: 'Delete',
                ),
              ),
            const SizedBox(height: 20),
            const _SectionTitle(title: 'Live Sessions'),
            const SizedBox(height: 12),
            if (controller.liveSessions.isEmpty)
              const _EmptyState(
                icon: Icons.wifi_tethering_rounded,
                title: 'No live sessions',
                message: 'Create real live classes and they will appear here.',
              )
            else
              ...controller.liveSessions.map(
                (item) => _SessionCard(
                  item: item,
                  primaryAction: () =>
                      controller.openLiveSessionDialog(existing: item),
                  secondaryAction: item.status == 'ENDED'
                      ? null
                      : () => controller.endLiveSession(item),
                  primaryLabel: 'Edit',
                  secondaryLabel: item.status == 'ENDED' ? '' : 'End',
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _ExamsTab extends StatelessWidget {
  const _ExamsTab({required this.controller});

  final AdminScheduleController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.exams.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.errorMessage.value.isNotEmpty &&
          controller.exams.isEmpty) {
        return _ErrorState(
          message: controller.errorMessage.value,
          onRetry: controller.refreshCurrentTab,
        );
      }
      return RefreshIndicator(
        onRefresh: controller.refreshCurrentTab,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SummaryChip(
                  label: 'Exams',
                  value: '${controller.exams.length}',
                ),
                FilledButton.icon(
                  onPressed: () => controller.openExamDialog(),
                  icon: const Icon(Icons.add_box_rounded),
                  label: const Text('Create Exam'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (controller.exams.isEmpty)
              const _EmptyState(
                icon: Icons.quiz_rounded,
                title: 'No exams found',
                message:
                    'Create real exams, publish them, and enter marks here.',
              )
            else
              ...controller.exams.map(
                (item) => _ExamCard(item: item, controller: controller),
              ),
          ],
        ),
      );
    });
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.item,
    required this.primaryAction,
    required this.secondaryAction,
    required this.primaryLabel,
    required this.secondaryLabel,
  });

  final AdminScheduleSessionRecord item;
  final VoidCallback primaryAction;
  final VoidCallback? secondaryAction;
  final String primaryLabel;
  final String secondaryLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.textDark
                            : AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatSessionTime(item),
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.status.isNotEmpty) _StatusChip(label: item.status),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (item.classLabel.trim().isNotEmpty)
                _MetaText(label: 'Class', value: item.classLabel),
              if (item.subjectLabel.trim().isNotEmpty)
                _MetaText(label: 'Subject', value: item.subjectLabel),
              if (item.teacherName.trim().isNotEmpty)
                _MetaText(label: 'Teacher', value: item.teacherName),
              if (item.platform.trim().isNotEmpty)
                _MetaText(label: 'Platform', value: item.platform),
            ],
          ),
          if (item.joinUrl.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            SelectableText(item.joinUrl),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: primaryAction,
                child: Text(primaryLabel),
              ),
              if (secondaryAction != null && secondaryLabel.isNotEmpty)
                FilledButton.tonal(
                  onPressed: secondaryAction,
                  child: Text(secondaryLabel),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({required this.item, required this.controller});

  final AdminExamRecord item;
  final AdminScheduleController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.textDark
                            : AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatExamDate(item.examDate),
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(label: item.isPublished ? 'PUBLISHED' : item.status),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (item.classLabel.trim().isNotEmpty)
                _MetaText(label: 'Class', value: item.classLabel),
              if (item.subjectLabel.trim().isNotEmpty)
                _MetaText(label: 'Subject', value: item.subjectLabel),
              _MetaText(label: 'Max Marks', value: item.maxMarks.toString()),
              _MetaText(label: 'Results', value: '${item.resultsCount}'),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => controller.openExamDialog(existing: item),
                child: const Text('Edit'),
              ),
              OutlinedButton(
                onPressed: () => controller.openMarksStatus(item),
                child: const Text('Marks'),
              ),
              if (!item.isPublished)
                OutlinedButton(
                  onPressed: () => controller.publishExam(item),
                  child: const Text('Publish'),
                ),
              FilledButton.tonal(
                onPressed: () => controller.deleteExam(item),
                child: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textDark : AppColors.textLight,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final active =
        label.toUpperCase() != 'ENDED' && label.toUpperCase() != 'DRAFT';
    final color = active ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 36,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => onRetry(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatSessionTime(AdminScheduleSessionRecord item) {
  final start = item.startsAt;
  final end = item.endsAt;
  if (start == null) return 'Time not set';
  final startText = start
      .toIso8601String()
      .substring(0, 16)
      .replaceFirst('T', ' ');
  if (end == null) return startText;
  final endText = end.toIso8601String().substring(11, 16);
  return '$startText | $endText';
}

String _formatExamDate(DateTime? value) {
  if (value == null) return 'Date not set';
  return value.toIso8601String().substring(0, 10);
}

int _tabFromArgs(Map<String, dynamic> args) {
  final value = (args['initialTab'] as num?)?.toInt() ?? 0;
  if (value < 0) return 0;
  if (value > 1) return 1;
  return value;
}
