import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/utils/safe_navigation.dart';
import 'package:flutter/material.dart';

class TeacherBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const TeacherBottomNavBar({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  void _onTap(int index) {
    if (onTap != null) {
      onTap!(index);
      return;
    }
    if (index == currentIndex) return;
    switch (index) {
      case 0:
        SafeNavigation.offNamed(AppRoutes.TEACHER_HOME);
        break;
      case 1:
        SafeNavigation.offNamed(AppRoutes.TEACHER_ATTENDANCE_SELECTOR);
        break;
      case 2:
        SafeNavigation.offNamed(AppRoutes.TEACHER_LIVE_CLASS); // Classes hub
        break;
      case 3:
        SafeNavigation.offNamed(AppRoutes.TEACHER_TIMETABLE);
        break;
      case 4:
        SafeNavigation.offNamed(AppRoutes.TEACHER_PROFILE);
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
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
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
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onTap(index),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
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
          ),
        ),
      ),
    );
  }
}
