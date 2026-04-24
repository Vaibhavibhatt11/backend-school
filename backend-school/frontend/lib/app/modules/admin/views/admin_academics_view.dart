import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_academics_controller.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminAcademicsView extends GetView<AdminAcademicsController> {
  const AdminAcademicsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Academic Management'),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadInitialData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeaderCard(context),
            const SizedBox(height: 14),
            _buildDashboardStats(context),
            const SizedBox(height: 20),
            const _SectionTitle(title: 'Academic Workflows'),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.88,
              children: [
                _CategoryCard(
                  title: 'Classes & Sections',
                  subtitle: 'Structure your grades',
                  icon: Icons.meeting_room_rounded,
                  onTap: () => _showTabSheet(context, 0),
                ),
                _CategoryCard(
                  title: 'Subjects & Curriculum',
                  subtitle: 'Academic framework',
                  icon: Icons.menu_book_rounded,
                  onTap: () => _showTabSheet(context, 1),
                ),
                _CategoryCard(
                  title: 'Syllabus Tracker',
                  subtitle: 'Course coverage progress',
                  icon: Icons.track_changes_rounded,
                  onTap: () => _showTabSheet(context, 2),
                ),
                _CategoryCard(
                  title: 'Planning & Execution',
                  subtitle: 'Lesson plans & notes',
                  icon: Icons.edit_calendar_rounded,
                  onTap: () => _showTabSheet(context, 3),
                ),
                _CategoryCard(
                  title: 'Materials Vault',
                  subtitle: 'Digital study assets',
                  icon: Icons.cloud_upload_rounded,
                  onTap: () => Get.toNamed(AppRoutes.ADMIN_STUDY_MATERIAL),
                ),
                _CategoryCard(
                  title: 'Academic Reports',
                  subtitle: 'Performance insights',
                  icon: Icons.analytics_rounded,
                  onTap: () =>
                      Get.toNamed('/admin-reports', arguments: {'tabIndex': 2}),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
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
            child: const Icon(Icons.menu_book_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Academic Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Manage classes, syllabus, lesson plans and resources.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardStats(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: _QuickStat(
                label: 'Classes',
                value: controller.classes.length.toString(),
                icon: Icons.business_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickStat(
                label: 'Subjects',
                value: controller.subjects.length.toString(),
                icon: Icons.library_books_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickStat(
                label: 'Materials',
                value: controller.materials.length.toString(),
                icon: Icons.attachment_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTabSheet(BuildContext context, int initialIndex) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.bottomSheet(
      Container(
        height: Get.height * 0.9,
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Academic Workbench',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: DefaultTabController(
                length: 5,
                initialIndex: initialIndex,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                      ),
                      child: TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
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
                          Tab(text: 'Classes'),
                          Tab(text: 'Subjects'),
                          Tab(text: 'Syllabus'),
                          Tab(text: 'Lesson Plans'),
                          Tab(text: 'Materials'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _ClassesTabView(controller: controller),
                          _SubjectsTabView(controller: controller),
                          _SyllabusTabView(controller: controller),
                          _LessonPlanTabView(controller: controller),
                          _MaterialsTabView(controller: controller),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: isDark ? AppColors.textDark : AppColors.textLight,
      ),
    );
  }
}

// --- Tab Views (Detailed Implementations with Actions) ---

class _ClassesTabView extends StatelessWidget {
  const _ClassesTabView({required this.controller});
  final AdminAcademicsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () => controller.openClassDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add New Class'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isClassesLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.classes.length,
              itemBuilder: (context, index) {
                final item = controller.classes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.meeting_room),
                    ),
                    title: Text(item.label),
                    subtitle: Text(
                      '${item.studentsCount} Students • Teacher: ${item.classTeacherName}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              controller.openClassDialog(existing: item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => controller.deleteClass(item),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

class _SubjectsTabView extends StatelessWidget {
  const _SubjectsTabView({required this.controller});
  final AdminAcademicsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () => controller.openSubjectDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add New Subject'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isSubjectsLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.subjects.length,
              itemBuilder: (context, index) {
                final item = controller.subjects[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(
                        alpha: 0.12,
                      ),
                      child: const Icon(Icons.book, color: AppColors.primary),
                    ),
                    title: Text(item.name),
                    subtitle: Text(item.code),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: item.isActive,
                          onChanged: (_) =>
                              controller.toggleSubjectActive(item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => controller.deleteSubject(item),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

class _SyllabusTabView extends StatelessWidget {
  const _SyllabusTabView({required this.controller});
  final AdminAcademicsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () => controller.openSyllabusDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Log Syllabus Progress'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isExtraLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.syllabuses.isEmpty) {
              return const _EmptyState(message: 'No syllabus records found.');
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.syllabuses.length,
              itemBuilder: (context, index) {
                final item = controller.syllabuses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.subjectName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () => controller
                                      .openSyllabusDialog(existing: item),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      controller.deleteSyllabus(item),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          item.classLabel,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Topic: ${item.topic}'),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: item.progress / 100,
                          backgroundColor: Colors.grey[200],
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.progress.toInt()}% Completed',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

class _LessonPlanTabView extends StatelessWidget {
  const _LessonPlanTabView({required this.controller});
  final AdminAcademicsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () => controller.openLessonPlanDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Create Lesson Plan'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isExtraLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.lessonPlans.isEmpty) {
              return const _EmptyState(message: 'No lesson plans found.');
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.lessonPlans.length,
              itemBuilder: (context, index) {
                final item = controller.lessonPlans[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(
                      Icons.event_note_rounded,
                      color: AppColors.primary,
                    ),
                    title: Text(item.title),
                    subtitle: Text('${item.subject} • ${item.duration} mins'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              controller.openLessonPlanDialog(existing: item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => controller.deleteLessonPlan(item),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

class _MaterialsTabView extends StatelessWidget {
  const _MaterialsTabView({required this.controller});
  final AdminAcademicsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () => controller.uploadMaterial(),
            icon: const Icon(Icons.upload),
            label: const Text('Upload Material'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isExtraLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.materials.isEmpty) {
              return const _EmptyState(message: 'No materials found.');
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.materials.length,
              itemBuilder: (context, index) {
                final item = controller.materials[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(
                      item.type.toUpperCase() == 'VIDEO'
                          ? Icons.play_circle_fill_rounded
                          : Icons.picture_as_pdf_rounded,
                      color: AppColors.primary,
                    ),
                    title: Text(item.title),
                    subtitle: Text(item.subject),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => controller.deleteMaterial(item),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Text(
            message,
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),
      ),
    );
  }
}
