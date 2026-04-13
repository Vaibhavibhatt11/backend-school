import 'package:erp_frontend/app/modules/teacher/controllers/teacher_shell_controller.dart';
import 'package:erp_frontend/app/modules/teacher/views/attendance_selector_view.dart';
import 'package:erp_frontend/app/modules/teacher/views/live_class_view.dart';
import 'package:erp_frontend/app/modules/teacher/views/teacher_home_view.dart';
import 'package:erp_frontend/app/modules/teacher/views/teacher_profile_view.dart';
import 'package:erp_frontend/app/modules/teacher/views/timetable_view.dart';
import 'package:erp_frontend/app/navbar/teacher_bottom_nav_bar.dart';
import 'package:erp_frontend/common/widgets/double_back_exit_scope.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TeacherShellView extends StatefulWidget {
  const TeacherShellView({super.key});

  @override
  State<TeacherShellView> createState() => _TeacherShellViewState();
}

class _TeacherShellViewState extends State<TeacherShellView> {
  late final TeacherShellController controller;
  int? _lastSyncedIndex;

  static const List<Widget> _tabs = [
    TeacherHomeView(embedded: true),
    AttendanceSelectorView(embedded: true),
    LiveClassView(embedded: true),
    TimetableView(embedded: true),
    TeacherProfileView(embedded: true),
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.find<TeacherShellController>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleTabSync();
  }

  void _scheduleTabSync() {
    final index = TeacherShellController.resolveIndex(
      Get.currentRoute,
      arguments: Get.arguments,
    );
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
          bottomNavigationBar: TeacherBottomNavBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.setTab,
          ),
        ),
      ),
    );
  }
}
