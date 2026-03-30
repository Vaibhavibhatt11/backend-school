import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_dashboard_controller.dart';
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
        return ListView(
        padding: const EdgeInsets.all(16),
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
                    Text(
                      'Staff Dashboard',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textDark : AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(onPressed: controller.loadDashboard, icon: const Icon(Icons.refresh_rounded)),
            ],
          ),
          const SizedBox(height: 16),
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
            childAspectRatio: 1.2,
            children: [
              _quickAction('Dashboard', Icons.dashboard_rounded, Colors.green, 'dashboard'),
              _quickAction('Profile', Icons.badge_rounded, Colors.blue, 'profile'),
              _quickAction('Communication', Icons.support_agent_rounded, Colors.orange, 'communication_ai'),
              _quickAction('Reports', Icons.bar_chart_rounded, Colors.purple, 'reports'),
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
      );
      }),
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

