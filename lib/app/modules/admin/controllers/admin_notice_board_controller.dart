import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';

class Notice {
  final String title;
  final String description;
  final String status; // PUBLISHED, SCHEDULED, DRAFT
  final String time;
  final List<String> audiences;
  final String? imageUrl;
  Notice({
    required this.title,
    required this.description,
    required this.status,
    required this.time,
    required this.audiences,
    this.imageUrl,
  });
}

class AdminNoticeBoardController extends GetxController {
  final selectedTab = 0.obs; // 0: All, 1: Recent, 2: Drafts

  final notices = <Notice>[
    Notice(
      title: 'Parent-Teacher Meeting - Term 1',
      description:
          'Please be informed that the meeting scheduled for Friday has been moved to the main auditorium...',
      status: 'PUBLISHED',
      time: '2 hours ago',
      audiences: ['All Parents', 'Grade 10-12'],
    ),
    Notice(
      title: 'Annual Sports Day Registration',
      description:
          'Registration for the upcoming annual sports day opens tomorrow. Students can sign up for...',
      status: 'SCHEDULED',
      time: 'Tomorrow, 08:00 AM',
      audiences: ['All Students'],
    ),
    Notice(
      title: 'Staff Workshop: Digital Tools',
      description:
          'Draft agenda for the upcoming professional development workshop focusing on AI...',
      status: 'DRAFT',
      time: 'Modified 3d ago',
      audiences: ['All Staff'],
    ),
    Notice(
      title: 'Library New Arrivals',
      description:
          'Over 200 new titles have been added to the science section this week...',
      status: 'PUBLISHED',
      time: 'Published',
      audiences: ['Grades 6-12'],
      // imageUrl: 'https://...', // dummy
    ),
  ];

  void onTabChanged(int index) {
    selectedTab.value = index;
  }

  void onAddNotice() {
    AppToast.show('Create new notice');
  }

  void onNoticeTap(Notice notice) {
    AppToast.show(notice.title);
  }

  void goToSystemAuditLogs() {
    Get.toNamed(AppRoutes.ADMIN_AUDIT_LOGS);
  }
}
