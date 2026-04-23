import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/core/widgets/custom_app_bar.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_homework_assignment_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffHomeworkAssignmentView
    extends GetView<StaffHomeworkAssignmentController> {
  const StaffHomeworkAssignmentView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: const CustomAppBar(title: 'Homework & Assignment Management'),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _tabs(isDark),
            const SizedBox(height: 12),
            _activeSection(isDark),
          ],
        ),
      ),
    );
  }

  Widget _tabs(bool isDark) {
    const labels = ['Create', 'Deadlines', 'Submissions', 'Feedback'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final selected = controller.activeTab.value == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.setTab(index),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected ? AppColors.primary : null,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _panel(bool isDark, String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _activeSection(bool isDark) {
    switch (controller.activeTab.value) {
      case 0:
        return _createTab(isDark);
      case 1:
        return _deadlinesTab(isDark);
      case 2:
        return _submissionsTab(isDark);
      default:
        return _feedbackTab(isDark);
    }
  }

  Widget _createTab(bool isDark) {
    return _panel(
      isDark,
      'Create Assignments & Homework',
      Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _openCreateDialog,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Assignment/Homework'),
            ),
          ),
          const SizedBox(height: 8),
          ...controller.assignments.map(
            (row) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.assignment_rounded,
                color: AppColors.primary,
              ),
              title: Text('${row['title']} - ${row['className']}'),
              subtitle: Text('${row['subject']} - ${row['status']}'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _deadlinesTab(bool isDark) {
    return _panel(
      isDark,
      'Set Deadlines',
      Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: _openDeadlineDialog,
              icon: const Icon(Icons.schedule_rounded),
              label: const Text('Set Deadline'),
            ),
          ),
          const SizedBox(height: 8),
          ...controller.deadlines.map(
            (row) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.calendar_today_rounded,
                color: AppColors.primary,
              ),
              title: Text('${row['assignmentTitle']}'),
              subtitle: Text('Due ${row['dueDate']} - ${row['dueTime']}'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _submissionsTab(bool isDark) {
    return _panel(
      isDark,
      'Assignment & Homework Submissions',
      Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: _openSubmissionDialog,
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('Add/Update Submission'),
            ),
          ),
          const SizedBox(height: 8),
          ...controller.submissions.map(
            (row) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.person_rounded,
                color: AppColors.primary,
              ),
              title: Text('${row['studentName']}'),
              subtitle: Text('${row['assignmentTitle']} - ${row['status']}'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _feedbackTab(bool isDark) {
    return _panel(
      isDark,
      'Feedback System',
      Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: _openFeedbackDialog,
              icon: const Icon(Icons.feedback_rounded),
              label: const Text('Add Feedback'),
            ),
          ),
          const SizedBox(height: 8),
          ...controller.feedbackItems.map(
            (row) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${row['studentName']} - ${row['assignmentTitle']}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text('${row['feedback']}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openCreateDialog() async {
    final title = TextEditingController();
    final className = TextEditingController();
    final subject = TextEditingController();
    await Get.dialog(
      AlertDialog(
        title: const Text('Create Assignment/Homework'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: className,
              decoration: const InputDecoration(labelText: 'Class'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: subject,
              decoration: const InputDecoration(labelText: 'Subject'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              controller.createAssignment(
                title: title.text,
                className: className.text,
                subject: subject.text,
              );
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _openDeadlineDialog() async {
    final title = TextEditingController();
    final date = TextEditingController(
      text: DateTime.now().toIso8601String().split('T').first,
    );
    final time = TextEditingController(text: '17:00');
    await Get.dialog(
      AlertDialog(
        title: const Text('Set Deadline'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Assignment Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: date,
              decoration: const InputDecoration(labelText: 'Due Date'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: time,
              decoration: const InputDecoration(labelText: 'Due Time'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              controller.setDeadline(
                assignmentTitle: title.text,
                dueDate: date.text,
                dueTime: time.text,
              );
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _openSubmissionDialog() async {
    final student = TextEditingController();
    final title = TextEditingController();
    String status = 'SUBMITTED';
    await Get.dialog(
      AlertDialog(
        title: const Text('Update Submission'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: student,
                decoration: const InputDecoration(labelText: 'Student Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: title,
                decoration: const InputDecoration(
                  labelText: 'Assignment Title',
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const ['SUBMITTED', 'PENDING', 'LATE']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => status = value ?? 'SUBMITTED'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              controller.addSubmission(
                studentName: student.text,
                assignmentTitle: title.text,
                status: status,
              );
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _openFeedbackDialog() async {
    final student = TextEditingController();
    final title = TextEditingController();
    final feedback = TextEditingController();
    await Get.dialog(
      AlertDialog(
        title: const Text('Add Feedback'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: student,
                decoration: const InputDecoration(labelText: 'Student Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: title,
                decoration: const InputDecoration(
                  labelText: 'Assignment Title',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: feedback,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Feedback'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              controller.addFeedback(
                studentName: student.text,
                assignmentTitle: title.text,
                feedback: feedback.text,
              );
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
