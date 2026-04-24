import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/hostel_warden/controllers/hostel_warden_controller.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HostelWardenHubView extends GetView<HostelWardenController> {
  const HostelWardenHubView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Hostel Warden Portal'),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        actions: [
          IconButton(
            onPressed: controller.refreshData,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _header(),
            const SizedBox(height: 14),
            Obx(
              () => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _metric('Rooms', '${controller.operations.hostelRooms.length}', isDark),
                  _metric(
                    'Allocations',
                    '${controller.operations.hostelAllocations.length}',
                    isDark,
                  ),
                  _metric(
                    'Attendance',
                    '${controller.operations.hostelAttendance.length}',
                    isDark,
                  ),
                  _metric(
                    'Visitors',
                    '${controller.operations.hostelVisitors.length}',
                    isDark,
                  ),
                  _metric(
                    'Complaints',
                    '${controller.operations.hostelComplaints.length}',
                    isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _tile(
              title: 'Room Allocation',
              subtitle: 'Manage hostel rooms and student allocations.',
              icon: Icons.meeting_room_rounded,
              route: AppRoutes.HOSTEL_WARDEN_ROOM_ALLOCATION,
              isDark: isDark,
            ),
            _tile(
              title: 'Hostel Attendance',
              subtitle: 'Mark and track hostel attendance records.',
              icon: Icons.fact_check_rounded,
              route: AppRoutes.HOSTEL_WARDEN_ATTENDANCE,
              isDark: isDark,
            ),
            _tile(
              title: 'Visitor Logs',
              subtitle: 'Register visitors and manage check-out flow.',
              icon: Icons.how_to_reg_rounded,
              route: AppRoutes.HOSTEL_WARDEN_VISITORS,
              isDark: isDark,
            ),
            _tile(
              title: 'Hostel Complaints',
              subtitle: 'Create, triage, and resolve hostel complaints.',
              icon: Icons.report_problem_rounded,
              route: AppRoutes.HOSTEL_WARDEN_COMPLAINTS,
              isDark: isDark,
            ),
            _tile(
              title: 'Admin Hostel Desk',
              subtitle: 'Open admin hostel operations (shared records).',
              icon: Icons.admin_panel_settings_rounded,
              route: AppRoutes.ADMIN_OPERATIONS,
              args: {'initialTab': 0, 'scope': 'hostel'},
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hostel Management',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'End-to-end hostel operations for rooming, attendance, visitors, and complaints.',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );

  Widget _metric(String label, String value, bool isDark) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Text(
          '$label: $value',
          style: TextStyle(
            color: isDark ? AppColors.textDark : AppColors.textLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  Widget _tile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String route,
    dynamic args,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: ListTile(
        onTap: () => Get.toNamed(route, arguments: args),
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
