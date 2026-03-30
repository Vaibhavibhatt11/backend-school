import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_dashboard_controller.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffDashboardView extends GetView<StaffDashboardController> {
  const StaffDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Obx(() {
        if (controller.isLoading.value && controller.todaySchedule.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return Stack(
          children: [
            ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.school_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back',
                      style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : Colors.grey[600]),
                    ),
                    Obx(
                      () => Text(
                        controller.staffName.value.isEmpty
                            ? 'Staff Dashboard'
                            : 'Hi, ${controller.staffName.value.split(' ').first}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textDark : AppColors.textLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'All modules',
                onPressed: () => Get.toNamed(AppRoutes.STAFF_MODULES),
                icon: const Icon(Icons.apps_rounded),
              ),
              IconButton(onPressed: controller.loadDashboard, icon: const Icon(Icons.refresh_rounded)),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.todayScheduleItems.isNotEmpty) {
              return SizedBox(
                height: 118,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.todayScheduleItems.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final it = controller.todayScheduleItems[i];
                    final subj = it['subject'] ?? '';
                    final cls = it['classLabel'] ?? '';
                    final line = cls.isNotEmpty ? '$subj · $cls' : subj;
                    return _scheduleChip(it['time'] ?? '', line, isDark);
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _summaryCard(
                  title: 'Today\'s Schedule',
                  icon: Icons.schedule_rounded,
                  lines: controller.todaySchedule,
                  colorA: AppColors.primary,
                  colorB: AppColors.primaryDark,
                ),
                const SizedBox(width: 12),
                _summaryCard(
                  title: 'Notifications',
                  icon: Icons.notifications_active_rounded,
                  lines: controller.notifications,
                  colorA: Colors.deepPurple,
                  colorB: Colors.indigo,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'QUICK ACTIONS',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]),
              ),
              TextButton(onPressed: controller.loadDashboard, child: const Text('Refresh')),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.15,
            children: [
              _quickAction('Dashboard', Icons.dashboard_rounded, Colors.green, 'dashboard'),
              _quickAction('Profile', Icons.badge_rounded, Colors.blue, 'profile'),
              _quickAction('Communication', Icons.support_agent_rounded, Colors.orange, 'communication'),
              _quickAction('Reports', Icons.bar_chart_rounded, Colors.purple, 'reports'),
              _quickAction('AI Assistant', Icons.smart_toy_rounded, Colors.teal, 'ai_teaching_assistant'),
            ],
          ),
          const SizedBox(height: 24),
          _miniTile('Assigned Classes', controller.assignedClasses, isDark),
          _miniTile('Pending Tasks', controller.pendingTasks, isDark),
          _miniTile('Student Alerts', controller.studentAlerts, isDark),
          _miniTile('Homework Status', controller.homeworkStatus, isDark),
          _miniTile('Upcoming Exams', controller.upcomingExams, isDark),
          _miniTile('Meetings', controller.meetings, isDark),
          const SizedBox(height: 12),
        ],
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton.extended(
                onPressed: controller.openAiAssistant,
                backgroundColor: AppColors.primary,
                icon: const Icon(Icons.smart_toy_rounded),
                label: const Text('AI'),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _scheduleChip(String time, String line, bool isDark) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(time, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
          const SizedBox(height: 6),
          Text(
            line.isEmpty ? 'Session' : line,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required IconData icon,
    required RxList<String> lines,
    required Color colorA,
    required Color colorB,
  }) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [colorA, colorB]),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              lines.isEmpty ? 'No updates' : lines.first,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Text(
              '${lines.length} items',
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(String title, IconData icon, Color color, String moduleId) {
    return GestureDetector(
      onTap: () => controller.openModule(moduleId),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _miniTile(String title, RxList<String> items, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        leading: const Icon(Icons.task_alt_rounded, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        children: [
          Obx(
            () => Column(
              children: items
                  .map(
                    (e) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(e),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

