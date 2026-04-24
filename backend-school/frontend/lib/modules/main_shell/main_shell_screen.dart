import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/theme/app_color.dart';
import '../../common/utils/responsive.dart';
import '../../common/widgets/double_back_exit_scope.dart';
import '../../widgets/common_app_bar.dart';
import 'tabs/home_dashboard_tab.dart';
import 'tabs/learn_tab.dart';
import 'tabs/messages_tab.dart';
import 'tabs/more_tab.dart';
import 'main_shell_controller.dart';

class MainShellScreen extends GetView<MainShellController> {
  const MainShellScreen({super.key});

  static const List<_NavItem> _navItems = [
    _NavItem(icon: Icons.home_rounded, label: 'Home', activeIcon: Icons.home_rounded),
    _NavItem(icon: Icons.school_rounded, label: 'Learn', activeIcon: Icons.school_rounded),
    _NavItem(icon: Icons.chat_bubble_rounded, label: 'Messages', activeIcon: Icons.chat_bubble_rounded),
    _NavItem(icon: Icons.more_horiz_rounded, label: 'More', activeIcon: Icons.menu_rounded),
  ];

  static const List<String> _tabTitles = ['Home', 'Learn', 'Messages', 'More'];

  @override
  Widget build(BuildContext context) {
    return DoubleBackExitScope(
      child: Scaffold(
        appBar: _ShellAppBar(controller: controller, tabTitles: _tabTitles),
        body: Obx(() {
          return IndexedStack(
            index: controller.currentIndex.value,
            children: const [
              HomeDashboardTab(),
              LearnTab(),
              MessagesTab(),
              MoreTab(),
            ],
          );
        }),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppColor.base,
            boxShadow: [
              BoxShadow(
                color: AppColor.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(context, 8),
                vertical: Responsive.h(context, 8),
              ),
              child: Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(
                      _navItems.length,
                      (index) => _NavBarItem(
                        item: _navItems[index],
                        isSelected: controller.currentIndex.value == index,
                        onTap: () => controller.setIndex(index),
                      ),
                    ),
                  )),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShellAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ShellAppBar({required this.controller, required this.tabTitles});
  final MainShellController controller;
  final List<String> tabTitles;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Obx(() => CommonAppBar(
          title: tabTitles[controller.currentIndex.value],
          showBackButton: false,
        ));
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label, required this.activeIcon});
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 8)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? item.activeIcon : item.icon,
                  size: Responsive.w(context, 26),
                  color: isSelected ? AppColor.primary : AppColor.textMuted,
                ),
                SizedBox(height: Responsive.h(context, 4)),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 11),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppColor.primary : AppColor.textMuted,
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
