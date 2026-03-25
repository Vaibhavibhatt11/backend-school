import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminBottomNavBar extends StatelessWidget {
  final int currentIndex;
  const AdminBottomNavBar({super.key, required this.currentIndex});

  void _onTap(int index) {
    switch (index) {
      case 0:
        Get.offNamed(AppRoutes.ADMIN_HOME);
        break;
      case 1:
        Get.offNamed(AppRoutes.ADMIN_APPROVALS);
        break;
      case 2:
        Get.offNamed(AppRoutes.ADMIN_REPORTS);
        break;
      case 3:
        Get.offNamed(AppRoutes.ADMIN_NOTICE_BOARD);
        break;
      case 4:
        Get.offNamed(AppRoutes.ADMIN_SETTINGS);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.dashboard, 'Dashboard', currentIndex == 0, 0),
            _buildNavItem(Icons.fact_check, 'Approvals', currentIndex == 1, 1),
            _buildNavItem(Icons.bar_chart, 'Reports', currentIndex == 2, 2),
            _buildNavItem(Icons.campaign, 'Notices', currentIndex == 3, 3),
            _buildNavItem(Icons.settings, 'Settings', currentIndex == 4, 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool active, int index) {
    return GestureDetector(
      onTap: () => _onTap(index),
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
            ),
          ),
        ],
      ),
    );
  }
}
