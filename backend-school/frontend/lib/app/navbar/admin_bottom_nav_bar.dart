import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/utils/safe_navigation.dart';
import 'package:flutter/material.dart';

class AdminBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  const AdminBottomNavBar({super.key, required this.currentIndex, this.onTap});

  void _onTap(int index) {
    if (onTap != null) {
      onTap!(index);
      return;
    }
    if (index == currentIndex) return;
    switch (index) {
      case 0:
        SafeNavigation.offNamed(
          AppRoutes.ADMIN_HOME,
          arguments: {'tabIndex': 0},
        );
        break;
      case 1:
        SafeNavigation.offNamed(
          AppRoutes.ADMIN_APPROVALS,
          arguments: {'tabIndex': 1},
        );
        break;
      case 2:
        SafeNavigation.offNamed(
          AppRoutes.ADMIN_REPORTS,
          arguments: {'tabIndex': 2},
        );
        break;
      case 3:
        SafeNavigation.offNamed(
          AppRoutes.ADMIN_NOTICE_BOARD,
          arguments: {'tabIndex': 3},
        );
        break;
      case 4:
        SafeNavigation.offNamed(
          AppRoutes.ADMIN_SETTINGS,
          arguments: {'tabIndex': 4},
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
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
        top: false,
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
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onTap(index),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: active ? AppColors.primary : Colors.grey,
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 12,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 10,
                        color: active ? AppColors.primary : Colors.grey,
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
