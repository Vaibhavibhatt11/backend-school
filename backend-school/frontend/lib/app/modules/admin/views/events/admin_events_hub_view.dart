import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/core/widgets/custom_app_bar.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_events_controller.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/utils/safe_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminEventsHubView extends GetView<AdminEventsController> {
  const AdminEventsHubView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: CustomAppBar(
        title: 'Events & Activities Hub',
        actions: [
          IconButton(
            onPressed: controller.refreshData,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Data',
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.events.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildKPIHeader(isDark),
              const SizedBox(height: 32),
              _buildSectionTitle('Event Management', isDark),
              const SizedBox(height: 16),
              _buildNavigationGrid(isDark, context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildKPIHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'At a Glance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                'Total Events',
                '${controller.totalEvents.value}',
                Icons.event_note_rounded,
                isDark,
                Colors.blueAccent,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildKPICard(
                'Active Competitions',
                '${controller.activeCompetitions.value}',
                Icons.emoji_events_rounded,
                isDark,
                Colors.orangeAccent,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildKPICard(
                'Total Registrations',
                '${controller.totalRegistrations.value}',
                Icons.how_to_reg_rounded,
                isDark,
                Colors.greenAccent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, bool isDark, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: accentColor, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: isDark ? AppColors.textDark : AppColors.textLight,
      ),
    );
  }

  Widget _buildNavigationGrid(bool isDark, BuildContext context) {
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: [
        _buildNavCard(
          title: 'Event Calendar',
          subtitle: 'Plan events and view photo galleries',
          icon: Icons.calendar_month_rounded,
          color: Colors.blueAccent,
          isDark: isDark,
          onTap: () => SafeNavigation.toNamed(AppRoutes.ADMIN_EVENTS_CALENDAR),
        ),
        _buildNavCard(
          title: 'Competitions',
          subtitle: 'Manage student competitions',
          icon: Icons.emoji_events_rounded,
          color: Colors.orangeAccent,
          isDark: isDark,
          onTap: () => SafeNavigation.toNamed(AppRoutes.ADMIN_EVENTS_COMPETITIONS),
        ),
        _buildNavCard(
          title: 'Registrations',
          subtitle: 'Track and manage event participants',
          icon: Icons.how_to_reg_rounded,
          color: Colors.greenAccent,
          isDark: isDark,
          onTap: () => SafeNavigation.toNamed(AppRoutes.ADMIN_EVENTS_REGISTRATIONS),
        ),
        _buildNavCard(
          title: 'Event Reports',
          subtitle: 'Analytics and participation tracking',
          icon: Icons.bar_chart_rounded,
          color: Colors.purpleAccent,
          isDark: isDark,
          onTap: () => SafeNavigation.toNamed(AppRoutes.ADMIN_EVENTS_REPORTS),
        ),
      ],
    );
  }

  Widget _buildNavCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ],
        ),
      ),
    );
  }
}
