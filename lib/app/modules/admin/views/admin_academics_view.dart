import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_academics_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminAcademicsView extends GetView<AdminAcademicsController> {
  const AdminAcademicsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(child: _buildDashboardStats(context)),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildListDelegate([
                _CategoryCard(
                  title: 'Classes & Sections',
                  subtitle: 'Structure your grades',
                  icon: Icons.meeting_room_rounded,
                  color: Colors.blue,
                  onTap: () => _showTabSheet(context, 0),
                ),
                _CategoryCard(
                  title: 'Subjects & Curriculum',
                  subtitle: 'Academic framework',
                  icon: Icons.menu_book_rounded,
                  color: Colors.purple,
                  onTap: () => _showTabSheet(context, 1),
                ),
                _CategoryCard(
                  title: 'Syllabus Tracker',
                  subtitle: 'Course coverage progress',
                  icon: Icons.track_changes_rounded,
                  color: Colors.orange,
                  onTap: () => _showTabSheet(context, 2),
                ),
                _CategoryCard(
                  title: 'Planning & Execution',
                  subtitle: 'Lesson plans & Notes',
                  icon: Icons.edit_calendar_rounded,
                  color: Colors.green,
                  onTap: () => _showTabSheet(context, 3),
                ),
                _CategoryCard(
                  title: 'Materials Vault',
                  subtitle: 'Digital study assets',
                  icon: Icons.cloud_upload_rounded,
                  color: Colors.teal,
                  onTap: () => _showTabSheet(context, 4),
                ),
                _CategoryCard(
                  title: 'Academic Reports',
                  subtitle: 'Performance insights',
                  icon: Icons.analytics_rounded,
                  color: Colors.indigo,
                  onTap: () => Get.toNamed('/admin-reports', arguments: {'tabIndex': 2}),
                ),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('Academic Management', style: TextStyle(fontWeight: FontWeight.w800)),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: controller.loadInitialData,
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildDashboardStats(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Obx(() => Row(
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
      )),
    );
  }

  void _showTabSheet(BuildContext context, int initialIndex) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.bottomSheet(
      Container(
        height: Get.height * 0.9,
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : Colors.white,
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
            Expanded(
              child: DefaultTabController(
                length: 5,
                initialIndex: initialIndex,
                child: Column(
                  children: [
                    TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      indicatorColor: AppColors.primary,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: Colors.grey,
                      tabs: const [
                        Tab(text: 'Classes'),
                        Tab(text: 'Subjects'),
                        Tab(text: 'Syllabus'),
                        Tab(text: 'Lesson Plans'),
                        Tab(text: 'Materials'),
                      ],
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
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({required this.label, required this.value, required this.icon});
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
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
            style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isClassesLoading.value) return const Center(child: CircularProgressIndicator());
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.classes.length,
              itemBuilder: (context, index) {
                final item = controller.classes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.meeting_room)),
                    title: Text(item.label),
                    subtitle: Text('${item.studentsCount} Students • Teacher: ${item.classTeacherName}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit), onPressed: () => controller.openClassDialog(existing: item)),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.deleteClass(item)),
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
            style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.purple),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isSubjectsLoading.value) return const Center(child: CircularProgressIndicator());
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.subjects.length,
              itemBuilder: (context, index) {
                final item = controller.subjects[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(backgroundColor: Colors.purple, child: Icon(Icons.book, color: Colors.white)),
                    title: Text(item.name),
                    subtitle: Text(item.code),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: item.isActive,
                          onChanged: (_) => controller.toggleSubjectActive(item),
                        ),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.deleteSubject(item)),
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
            style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.orange),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isExtraLoading.value) return const Center(child: CircularProgressIndicator());
            if (controller.syllabuses.isEmpty) return const Center(child: Text('No syllabus records found.'));
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
                            Text(item.subjectName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => controller.openSyllabusDialog(existing: item)),
                                IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () => controller.deleteSyllabus(item)),
                              ],
                            ),
                          ],
                        ),
                        Text(item.classLabel, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 8),
                        Text('Topic: ${item.topic}'),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: item.progress / 100,
                          backgroundColor: Colors.grey[200],
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 4),
                        Text('${item.progress.toInt()}% Completed', style: const TextStyle(fontSize: 12)),
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
            style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.green),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isExtraLoading.value) return const Center(child: CircularProgressIndicator());
            if (controller.lessonPlans.isEmpty) return const Center(child: Text('No lesson plans found.'));
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.lessonPlans.length,
              itemBuilder: (context, index) {
                final item = controller.lessonPlans[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.event_note_rounded, color: Colors.green),
                    title: Text(item.title),
                    subtitle: Text('${item.subject} • ${item.duration} mins'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit), onPressed: () => controller.openLessonPlanDialog(existing: item)),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.deleteLessonPlan(item)),
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
            style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.teal),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isExtraLoading.value) return const Center(child: CircularProgressIndicator());
            if (controller.materials.isEmpty) return const Center(child: Text('No materials found.'));
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.materials.length,
              itemBuilder: (context, index) {
                final item = controller.materials[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(
                      item.type.toUpperCase() == 'VIDEO' ? Icons.play_circle_fill_rounded : Icons.picture_as_pdf_rounded,
                      color: Colors.teal,
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
