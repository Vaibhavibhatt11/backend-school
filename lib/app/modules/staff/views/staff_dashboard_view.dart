import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_dashboard_controller.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/utils/safe_navigation.dart';
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
                onPressed: () =>
                    SafeNavigation.toNamed(AppRoutes.STAFF_MODULES),
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
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Obx(
              () => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _dashTab('Today', 0),
                    _dashTab('Classes', 1),
                    _dashTab('Tasks', 2),
                    _dashTab('Alerts', 3),
                    _dashTab('Notify', 4),
                    _dashTab('Homework', 5),
                    _dashTab('Exams', 6),
                    _dashTab('Meetings', 7),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => _dashboardFeaturePanel(isDark)),
          const SizedBox(height: 18),
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

  Widget _dashTab(String label, int index) {
    final selected = controller.selectedDashboardTab.value == index;
    return GestureDetector(
      onTap: () => controller.setDashboardTab(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.primary : null,
          ),
        ),
      ),
    );
  }

  Widget _dashboardFeaturePanel(bool isDark) {
    final idx = controller.selectedDashboardTab.value;
    if (idx == 0) {
      return _recordPanel(
        isDark: isDark,
        title: "Today's Schedule",
        records: controller.scheduleRecords,
        detailBuilder: (e) =>
            '${e['time'] ?? '-'} | ${e['subject'] ?? '-'} | ${e['classLabel'] ?? '-'}',
        onAdd: null,
      );
    }
    if (idx == 1) {
      return _recordPanel(
        isDark: isDark,
        title: 'Assigned Classes',
        records: controller.classRecords,
        detailBuilder: (e) => e['name'] ?? '-',
        onAdd: null,
      );
    }
    if (idx == 2) {
      return _recordPanel(
        isDark: isDark,
        title: 'Pending Tasks',
        records: controller.taskRecords,
        detailBuilder: (e) => e['title'] ?? '-',
        onAdd: controller.addTaskRecord,
        statusActions: const ['IN_PROGRESS', 'DONE'],
        statusUpdater: (id, status) =>
            controller.updateRecordStatus(controller.taskRecords, id, status),
        onDelete: (id) => controller.deleteRecord(controller.taskRecords, id),
      );
    }
    if (idx == 3) {
      return _recordPanel(
        isDark: isDark,
        title: 'Student Alerts',
        records: controller.alertRecords,
        detailBuilder: (e) => e['title'] ?? '-',
        statusActions: const ['ACKNOWLEDGED', 'RESOLVED'],
        statusUpdater: (id, status) =>
            controller.updateRecordStatus(controller.alertRecords, id, status),
      );
    }
    if (idx == 4) {
      return _recordPanel(
        isDark: isDark,
        title: 'Notifications',
        records: controller.notificationRecords,
        detailBuilder: (e) => e['title'] ?? '-',
        statusActions: const ['READ', 'ARCHIVED'],
        statusUpdater: (id, status) => controller.updateRecordStatus(
          controller.notificationRecords,
          id,
          status,
        ),
      );
    }
    if (idx == 5) {
      return _recordPanel(
        isDark: isDark,
        title: 'Homework Status',
        records: controller.homeworkRecords,
        detailBuilder: (e) => e['title'] ?? '-',
        statusActions: const ['CHECKED', 'COMPLETED'],
        statusUpdater: (id, status) =>
            controller.updateRecordStatus(controller.homeworkRecords, id, status),
      );
    }
    if (idx == 6) {
      return _recordPanel(
        isDark: isDark,
        title: 'Upcoming Exams',
        records: controller.examRecords,
        detailBuilder: (e) => e['title'] ?? '-',
        statusActions: const ['READY', 'COMPLETED'],
        statusUpdater: (id, status) =>
            controller.updateRecordStatus(controller.examRecords, id, status),
      );
    }
    return _recordPanel(
      isDark: isDark,
      title: 'Meetings',
      records: controller.meetingRecords,
      detailBuilder: (e) => e['title'] ?? '-',
      statusActions: const ['ATTENDED', 'CLOSED'],
      statusUpdater: (id, status) =>
          controller.updateRecordStatus(controller.meetingRecords, id, status),
    );
  }

  Widget _recordPanel({
    required bool isDark,
    required String title,
    required RxList<Map<String, String>> records,
    required String Function(Map<String, String>) detailBuilder,
    Future<void> Function()? onAdd,
    List<String> statusActions = const [],
    void Function(String id, String status)? statusUpdater,
    void Function(String id)? onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
                if (onAdd != null)
                  IconButton(
                    tooltip: 'Add',
                    onPressed: onAdd,
                    icon: const Icon(Icons.add_circle_rounded),
                  ),
              ],
            ),
            if (records.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text('No items available', style: TextStyle(color: Colors.grey)),
              )
            else
              ...records.map((item) {
                final id = item['id'] ?? '';
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(detailBuilder(item)),
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${item['status'] ?? '-'}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      if (statusActions.isNotEmpty || onDelete != null) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            ...statusActions.map(
                              (status) => OutlinedButton(
                                onPressed: statusUpdater == null || id.isEmpty
                                    ? null
                                    : () => statusUpdater(id, status),
                                child: Text(status),
                              ),
                            ),
                            if (onDelete != null)
                              FilledButton.tonal(
                                onPressed: id.isEmpty ? null : () => onDelete(id),
                                child: const Text('Remove'),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

