import 'package:erp_frontend/app/modules/admin/views/admin_approvals_view.dart';
import 'package:erp_frontend/app/modules/admin/views/admin_dashboard_view.dart';
import 'package:erp_frontend/app/modules/admin/views/admin_notice_board_view.dart';
import 'package:erp_frontend/app/modules/admin/views/admin_reports_view.dart';
import 'package:erp_frontend/app/modules/admin/views/admin_settings_view.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_shell_controller.dart';
import 'package:erp_frontend/app/navbar/admin_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminShellView extends StatefulWidget {
  const AdminShellView({super.key});

  @override
  State<AdminShellView> createState() => _AdminShellViewState();
}

class _AdminShellViewState extends State<AdminShellView> {
  late final AdminShellController controller;

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
    final args = Get.arguments;
    final idx = (args is Map<String, dynamic> ? args['tabIndex'] : null);
    if (idx is int && idx >= 0 && idx < _tabs.length) {
      controller.setTab(idx);
    } else if (idx is num && idx.toInt() >= 0 && idx.toInt() < _tabs.length) {
      controller.setTab(idx.toInt());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: IndexedStack(index: controller.currentIndex.value, children: _tabs),
        bottomNavigationBar: AdminBottomNavBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.setTab,
        ),
      ),
    );
  }
}

