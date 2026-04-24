import 'package:erp_frontend/app/modules/admin/views/admin_approvals_view.dart';
import 'package:erp_frontend/app/modules/admin/views/admin_dashboard_view.dart';
import 'package:erp_frontend/app/modules/admin/views/admin_notice_board_view.dart';
import 'package:erp_frontend/app/modules/admin/views/admin_reports_view.dart';
import 'package:erp_frontend/app/modules/admin/views/admin_settings_view.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_shell_controller.dart';
import 'package:erp_frontend/app/navbar/admin_bottom_nav_bar.dart';
import 'package:erp_frontend/common/widgets/double_back_exit_scope.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminShellView extends StatefulWidget {
  const AdminShellView({super.key});

  @override
  State<AdminShellView> createState() => _AdminShellViewState();
}

class _AdminShellViewState extends State<AdminShellView> {
  late final AdminShellController controller;
  int? _lastSyncedIndex;

  static const List<Widget> _tabs = [
    AdminDashboardView(embedded: true),
    AdminApprovalsView(embedded: true),
    AdminReportsView(embedded: true),
    AdminNoticeBoardView(embedded: true),
    AdminSettingsView(embedded: true),
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.find<AdminShellController>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleTabSync();
  }

  void _scheduleTabSync() {
    final index = AdminShellController.resolveIndex(arguments: Get.arguments);
    if (_lastSyncedIndex == index) return;
    _lastSyncedIndex = index;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      controller.setTab(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => DoubleBackExitScope(
        child: Scaffold(
          body: IndexedStack(
            index: controller.currentIndex.value,
            children: _tabs,
          ),
          bottomNavigationBar: AdminBottomNavBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.setTab,
          ),
        ),
      ),
    );
  }
}
