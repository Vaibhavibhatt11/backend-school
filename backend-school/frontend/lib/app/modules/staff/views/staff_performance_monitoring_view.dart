import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/core/widgets/custom_app_bar.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_performance_monitoring_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffPerformanceMonitoringView
    extends GetView<StaffPerformanceMonitoringController> {
  const StaffPerformanceMonitoringView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: const CustomAppBar(title: 'Student Performance Monitoring'),
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
    const labels = ['Marks', 'Attendance', 'Progress Reports', 'Weak Students'];
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
        return _marksTab(isDark);
      case 1:
        return _attendanceTab(isDark);
      case 2:
        return _reportsTab(isDark);
      default:
        return _weakStudentsTab(isDark);
    }
  }

  Widget _marksTab(bool isDark) {
    return _panel(
      isDark,
      'Student Marks Tracking',
      Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _openMarksDialog,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Marks'),
            ),
          ),
          const SizedBox(height: 8),
          ...controller.marks.map((row) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.quiz_rounded, color: AppColors.primary),
                title: Text('${row['studentName']} - ${row['subject']}'),
                subtitle: Text('Score: ${row['score']}'),
              )),
        ],
      ),
    );
  }

  Widget _attendanceTab(bool isDark) {
    return _panel(
      isDark,
      'Attendance Monitoring',
      Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: _openAttendanceDialog,
              icon: const Icon(Icons.fact_check_rounded),
              label: const Text('Update Attendance'),
            ),
          ),
          const SizedBox(height: 8),
          ...controller.attendance.map((row) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_rounded, color: AppColors.primary),
                title: Text('${row['studentName']}'),
                subtitle: Text('Attendance: ${row['percentage']}%'),
              )),
        ],
      ),
    );
  }

  Widget _reportsTab(bool isDark) {
    return _panel(
      isDark,
      'Academic Progress Reports',
      Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: _openReportDialog,
              icon: const Icon(Icons.description_rounded),
              label: const Text('Add Progress Report'),
            ),
          ),
          const SizedBox(height: 8),
          ...controller.progressReports.map((row) => Container(
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
                    Text('${row['studentName']} - ${row['term']}',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('${row['summary']}'),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _weakStudentsTab(bool isDark) {
    return _panel(
      isDark,
      'Weak Student Identification',
      Column(
        children: [
          if (controller.weakStudents.isEmpty)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('No weak students flagged currently'),
            )
          else
            ...controller.weakStudents.map((row) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  title: Text('${row['studentName']}'),
                  subtitle: Text('${row['reason']}'),
                  trailing: FilledButton.tonal(
                    onPressed: () => controller.resolveWeakStudent(row['id'] ?? ''),
                    child: const Text('Follow-up'),
                  ),
                )),
        ],
      ),
    );
  }

  Future<void> _openMarksDialog() async {
    final name = TextEditingController();
    final subject = TextEditingController();
    final score = TextEditingController();
    await Get.dialog(
      AlertDialog(
        title: const Text('Add Marks'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Student Name')),
            const SizedBox(height: 8),
            TextField(controller: subject, decoration: const InputDecoration(labelText: 'Subject')),
            const SizedBox(height: 8),
            TextField(controller: score, decoration: const InputDecoration(labelText: 'Score')),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              controller.addMarks(
                studentName: name.text,
                subject: subject.text,
                score: score.text,
              );
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _openAttendanceDialog() async {
    final name = TextEditingController();
    final pct = TextEditingController();
    await Get.dialog(
      AlertDialog(
        title: const Text('Update Attendance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Student Name')),
            const SizedBox(height: 8),
            TextField(controller: pct, decoration: const InputDecoration(labelText: 'Attendance %')),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              controller.addAttendance(
                studentName: name.text,
                percentage: pct.text,
              );
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _openReportDialog() async {
    final name = TextEditingController();
    final term = TextEditingController(text: 'Term 1');
    final summary = TextEditingController();
    await Get.dialog(
      AlertDialog(
        title: const Text('Add Progress Report'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Student Name')),
              const SizedBox(height: 8),
              TextField(controller: term, decoration: const InputDecoration(labelText: 'Term')),
              const SizedBox(height: 8),
              TextField(controller: summary, maxLines: 3, decoration: const InputDecoration(labelText: 'Summary')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              controller.addProgressReport(
                studentName: name.text,
                summary: summary.text,
                term: term.text,
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
