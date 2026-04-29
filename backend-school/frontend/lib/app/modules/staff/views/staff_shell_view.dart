import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_shell_controller.dart';
import 'package:erp_frontend/app/modules/staff/views/staff_communication_view.dart';
import 'package:erp_frontend/app/modules/staff/views/staff_dashboard_view.dart';
import 'package:erp_frontend/app/modules/staff/views/staff_profile_view.dart';
import 'package:erp_frontend/app/modules/staff/views/staff_reports_view.dart';
import 'package:erp_frontend/app/modules/staff/views/staff_settings_view.dart';
import 'package:erp_frontend/common/widgets/double_back_exit_scope.dart';
import 'package:erp_frontend/common/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffShellView extends StatefulWidget {
  const StaffShellView({super.key});

  @override
  State<StaffShellView> createState() => _StaffShellViewState();
}

class _StaffShellViewState extends State<StaffShellView> {
  late final StaffShellController controller;
  int? _lastSyncedIndex;

  static const _tabs = [
    StaffDashboardView(),
    StaffProfileView(),
    StaffCommunicationView(),
    StaffReportsView(),
    StaffSettingsView(),
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.find<StaffShellController>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleTabSync();
  }

  void _scheduleTabSync() {
    final index = StaffShellController.resolveIndex(arguments: Get.arguments);
    if (_lastSyncedIndex == index) return;
    _lastSyncedIndex = index;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      controller.setTab(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(
      () => DoubleBackExitScope(
        child: Scaffold(
          backgroundColor: isDark
              ? AppColors.backgroundDark
              : AppColors.backgroundLight,
          body: ResponsivePageContainer(
            maxWidth: 1100,
            padding: EdgeInsets.zero,
            child: IndexedStack(
              index: controller.currentIndex.value,
              children: _tabs,
            ),
          ),
          bottomNavigationBar: Container(
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
      ),
    );
  }

  Widget _item(IconData icon, String label, int idx) {
    final active = controller.currentIndex.value == idx;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => controller.setTab(idx),
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
                      fontWeight: active ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
