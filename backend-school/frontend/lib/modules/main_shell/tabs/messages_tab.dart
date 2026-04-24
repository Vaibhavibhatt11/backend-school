import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/theme/app_color.dart';
import '../../../modules/student/communication/student_communication_screen.dart';
import '../../../modules/student/communication/student_communication_controller.dart';
import '../../../modules/student/communication/schedule_meeting_screen.dart';

class MessagesTab extends StatelessWidget {
  const MessagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure the communication controller is available when using the screen directly in a tab.
    if (!Get.isRegistered<StudentCommunicationController>()) {
      Get.lazyPut<StudentCommunicationController>(() => StudentCommunicationController());
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: const StudentCommunicationScreen(embedded: true),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'student-messages-schedule-meeting-fab',
        onPressed: () => Get.to(() => const ScheduleMeetingScreen()),
        backgroundColor: AppColor.primary,
        foregroundColor: AppColor.base,
        icon: const Icon(Icons.video_call_rounded),
        label: const Text('Schedule'),
      ),
    );
  }
}
