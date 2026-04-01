import 'package:erp_frontend/app/modules/parent/controllers/parent_shell_controller.dart';
import 'package:erp_frontend/app/modules/parent/views/attendance_tracker_view.dart';
import 'package:erp_frontend/app/modules/parent/views/daily_timetable_view.dart';
import 'package:erp_frontend/app/modules/parent/views/fees_management_view.dart';
import 'package:erp_frontend/app/modules/parent/views/parent_home_view.dart';
import 'package:erp_frontend/app/modules/parent/views/student_profile_hub_view.dart';
import 'package:erp_frontend/app/navbar/parent_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ParentShellView extends StatefulWidget {
  const ParentShellView({super.key});

  @override
  State<ParentShellView> createState() => _ParentShellViewState();
}

class _ParentShellViewState extends State<ParentShellView> {
  late final ParentShellController controller;

  static const List<Widget> _tabs = [
    ParentHomeView(embedded: true),
    AttendanceTrackerView(embedded: true),
    FeesManagementView(embedded: true),
    DailyTimetableView(embedded: true),
    StudentProfileHubView(embedded: true),
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.find<ParentShellController>();
    _syncNavigationState();
  }

  void _syncNavigationState() {
    final index = ParentShellController.resolveIndex(
      Get.currentRoute,
      arguments: Get.arguments,
    );
    if (controller.currentIndex.value != index) {
      Future.microtask(() => controller.setTab(index));
    }
  }

  @override
  Widget build(BuildContext context) {
    _syncNavigationState();
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: _tabs,
        ),
        bottomNavigationBar: ParentBottomNavBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.setTab,
        ),
      ),
    );
  }
}
