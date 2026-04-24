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
          actions: const [],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: _ScheduleHeaderCard(controller: controller),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: TabBar(
                onTap: (value) => controller.changeTab(value),
                indicator: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorPadding: const EdgeInsets.all(6),
                dividerColor: Colors.transparent,
                labelColor: AppColors.primary,
                unselectedLabelColor: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                tabs: const [
                  Tab(text: 'Schedule'),
                  Tab(text: 'Exams'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TabBarView(
          children: [
            _ScheduleTab(controller: controller),
            _ExamsTab(controller: controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleHeaderCard extends StatelessWidget {
  const _ScheduleHeaderCard({required this.controller});

  final AdminScheduleController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.event_note_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Examination System',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${controller.exams.length} exams • '
                    '${controller.publishedResultsCount} published • '
                    '${controller.averageScore.toStringAsFixed(1)}% avg',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleTab extends StatelessWidget {
  const _ScheduleTab({required this.controller});

  final AdminScheduleController controller;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.surfaceDark
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.borderDark
                    : AppColors.borderLight,
              ),
            ),
            child: TabBar(
              isScrollable: true,
              indicator: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorPadding: const EdgeInsets.all(6),
              dividerColor: Colors.transparent,
              labelColor: AppColors.primary,
              unselectedLabelColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              tabs: const [
                Tab(text: 'Class Timetable'),
                Tab(text: 'Teacher Timetable'),
                Tab(text: 'Room Allocation'),
                Tab(text: 'Substitute Teachers'),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
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
              return TabBarView(
                children: [
                  _ClassTimetableSubTab(controller: controller),
                  _TeacherTimetableSubTab(controller: controller),
                  _RoomAllocationSubTab(controller: controller),
                  _SubstituteTeachersSubTab(controller: controller),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ClassTimetableSubTab extends StatelessWidget {
  const _ClassTimetableSubTab({required this.controller});
  final AdminScheduleController controller;

  @override
  Widget build(BuildContext context) {
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
                label: 'Class Slots',
                  value: '${controller.timetableSlots.length}',
                ),
                FilledButton.icon(
                  onPressed: () => controller.openTimetableDialog(),
                  icon: const Icon(Icons.add_alarm_rounded),
                  label: const Text('Add Slot'),
                ),
                OutlinedButton.icon(
                  onPressed: controller.publishTimetable,
                  icon: const Icon(Icons.publish_rounded),
                label: const Text('Publish Timetable'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (controller.timetableSlots.isEmpty)
              const _EmptyState(
                icon: Icons.schedule_rounded,
              title: 'No class timetable slots',
              message: 'Create class timetable slots to build weekly schedule.',
              )
            else
              ...controller.timetableSlots.map(
                (item) => _SessionCard(
                  item: item,
                primaryAction: () => controller.openTimetableDialog(existing: item),
                  secondaryAction: () => controller.deleteTimetableSlot(item),
                  primaryLabel: 'Edit',
                  secondaryLabel: 'Delete',
                ),
              ),
        ],
      ),
    );
  }
}

class _TeacherTimetableSubTab extends StatelessWidget {
  const _TeacherTimetableSubTab({required this.controller});
  final AdminScheduleController controller;

  @override
  Widget build(BuildContext context) {
    final slots = controller.teacherTimetableView;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _SummaryChip(label: 'Teacher Slots', value: '${slots.length}'),
        const SizedBox(height: 14),
        if (slots.isEmpty)
              const _EmptyState(
            icon: Icons.person_search_rounded,
            title: 'No teacher timetable entries',
            message: 'Create timetable slots to populate teacher timetable.',
              )
            else
          ...slots.map(
                (item) => _SessionCard(
                  item: item,
              primaryAction: () => controller.openTimetableDialog(existing: item),
                  secondaryAction: item.status == 'ENDED'
                      ? null
                      : () => controller.endLiveSession(item),
                  primaryLabel: 'Edit',
                  secondaryLabel: item.status == 'ENDED' ? '' : 'End',
                ),
              ),
          ],
    );
  }
}

class _RoomAllocationSubTab extends StatelessWidget {
  const _RoomAllocationSubTab({required this.controller});
  final AdminScheduleController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _SummaryChip(
              label: 'Room Allocations',
              value: '${controller.roomAllocations.length}',
            ),
            FilledButton.icon(
              onPressed: () => controller.openRoomAllocationDialog(),
              icon: const Icon(Icons.meeting_room_rounded),
              label: const Text('Assign Room'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (controller.roomAllocations.isEmpty)
          const _EmptyState(
            icon: Icons.meeting_room_rounded,
            title: 'No room allocations',
            message: 'Assign rooms for timetable slots and classes.',
          )
        else
          ...controller.roomAllocations.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.surfaceDark
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.borderDark
                      : AppColors.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.roomName, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('${item.classLabel} • ${item.subjectLabel}'),
                  Text('${item.teacherName} • ${item.timeLabel}'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () => controller.openRoomAllocationDialog(existing: item),
                        child: const Text('Edit'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.tonal(
                        onPressed: () => controller.deleteRoomAllocation(item),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _SubstituteTeachersSubTab extends StatelessWidget {
  const _SubstituteTeachersSubTab({required this.controller});
  final AdminScheduleController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _SummaryChip(
              label: 'Substitute Assignments',
              value: '${controller.substituteTeachers.length}',
            ),
            FilledButton.icon(
              onPressed: () => controller.openSubstituteTeacherDialog(),
              icon: const Icon(Icons.swap_horiz_rounded),
              label: const Text('Assign Substitute'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (controller.substituteTeachers.isEmpty)
          const _EmptyState(
            icon: Icons.swap_horiz_rounded,
            title: 'No substitute assignments',
            message: 'Assign substitute teachers for absent faculty.',
          )
        else
          ...controller.substituteTeachers.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.surfaceDark
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.borderDark
                      : AppColors.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.classLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('${item.subjectLabel} • ${item.dateLabel}'),
                  Text('Original: ${item.originalTeacherName}'),
                  Text('Substitute: ${item.substituteTeacherName}'),
                  if (item.reason.trim().isNotEmpty) Text('Reason: ${item.reason}'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () => controller.openSubstituteTeacherDialog(existing: item),
                        child: const Text('Edit'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.tonal(
                        onPressed: () => controller.deleteSubstituteTeacher(item),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ExamsTab extends StatelessWidget {
  const _ExamsTab({required this.controller});

  final AdminScheduleController controller;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.surfaceDark
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.borderDark
                    : AppColors.borderLight,
              ),
            ),
            child: TabBar(
              isScrollable: true,
              indicator: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorPadding: const EdgeInsets.all(6),
              dividerColor: Colors.transparent,
              labelColor: AppColors.primary,
              unselectedLabelColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              tabs: const [
                Tab(text: 'Exam Schedule'),
                Tab(text: 'Question Papers'),
                Tab(text: 'Marks Entry'),
                Tab(text: 'Grading'),
                Tab(text: 'Report Cards'),
                Tab(text: 'Analytics'),
                Tab(text: 'Results'),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
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
              return TabBarView(
                children: [
                  _ExamScheduleSubTab(controller: controller),
                  _QuestionPapersSubTab(controller: controller),
                  _MarksEntrySubTab(controller: controller),
                  _GradingSubTab(controller: controller),
                  _ReportCardsSubTab(controller: controller),
                  _ExamAnalyticsSubTab(controller: controller),
                  _ResultPublishingSubTab(controller: controller),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ExamScheduleSubTab extends StatelessWidget {
  const _ExamScheduleSubTab({required this.controller});
  final AdminScheduleController controller;

  @override
  Widget build(BuildContext context) {
      return RefreshIndicator(
        onRefresh: controller.refreshCurrentTab,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
              _SummaryChip(label: 'Exams', value: '${controller.exams.length}'),
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
              message: 'Create real exams, publish them, and enter marks here.',
            )
          else
            ...controller.exams.map((item) => _ExamCard(item: item, controller: controller)),
        ],
      ),
    );
  }
}

class _QuestionPapersSubTab extends StatelessWidget {
  const _QuestionPapersSubTab({required this.controller});
  final AdminScheduleController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _SummaryChip(
              label: 'Uploaded Papers',
              value: '${controller.questionPapers.length}',
            ),
            FilledButton.icon(
              onPressed: () => controller.openQuestionPaperDialog(),
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('Upload Paper'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (controller.questionPapers.isEmpty)
          const _EmptyState(
            icon: Icons.description_rounded,
            title: 'No question papers',
            message: 'Upload exam question papers to organize distribution.',
          )
        else
          ...controller.questionPapers.map(
            (paper) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(paper.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Exam: ${paper.examName}'),
                  const SizedBox(height: 4),
                  SelectableText(paper.fileUrl),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () => controller.openQuestionPaperDialog(existing: paper),
                        child: const Text('Edit'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.tonal(
                        onPressed: () => controller.deleteQuestionPaper(paper),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _MarksEntrySubTab extends StatelessWidget {
  const _MarksEntrySubTab({required this.controller});
  final AdminScheduleController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        const _SectionTitle(title: 'Marks Entry Workflow'),
        const SizedBox(height: 12),
        if (controller.exams.isEmpty)
          const _EmptyState(
            icon: Icons.edit_note_rounded,
            title: 'No exams available',
            message: 'Create an exam first to start marks entry.',
              )
            else
              ...controller.exams.map(
            (exam) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(exam.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text('${exam.classLabel} • ${exam.subjectLabel}'),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => controller.openMarksStatus(exam),
                    icon: const Icon(Icons.score_rounded),
                    label: const Text('Enter Marks'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _GradingSubTab extends StatelessWidget {
  const _GradingSubTab({required this.controller});
  final AdminScheduleController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _SummaryChip(
              label: 'Grading Bands',
              value: '${controller.gradingBands.length}',
            ),
            FilledButton.icon(
              onPressed: () => controller.openGradingBandDialog(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Grade Band'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (controller.gradingBands.isEmpty)
          const _EmptyState(
            icon: Icons.rule_rounded,
            title: 'No grading bands',
            message: 'Define grading thresholds to automate grade assignment.',
          )
        else
          ...controller.gradingBands.map(
            (band) => ListTile(
              tileColor: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              title: Text('Grade ${band.label}', style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${band.minPercent.toStringAsFixed(0)}% - ${band.maxPercent.toStringAsFixed(0)}% • GPA ${band.gpa.toStringAsFixed(2)}'),
              trailing: Wrap(
                spacing: 6,
                children: [
                  IconButton(
                    onPressed: () => controller.openGradingBandDialog(existing: band),
                    icon: const Icon(Icons.edit_rounded),
                  ),
                  IconButton(
                    onPressed: () => controller.deleteGradingBand(band),
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ReportCardsSubTab extends StatelessWidget {
  const _ReportCardsSubTab({required this.controller});
  final AdminScheduleController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _SummaryChip(label: 'Report Cards', value: '${controller.reportCards.length}'),
        const SizedBox(height: 16),
        if (controller.reportCards.isEmpty)
          const _EmptyState(
            icon: Icons.badge_rounded,
            title: 'No report cards',
            message: 'Enter marks and generate report cards from exam results.',
          )
        else
          ...controller.reportCards.map(
            (card) => ListTile(
              tileColor: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              title: Text(card.studentName, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${card.examName} • ${card.obtainedMarks.toStringAsFixed(1)}/${card.maxMarks.toStringAsFixed(1)} • ${card.percent.toStringAsFixed(1)}%'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(card.grade, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
      ],
    );
  }
}

class _ExamAnalyticsSubTab extends StatelessWidget {
  const _ExamAnalyticsSubTab({required this.controller});
  final AdminScheduleController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _SummaryChip(label: 'Avg Score', value: '${controller.averageScore.toStringAsFixed(1)}%'),
            _SummaryChip(label: 'Pass Rate', value: '${controller.examPassRate.toStringAsFixed(1)}%'),
            _SummaryChip(label: 'Published Results', value: '${controller.publishedResultsCount}/${controller.exams.length}'),
          ],
        ),
        const SizedBox(height: 16),
        if (controller.reportCards.isEmpty)
          const _EmptyState(
            icon: Icons.analytics_rounded,
            title: 'No analytics yet',
            message: 'Enter marks and report cards to unlock exam analytics.',
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Analytics Summary', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('Insights generated at: ${controller.examInsightsGeneratedAt.value}'),
                const SizedBox(height: 8),
                Text('Top performers and subject analysis can be extended from this baseline.'),
              ],
            ),
          ),
      ],
    );
  }
}

class _ResultPublishingSubTab extends StatelessWidget {
  const _ResultPublishingSubTab({required this.controller});
  final AdminScheduleController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        const _SectionTitle(title: 'Result Publishing'),
        const SizedBox(height: 12),
        if (controller.exams.isEmpty)
          const _EmptyState(
            icon: Icons.publish_rounded,
            title: 'No exams available',
            message: 'Create exams and enter marks before publishing results.',
          )
        else
          ...controller.exams.map(
            (exam) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(exam.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(exam.isPublished ? 'Published' : 'Draft'),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: exam.isPublished ? null : () => controller.publishResults(exam),
                    icon: const Icon(Icons.publish_rounded),
                    label: Text(exam.isPublished ? 'Published' : 'Publish'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
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
