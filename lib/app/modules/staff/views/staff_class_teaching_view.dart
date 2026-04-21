import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/core/widgets/custom_app_bar.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_class_teaching_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffClassTeachingView extends GetView<StaffClassTeachingController> {
  const StaffClassTeachingView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: const CustomAppBar(title: 'Class & Teaching Management'),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _tabs(isDark),
            const SizedBox(height: 12),
            _activeBody(isDark),
          ],
        ),
      ),
    );
  }

  Widget _tabs(bool isDark) {
    const labels = [
      'Class List',
      'Student List',
      'Subject Assignments',
      'Classroom Schedule',
      'Class Notes',
    ];
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

  Widget _activeBody(bool isDark) {
    switch (controller.activeTab.value) {
      case 0:
        return _classList(isDark);
      case 1:
        return _studentList(isDark);
      case 2:
        return _subjectAssignments(isDark);
      case 3:
        return _schedule(isDark);
      default:
        return _notes(isDark);
    }
  }

  Widget _classList(bool isDark) {
    return _panel(
      isDark,
      'Class List',
      Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _addClassDialog,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Class'),
            ),
          ),
          const SizedBox(height: 8),
          ...controller.classList.map((row) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.class_rounded, color: AppColors.primary),
                title: Text('${row['name']}'),
                subtitle: Text('Section ${row['section']}'),
              )),
        ],
      ),
    );
  }

  Widget _studentList(bool isDark) {
    return _panel(
      isDark,
      'Student List',
      Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: _addStudentDialog,
              icon: const Icon(Icons.person_add_rounded),
              label: const Text('Add Student'),
            ),
          ),
          const SizedBox(height: 8),
          ...controller.studentList.map((row) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_rounded, color: AppColors.primary),
                title: Text('${row['name']}'),
                subtitle: Text('${row['className']}'),
              )),
        ],
      ),
    );
  }

  Widget _subjectAssignments(bool isDark) {
    return _panel(
      isDark,
      'Subject Assignments',
      Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: _addAssignmentDialog,
              icon: const Icon(Icons.assignment_ind_rounded),
              label: const Text('Assign Subject'),
            ),
          ),
          const SizedBox(height: 8),
          ...controller.subjectAssignments.map((row) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.menu_book_rounded, color: AppColors.primary),
                title: Text('${row['className']} · ${row['subject']}'),
                subtitle: Text('Teacher: ${row['teacher']}'),
              )),
        ],
      ),
    );
  }

  Widget _schedule(bool isDark) {
    return _panel(
      isDark,
      'Classroom Schedule',
      Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: _addScheduleDialog,
              icon: const Icon(Icons.schedule_rounded),
              label: const Text('Add Schedule Slot'),
            ),
          ),
          const SizedBox(height: 8),
          ...controller.classroomSchedule.map((row) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_rounded, color: AppColors.primary),
                title: Text('${row['className']} · ${row['subject']}'),
                subtitle: Text('${row['day']} · ${row['period']}'),
              )),
        ],
      ),
    );
  }

  Widget _notes(bool isDark) {
    return _panel(
      isDark,
      'Class Notes',
      Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: _addNoteDialog,
              icon: const Icon(Icons.note_add_rounded),
              label: const Text('Add Class Note'),
            ),
          ),
          const SizedBox(height: 8),
          ...controller.classNotes.map((row) => Container(
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

  Future<void> _addClassDialog() async {
    final name = TextEditingController();
    final section = TextEditingController();
    await Get.dialog(
      AlertDialog(
        title: const Text('Add Class'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Class Name')),
            const SizedBox(height: 8),
            TextField(controller: section, decoration: const InputDecoration(labelText: 'Section')),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              controller.addClass(name.text, section.text);
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _addStudentDialog() async {
    final name = TextEditingController();
    final cls = TextEditingController();
    await Get.dialog(
      AlertDialog(
        title: const Text('Add Student'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Student Name')),
            const SizedBox(height: 8),
            TextField(controller: cls, decoration: const InputDecoration(labelText: 'Class')),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              controller.addStudent(name.text, cls.text);
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _addAssignmentDialog() async {
    final cls = TextEditingController();
    final subj = TextEditingController();
    final teacher = TextEditingController();
    await Get.dialog(
      AlertDialog(
        title: const Text('Assign Subject'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: cls, decoration: const InputDecoration(labelText: 'Class')),
            const SizedBox(height: 8),
            TextField(controller: subj, decoration: const InputDecoration(labelText: 'Subject')),
            const SizedBox(height: 8),
            TextField(controller: teacher, decoration: const InputDecoration(labelText: 'Teacher')),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              controller.upsertSubjectAssignment(
                className: cls.text,
                subject: subj.text,
                teacher: teacher.text,
              );
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _addScheduleDialog() async {
    final cls = TextEditingController();
    final day = TextEditingController(text: 'Monday');
    final period = TextEditingController(text: '09:00-09:45');
    final subj = TextEditingController();
    await Get.dialog(
      AlertDialog(
        title: const Text('Add Schedule Slot'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: cls, decoration: const InputDecoration(labelText: 'Class')),
            const SizedBox(height: 8),
            TextField(controller: day, decoration: const InputDecoration(labelText: 'Day')),
            const SizedBox(height: 8),
            TextField(controller: period, decoration: const InputDecoration(labelText: 'Period')),
            const SizedBox(height: 8),
            TextField(controller: subj, decoration: const InputDecoration(labelText: 'Subject')),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              controller.addSchedule(
                className: cls.text,
                day: day.text,
                period: period.text,
                subject: subj.text,
              );
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _addNoteDialog() async {
    final cls = TextEditingController();
    final title = TextEditingController();
    final note = TextEditingController();
    await Get.dialog(
      AlertDialog(
        title: const Text('Add Class Note'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: cls, decoration: const InputDecoration(labelText: 'Class')),
              const SizedBox(height: 8),
              TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 8),
              TextField(controller: note, maxLines: 3, decoration: const InputDecoration(labelText: 'Note')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              controller.addClassNote(
                className: cls.text,
                title: title.text,
                note: note.text,
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
