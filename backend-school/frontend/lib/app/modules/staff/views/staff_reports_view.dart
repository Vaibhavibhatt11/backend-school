import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/admin/models/admin_report_models.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_reports_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffReportsView extends GetView<StaffReportsController> {
  const StaffReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.loadReports,
          child: CustomScrollView(
            slivers: [
              _buildHeader(isDark),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),
                    _buildSectionHeader('Report Modules', isDark),
                    const SizedBox(height: 12),
                    _buildModuleGrid(isDark),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Quick Insights', isDark),
                    const SizedBox(height: 12),
                    _buildQuickInsights(isDark),
                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: const Text(
          'Reports & Analytics',
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
        ),
      ),
      actions: [
        IconButton(
          onPressed: controller.loadReports,
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
        ),
      ],
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
          desc: 'Class Performance',
          isDark: isDark,
        ),
        _moduleCard(
          kind: AdminReportKind.attendance,
          icon: Icons.how_to_reg_rounded,
          color: Colors.green,
          desc: 'Attendance Logs',
          isDark: isDark,
        ),
        _moduleCard(
          kind: AdminReportKind.productivity,
          icon: Icons.speed_rounded,
          color: Colors.orange,
          desc: 'My Efficiency',
          isDark: isDark,
        ),
        _moduleCard(
          kind: AdminReportKind.progress,
          icon: Icons.trending_up_rounded,
          color: Colors.purple,
          desc: 'Student Trends',
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

  Widget _buildQuickInsights(bool isDark) {
    return Column(
      children: [
        _insightTile(
          label: 'Class Attendance',
          value: controller.attendanceBadge,
          icon: Icons.pie_chart_rounded,
          color: Colors.green,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _insightTile(
          label: 'Productivity Score',
          value: controller.productivityScore,
          icon: Icons.bolt_rounded,
          color: Colors.orange,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _insightTile(
          label: 'Avg Exam Score',
          value: controller.academicPassRate,
          icon: Icons.auto_graph_rounded,
          color: Colors.purple,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _insightTile({
    required String label,
    required RxString value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
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
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Obx(() => Text(
                value.value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              )),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
        ],
      ),
    );
  }
}

