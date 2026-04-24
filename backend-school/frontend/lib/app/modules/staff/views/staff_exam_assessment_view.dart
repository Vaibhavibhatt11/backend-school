import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/core/widgets/custom_app_bar.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_exam_assessment_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffExamAssessmentView extends GetView<StaffExamAssessmentController> {
  const StaffExamAssessmentView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: const CustomAppBar(title: 'Exam & Assessment Management'),
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
    const labels = ['Create Exams', 'Question Papers', 'Marks Entry', 'Grading', 'Results'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(labels.length, (index) {
            final selected = controller.activeTab.value == index;
            return GestureDetector(
              onTap: () => controller.setTab(index),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  labels[index],
                  style: TextStyle(
                    color: selected ? AppColors.primary : null,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _panel(bool isDark, String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
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
        return _createExams(isDark);
      case 1:
        return _questionPapers(isDark);
      case 2:
        return _marksEntry(isDark);
      case 3:
        return _grading(isDark);
      default:
        return _results(isDark);
    }
  }

  Widget _createExams(bool isDark) {
    return _panel(
      isDark,
      'Create Exams',
      Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _openCreateExamDialog,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Exam'),
            ),
          ),
          const SizedBox(height: 8),
          ...controller.exams.map((row) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.quiz_rounded, color: AppColors.primary),
                title: Text('${row['name']} - ${row['className']}'),
                subtitle: Text('${row['date']} - ${row['status']}'),
              )),
        ],
      ),
    );
  }

  Widget _questionPapers(bool isDark) {
    return _panel(
      isDark,
      'Question Paper Upload',
      Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: _openPaperDialog,
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('Upload Question Paper'),
            ),
          ),
          const SizedBox(height: 8),
          ...controller.questionPapers.map((row) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.description_rounded, color: AppColors.primary),
                title: Text('${row['examName']} - ${row['subject']}'),
                subtitle: Text('${row['fileName']} - ${row['status']}'),
              )),
        ],
      ),
    );
  }

  Widget _marksEntry(bool isDark) {
    return _panel(
      isDark,
      'Marks Entry',
      Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: _openMarksDialog,
              icon: const Icon(Icons.edit_note_rounded),
              label: const Text('Enter Marks'),
            ),
          ),
          const SizedBox(height: 8),
          ...controller.marksEntries.map((row) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_rounded, color: AppColors.primary),
                title: Text('${row['studentName']} - ${row['examName']}'),
                subtitle: Text('Marks: ${row['marks']}'),
              )),
        ],
      ),
    );
  }

  Widget _grading(bool isDark) {
    return _panel(
      isDark,
      'Grading System',
      Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: _openGradingDialog,
              icon: const Icon(Icons.rule_rounded),
              label: const Text('Add Grading Rule'),
            ),
          ),
          const SizedBox(height: 8),
          ...controller.gradingRules.map((row) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.grade_rounded, color: AppColors.primary),
                title: Text('Grade ${row['grade']}'),
                subtitle: Text('Marks ${row['minMarks']} - ${row['maxMarks']}'),
              )),
        ],
      ),
    );
  }

  Widget _results(bool isDark) {
    return _panel(
      isDark,
      'Result Publishing',
      Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: _openResultDialog,
              icon: const Icon(Icons.publish_rounded),
              label: const Text('Publish Result'),
            ),
          ),
          const SizedBox(height: 8),
          ...controller.results.map((row) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.campaign_rounded, color: AppColors.primary),
                title: Text('${row['examName']} - ${row['className']}'),
                subtitle: Text('${row['status']} - ${row['publishedOn']}'),
              )),
        ],
      ),
    );
  }

  Future<void> _openCreateExamDialog() async {
    final name = TextEditingController();
    final cls = TextEditingController();
    final date = TextEditingController(text: DateTime.now().toIso8601String().split('T').first);
    await Get.dialog(
      AlertDialog(
        title: const Text('Create Exam'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Exam Name')),
            const SizedBox(height: 8),
            TextField(controller: cls, decoration: const InputDecoration(labelText: 'Class')),
            const SizedBox(height: 8),
            TextField(controller: date, decoration: const InputDecoration(labelText: 'Exam Date')),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              controller.createExam(
                name: name.text,
                className: cls.text,
                date: date.text,
              );
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _openPaperDialog() async {
    final exam = TextEditingController();
    final subject = TextEditingController();
    final file = TextEditingController();
    await Get.dialog(
      AlertDialog(
        title: const Text('Upload Question Paper'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: exam, decoration: const InputDecoration(labelText: 'Exam Name')),
            const SizedBox(height: 8),
            TextField(controller: subject, decoration: const InputDecoration(labelText: 'Subject')),
            const SizedBox(height: 8),
            TextField(controller: file, decoration: const InputDecoration(labelText: 'File Name')),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              controller.uploadQuestionPaper(
                examName: exam.text,
                subject: subject.text,
                fileName: file.text,
              );
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _openMarksDialog() async {
    final exam = TextEditingController();
    final student = TextEditingController();
    final marks = TextEditingController();
    await Get.dialog(
      AlertDialog(
        title: const Text('Marks Entry'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: exam, decoration: const InputDecoration(labelText: 'Exam Name')),
            const SizedBox(height: 8),
            TextField(controller: student, decoration: const InputDecoration(labelText: 'Student Name')),
            const SizedBox(height: 8),
            TextField(controller: marks, decoration: const InputDecoration(labelText: 'Marks')),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              controller.addMarks(
                examName: exam.text,
                studentName: student.text,
                marks: marks.text,
              );
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _openGradingDialog() async {
    final grade = TextEditingController();
    final min = TextEditingController();
    final max = TextEditingController();
    await Get.dialog(
      AlertDialog(
        title: const Text('Add Grading Rule'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: grade, decoration: const InputDecoration(labelText: 'Grade')),
            const SizedBox(height: 8),
            TextField(controller: min, decoration: const InputDecoration(labelText: 'Min Marks')),
            const SizedBox(height: 8),
            TextField(controller: max, decoration: const InputDecoration(labelText: 'Max Marks')),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              controller.addGradingRule(
                grade: grade.text,
                minMarks: min.text,
                maxMarks: max.text,
              );
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _openResultDialog() async {
    final exam = TextEditingController();
    final cls = TextEditingController();
    await Get.dialog(
      AlertDialog(
        title: const Text('Publish Result'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: exam, decoration: const InputDecoration(labelText: 'Exam Name')),
            const SizedBox(height: 8),
            TextField(controller: cls, decoration: const InputDecoration(labelText: 'Class')),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              controller.publishResult(
                examName: exam.text,
                className: cls.text,
              );
              Get.back();
            },
            child: const Text('Publish'),
          ),
        ],
      ),
    );
  }
}
