import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_shell_controller.dart';
import 'package:erp_frontend/app/modules/staff/views/staff_communication_view.dart';
import 'package:erp_frontend/app/modules/staff/views/staff_dashboard_view.dart';
import 'package:erp_frontend/app/modules/staff/views/staff_profile_view.dart';
import 'package:erp_frontend/app/modules/staff/views/staff_reports_view.dart';
import 'package:erp_frontend/app/modules/staff/views/staff_settings_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffShellView extends GetView<StaffShellController> {
  const StaffShellView({super.key});

  static const _tabs = [
    StaffDashboardView(),
    StaffProfileView(),
    StaffCommunicationView(),
    StaffReportsView(),
    StaffSettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final idx = (args is Map<String, dynamic> ? args['tabIndex'] : null);
    if (idx is int && idx >= 0 && idx < _tabs.length && controller.currentIndex.value != idx) {
      Future.microtask(() => controller.setTab(idx));
    } else if (idx is num && idx.toInt() >= 0 && idx.toInt() < _tabs.length && controller.currentIndex.value != idx.toInt()) {
      Future.microtask(() => controller.setTab(idx.toInt()));
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(
      () => Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: IndexedStack(index: controller.currentIndex.value, children: _tabs),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _item(Icons.dashboard_rounded, 'Home', 0),
                _item(Icons.badge_rounded, 'Profile', 1),
                _item(Icons.chat_rounded, 'Comms', 2),
                _item(Icons.bar_chart_rounded, 'Reports', 3),
                _item(Icons.settings_rounded, 'Settings', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(IconData icon, String label, int idx) {
    final active = controller.currentIndex.value == idx;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => controller.setTab(idx),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? AppColors.primary : Colors.grey),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: active ? AppColors.primary : Colors.grey,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

