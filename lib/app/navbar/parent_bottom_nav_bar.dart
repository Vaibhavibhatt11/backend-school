import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/utils/safe_navigation.dart';
import 'package:flutter/material.dart';

class ParentBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const ParentBottomNavBar({super.key, required this.currentIndex});

  void _onTap(int index) {
    if (index == currentIndex) return;
    switch (index) {
      case 0:
        SafeNavigation.offNamed(AppRoutes.PARENT_HOME);
        break;
      case 1:
        SafeNavigation.offNamed(AppRoutes.PARENT_ATTENDANCE);
        break;
      case 2:
        SafeNavigation.offNamed(AppRoutes.PARENT_FEES);
        break;
      case 3:
        SafeNavigation.offNamed(AppRoutes.PARENT_TIMETABLE);
        break;
      case 4:
        SafeNavigation.offNamed(AppRoutes.PARENT_PROFILE);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 'Home', currentIndex == 0, 0),
            _buildNavItem(Icons.how_to_reg, 'Attendance', currentIndex == 1, 1),
            _buildNavItem(Icons.payments, 'Fees', currentIndex == 2, 2),
            _buildNavItem(
              Icons.calendar_month,
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
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? const Color(0xFF137FEC) : Colors.grey),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: active ? const Color(0xFF137FEC) : Colors.grey,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
