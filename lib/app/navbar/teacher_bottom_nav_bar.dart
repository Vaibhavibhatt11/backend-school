import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TeacherBottomNavBar extends StatelessWidget {
  final int currentIndex;
  const TeacherBottomNavBar({super.key, required this.currentIndex});

  void _onTap(int index) {
    switch (index) {
      case 0:
        Get.offNamed(AppRoutes.TEACHER_HOME);
        break;
      case 1:
        Get.offNamed(AppRoutes.TEACHER_ATTENDANCE_SELECTOR);
        break;
      case 2:
        Get.offNamed(AppRoutes.TEACHER_LIVE_CLASS); // Classes hub
        break;
      case 3:
        Get.offNamed(AppRoutes.TEACHER_TIMETABLE);
        break;
      case 4:
        Get.offNamed(AppRoutes.TEACHER_PROFILE);
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
            _buildNavItem(Icons.home, 'Home', currentIndex == 0, 0),
            _buildNavItem(Icons.how_to_reg, 'Attendance', currentIndex == 1, 1),
            _buildNavItem(Icons.video_call, 'Classes', currentIndex == 2, 2),
            _buildNavItem(
              Icons.calendar_today,
              'Timetable',
              currentIndex == 3,
              3,
            ),
            _buildNavItem(Icons.person, 'Profile', currentIndex == 4, 4),
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
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
