import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/core/widgets/custom_app_bar.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_lesson_planning_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffLessonPlanningView extends GetView<StaffLessonPlanningController> {
  const StaffLessonPlanningView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: const CustomAppBar(title: 'Lesson Planning'),
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
    const labels = ['Create Plans', 'Topic Scheduling', 'Lesson Notes'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(labels.length, (i) {
          final selected = controller.activeTab.value == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.setTab(i),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  labels[i],
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
    if (controller.activeTab.value == 0) return _plans(isDark);
    if (controller.activeTab.value == 1) return _topics(isDark);
    return _notes(isDark);
  }

  Widget _plans(bool isDark) {
    return _panel(
      isDark,
      'Create Lesson Plans',
      Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _openPlanDialog,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Lesson Plan'),
            ),
          ),
          const SizedBox(height: 8),
          ...controller.lessonPlans.map((row) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.menu_book_rounded, color: AppColors.primary),
                title: Text('${row['className']} - ${row['subject']}'),
                subtitle: Text('${row['objective']}'),
              )),
        ],
      ),
    );
  }

  Widget _topics(bool isDark) {
    return _panel(
      isDark,
      'Topic Scheduling',
      Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: _openTopicDialog,
              icon: const Icon(Icons.schedule_rounded),
              label: const Text('Schedule Topic'),
            ),
          ),
          const SizedBox(height: 8),
          ...controller.topicSchedules.map((row) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_note_rounded, color: AppColors.primary),
                title: Text('${row['topic']} - ${row['className']}'),
                subtitle: Text('${row['date']} - ${row['period']}'),
              )),
        ],
      ),
    );
  }

  Widget _notes(bool isDark) {
    return _panel(
      isDark,
      'Lesson Notes',
      Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: _openNoteDialog,
              icon: const Icon(Icons.note_add_rounded),
              label: const Text('Add Note'),
            ),
          ),
          const SizedBox(height: 8),
          ...controller.lessonNotes.map((row) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${row['title']}', style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('${row['className']}'),
                    const SizedBox(height: 4),
                    Text('${row['note']}'),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Future<void> _openPlanDialog() async {
    final cls = TextEditingController();
    final subject = TextEditingController();
    final objective = TextEditingController();
    await Get.dialog(
      AlertDialog(
        title: const Text('Create Lesson Plan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: cls, decoration: const InputDecoration(labelText: 'Class')),
              const SizedBox(height: 8),
              TextField(controller: subject, decoration: const InputDecoration(labelText: 'Subject')),
              const SizedBox(height: 8),
              TextField(controller: objective, maxLines: 3, decoration: const InputDecoration(labelText: 'Objective')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              controller.addLessonPlan(
                className: cls.text,
                subject: subject.text,
                objective: objective.text,
              );
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _openTopicDialog() async {
    final cls = TextEditingController();
    final topic = TextEditingController();
    final date = TextEditingController(text: DateTime.now().toIso8601String().split('T').first);
    final period = TextEditingController(text: '10:00-10:45');
    await Get.dialog(
      AlertDialog(
        title: const Text('Schedule Topic'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: cls, decoration: const InputDecoration(labelText: 'Class')),
              const SizedBox(height: 8),
              TextField(controller: topic, decoration: const InputDecoration(labelText: 'Topic')),
              const SizedBox(height: 8),
              TextField(controller: date, decoration: const InputDecoration(labelText: 'Date')),
              const SizedBox(height: 8),
              TextField(controller: period, decoration: const InputDecoration(labelText: 'Period')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              controller.addTopicSchedule(
                className: cls.text,
                topic: topic.text,
                date: date.text,
                period: period.text,
              );
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _openNoteDialog() async {
    final title = TextEditingController();
    final note = TextEditingController();
    final cls = TextEditingController();
    await Get.dialog(
      AlertDialog(
        title: const Text('Add Lesson Note'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 8),
              TextField(controller: cls, decoration: const InputDecoration(labelText: 'Class')),
              const SizedBox(height: 8),
              TextField(controller: note, maxLines: 3, decoration: const InputDecoration(labelText: 'Note')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              controller.addLessonNote(
                title: title.text,
                note: note.text,
                className: cls.text,
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
