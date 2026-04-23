import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/navbar/admin_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  final bool embedded;
  const AdminDashboardView({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final content = SafeArea(
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.loadDashboard,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth >= 1000
                  ? 24.0
                  : constraints.maxWidth >= 700
                      ? 20.0
                      : 16.0;
              final quickGridCount = constraints.maxWidth >= 1100
                  ? 4
                  : constraints.maxWidth >= 700
                      ? 3
                      : 2;
              final wideStats = constraints.maxWidth >= 540;
              return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(horizontalPadding),
            children: [
            if (controller.dashboardError.value != null) ...[
              Material(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade800, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          controller.dashboardError.value!,
                          style: TextStyle(color: Colors.red.shade900, fontSize: 13),
                        ),
                      ),
                      TextButton(
                        onPressed: controller.loadDashboard,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Header with profile
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 380;
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        controller.adminName.value.isNotEmpty
                            ? controller.adminName.value
                                .trim()
                                .split(RegExp(r'\s+'))
                                .take(2)
                                .map((p) => p.isEmpty ? '' : p[0].toUpperCase())
                                .join()
                            : 'AD',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          Text(
                            controller.adminName.value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!compact) ...[
                      IconButton(
                        onPressed: controller.goToAttendance,
                        icon: const Icon(Icons.calendar_today_outlined),
                      ),
                      IconButton(
                        onPressed: controller.goToFeeSnapshot,
                        icon: const Icon(Icons.payments_outlined),
                      ),
                    ],
                    Stack(
                      children: [
                        IconButton(
                          onPressed: controller.loadDashboard,
                          icon: const Icon(Icons.notifications_none),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            // Horizontal scroll cards
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  GestureDetector(
                    onTap: controller.goToFeeSnapshot,
                    child: _buildFeeCard(),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: controller.goToAttendance,
                    child: _buildAttendanceCard(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Quick actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'QUICK ACTIONS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                TextButton(
                  onPressed: controller.goToAllModules,
                  child: const Text('View all modules'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: quickGridCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: constraints.maxWidth >= 700 ? 1.3 : 1.15,
              children:
                  controller.quickActions
                      .map((action) => _buildQuickAction(action))
                      .toList(),
            ),
            const SizedBox(height: 24),
            // Secondary stats
            wideStats
                ? Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Students',
                          '${controller.totalStudents.value}',
                          controller.dashboardError.value != null ? '—' : 'Live',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Teacher Presence',
                          '${controller.teacherPresence.value.toStringAsFixed(1)}%',
                          '${controller.teacherPresent.value}/${controller.teacherTotal.value}',
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _buildStatCard(
                        'Total Students',
                        '${controller.totalStudents.value}',
                        controller.dashboardError.value != null ? '—' : 'Live',
                      ),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        'Teacher Presence',
                        '${controller.teacherPresence.value.toStringAsFixed(1)}%',
                        '${controller.teacherPresent.value}/${controller.teacherTotal.value}',
                      ),
                    ],
                  ),
            const SizedBox(height: 16),
            // Pending approvals
            GestureDetector(
              onTap: controller.onPendingApprovalsTap,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade50,
                  border: Border.all(color: Colors.yellow.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.task_alt, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pending Approvals',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.yellow.shade800,
                            ),
                          ),
                          Text(
                            '${controller.pendingApprovals.value} items require your attention',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.yellow.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.yellow),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Attendance trend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ATTENDANCE TREND',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Last 7 Days',
                  style: TextStyle(color: AppColors.primary, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 120,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (index) {
                  return Expanded(
                    child: Container(
                      height: controller.attendanceTrend[index] * 0.8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.3 + index * 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children:
                  ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                      .map(
                        (day) => Text(
                          day,
                          style: TextStyle(
                            fontSize: 10,
                            color:
                                day == 'Sat' ? AppColors.primary : Colors.grey,
                          ),
                        ),
                      )
                      .toList(),
            ),
            ],
          );
            },
          ),
        );
      }),
    );
    if (embedded) return content;
    return Scaffold(body: content, bottomNavigationBar: AdminBottomNavBar(currentIndex: 0));
  }

  Widget _buildFeeCard() {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${controller.feeVsLastWeekPct.value >= 0 ? '+' : ''}${controller.feeVsLastWeekPct.value.toStringAsFixed(1)}% vs LW',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Fee Collected Today',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Text(
            '\$${controller.feeToday.value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pending: \$${controller.feePending.value.toStringAsFixed(0)}',
                style: TextStyle(fontSize: 11, color: Colors.white70),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard() {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.how_to_reg, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Student Attendance',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Row(
            children: [
              Text(
                '${controller.studentAttendancePct.value.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'of ${controller.totalStudents.value} students',
                style: const TextStyle(fontSize: 10, color: Colors.white70),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: List.generate(
              3,
              (index) => Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green, width: 2),
                  color: Colors.white.withValues(alpha: 0.3 - index * 0.1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String action) {
    IconData icon;
    Color color;
    switch (action) {
      case 'New Admission':
        icon = Icons.person_add;
        color = Colors.blue;
        break;
      case 'Broadcast':
        icon = Icons.campaign;
        color = Colors.orange;
        break;
      case 'Mark Leave':
        icon = Icons.event_note;
        color = Colors.purple;
        break;
      case 'Collect Fee':
        icon = Icons.request_quote;
        color = Colors.green;
        break;
      default:
        icon = Icons.help;
        color = Colors.grey;
    }
    return GestureDetector(
      onTap: () => controller.onQuickActionTap(action),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              Theme.of(Get.context!).brightness == Brightness.dark
                  ? AppColors.surfaceDark
                  : Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              action,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String sub) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            Theme.of(Get.context!).brightness == Brightness.dark
                ? AppColors.surfaceDark
                : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                sub,
                style: TextStyle(
                  fontSize: 10,
                  color: sub.startsWith('+') ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
