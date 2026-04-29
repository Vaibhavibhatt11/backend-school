import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/utils/responsive.dart';
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
      constraints: BoxConstraints(
        minHeight: Responsive.clamp(context, 76, min: 68, max: 92),
      ),
      padding: EdgeInsets.symmetric(
        vertical: Responsive.clamp(context, 6, min: 4, max: 10),
        horizontal: Responsive.clamp(context, 12, min: 8, max: 18),
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Responsive.clamp(context, 20, min: 14, max: 26)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, Icons.home, 'Home', currentIndex == 0, 0),
            _buildNavItem(context, Icons.how_to_reg, 'Attendance', currentIndex == 1, 1),
            _buildNavItem(context, Icons.video_call, 'Classes', currentIndex == 2, 2),
            _buildNavItem(
              context,
              Icons.calendar_today,
              'Timetable',
              currentIndex == 3,
              3,
            ),
            _buildNavItem(context, Icons.person, 'Profile', currentIndex == 4, 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    bool active,
    int index,
  ) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onTap(index),
          borderRadius: BorderRadius.circular(
            Responsive.clamp(context, 16, min: 12, max: 20),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: Responsive.clamp(context, 6, min: 4, max: 10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: Responsive.clamp(context, 22, min: 18, max: 26),
                  color: active ? AppColors.primary : Colors.grey,
                ),
                SizedBox(height: Responsive.clamp(context, 4, min: 2, max: 6)),
                SizedBox(
                  height: Responsive.clamp(context, 12, min: 10, max: 16),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: Responsive.sp(context, 10),
                        color: active ? AppColors.primary : Colors.grey,
                        fontWeight: active
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
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
