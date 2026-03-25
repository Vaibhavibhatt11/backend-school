import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/theme/app_color.dart';
import '../../../common/fonts/common_textstyle.dart';
import '../../../common/utils/responsive.dart';
import '../../../widgets/module_tile.dart';
import '../../../widgets/section_header.dart';
import '../dashboard/student_dashboard_controller.dart';

class StudentDashboardScreen extends GetView<StudentDashboardController> {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Responsive.h(context, 16)),
              Obx(() => Text(
                    '${controller.greeting.value}, ${controller.userName.value}',
                    style: AppTextStyle.headlineLarge(context),
                  )),
              SizedBox(height: Responsive.h(context, 4)),
              Text(
                'Choose a module to continue',
                style: AppTextStyle.bodySmall(context),
              ),
              SizedBox(height: Responsive.h(context, 20)),
              SectionHeader(title: 'Academics'),
              _tile(context, 'Profile', Icons.person_rounded, controller.goToProfile),
              _tile(context, 'Timetable', Icons.calendar_month_rounded, controller.goToTimetable),
              _tile(context, 'Attendance', Icons.fact_check_rounded, controller.goToAttendance),
              _tile(context, 'Homework', Icons.assignment_rounded, controller.goToHomework),
              _tile(context, 'Study Materials', Icons.menu_book_rounded, controller.goToStudyMaterials),
              _tile(context, 'Exams', Icons.quiz_rounded, controller.goToExams),
              SizedBox(height: Responsive.h(context, 12)),
              // AI options commented for now
              // SectionHeader(title: 'AI Assistants'),
              // _tile(context, 'AI Study Assistant', Icons.smart_toy_rounded, controller.goToAiStudy),
              // _tile(context, 'AI Career Advisor', Icons.work_rounded, controller.goToAiCareer),
              // SizedBox(height: Responsive.h(context, 12)),
              SectionHeader(title: 'Finance & Services'),
              _tile(context, 'Fees', Icons.payments_rounded, controller.goToFees),
              _tile(context, 'Communication', Icons.chat_rounded, controller.goToCommunication),
              _tile(context, 'Events', Icons.event_rounded, controller.goToEvents),
              _tile(context, 'Health', Icons.health_and_safety_rounded, controller.goToHealth),
              // Transport module commented for now
              // _tile(context, 'Transport', Icons.directions_bus_rounded, controller.goToTransport),
              // Library module commented for now
              // _tile(context, 'Library', Icons.local_library_rounded, controller.goToLibrary),
              SizedBox(height: Responsive.h(context, 12)),
              SectionHeader(title: 'More'),
              // Achievements module commented for now
              // _tile(context, 'Achievements', Icons.emoji_events_rounded, controller.goToAchievements),
              _tile(context, 'Settings', Icons.settings_rounded, controller.goToSettings),
              SizedBox(height: Responsive.h(context, 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.h(context, 8)),
      child: ModuleTile(title: title, icon: icon, onTap: onTap),
    );
  }
}
