import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_reports_controller.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_shell_controller.dart';
import 'package:erp_frontend/app/modules/admin/models/admin_report_models.dart';
import 'package:erp_frontend/app/navbar/admin_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminReportsView extends GetView<AdminReportsController> {
  final bool embedded;
  const AdminReportsView({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final content = Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.loadReports,
          child: CustomScrollView(
            slivers: [
              _buildSliverHeader(isDark),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildGlobalFilters(isDark),
                    const SizedBox(height: 28),
                    _buildSectionHeader('Report Modules', isDark),
                    const SizedBox(height: 12),
                    _buildModuleGrid(isDark),
                    const SizedBox(height: 28),
                    _buildSectionHeader('Key Performance Indicators', isDark),
                    const SizedBox(height: 12),
                    _buildQuickStats(isDark),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (embedded) return content;
    return Scaffold(
      body: content,
      bottomNavigationBar: AdminBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildSliverHeader(bool isDark) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: const Text(
          'Reports Hub',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primaryDark,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -10,
                child: Icon(
                  Icons.analytics_rounded,
                  size: 160,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ),
      ),
      leading: IconButton(
        onPressed: () {
          if (embedded && Get.isRegistered<AdminShellController>()) {
            Get.find<AdminShellController>().setTab(0);
            return;
          }
          if (Get.key.currentState?.canPop() ?? false) Get.back();
        },
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
      ),
      actions: [
        IconButton(
          onPressed: controller.loadReports,
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildGlobalFilters(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _filterItem(
              icon: Icons.calendar_today_rounded,
              label: 'RANGE',
              value: controller.selectedRange,
              onTap: controller.onRangeTap,
              isDark: isDark,
            ),
          ),
          Container(
            height: 40,
            width: 1,
            color: isDark ? AppColors.borderDark : Colors.grey[200],
          ),
          Expanded(
            child: _filterItem(
              icon: Icons.class_rounded,
              label: 'CLASS',
              value: controller.selectedClass,
              onTap: controller.onClassTap,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterItem({
    required IconData icon,
    required String label,
    required RxString value,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                  ),
                  Obx(() => Text(
                        value.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: isDark ? AppColors.textSecondaryDark : Colors.grey[600],
      ),
    );
  }

  Widget _buildModuleGrid(bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.9,
      children: [
        _moduleCard(
          kind: AdminReportKind.academic,
          icon: Icons.menu_book_rounded,
          color: Colors.blue,
          desc: 'Structure & Syllabus',
          isDark: isDark,
        ),
        _moduleCard(
          kind: AdminReportKind.attendance,
          icon: Icons.how_to_reg_rounded,
          color: Colors.green,
          desc: 'Daily Presence Logs',
          isDark: isDark,
        ),
        _moduleCard(
          kind: AdminReportKind.productivity,
          icon: Icons.speed_rounded,
          color: Colors.orange,
          desc: 'Staff Efficiency',
          isDark: isDark,
        ),
        _moduleCard(
          kind: AdminReportKind.progress,
          icon: Icons.trending_up_rounded,
          color: Colors.purple,
          desc: 'Academic Performance',
          isDark: isDark,
        ),
        _moduleCard(
          kind: AdminReportKind.fees,
          icon: Icons.payments_rounded,
          color: Colors.teal,
          desc: 'Collection Analytics',
          isDark: isDark,
        ),
        _moduleCard(
          kind: AdminReportKind.all,
          icon: Icons.auto_awesome_mosaic_rounded,
          color: Colors.indigo,
          desc: 'Complete Dashboard',
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _moduleCard({
    required AdminReportKind kind,
    required IconData icon,
    required Color color,
    required String desc,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () => controller.openReport(kind),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            Text(
              kind.title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: TextStyle(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Explore',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 12, color: color),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(bool isDark) {
    return Column(
      children: [
        _statTile(
          label: 'Attendance Rate',
          value: controller.attendanceBadge,
          icon: Icons.donut_large_rounded,
          color: Colors.green,
          isDark: isDark,
          onTap: () => controller.openReport(AdminReportKind.attendance),
        ),
        const SizedBox(height: 12),
        _statTile(
          label: 'Fees Outstanding',
          value: controller.feeOutstandingBadge,
          icon: Icons.money_off_rounded,
          color: Colors.red,
          isDark: isDark,
          onTap: () => controller.openReport(AdminReportKind.fees),
        ),
        const SizedBox(height: 12),
        _statTile(
          label: 'Pass Percentage',
          value: controller.progressPassBadge,
          icon: Icons.auto_graph_rounded,
          color: Colors.purple,
          isDark: isDark,
          onTap: () => controller.openReport(AdminReportKind.progress),
        ),
      ],
    );
  }

  Widget _statTile({
    required String label,
    required RxString value,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
            Obx(() => Text(
                  value.value,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: color,
                  ),
                )),
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
