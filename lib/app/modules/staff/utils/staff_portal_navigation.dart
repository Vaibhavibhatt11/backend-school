import 'package:erp_frontend/app/modules/staff/widgets/staff_ai_assistant_sheet.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_shell_controller.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/utils/safe_navigation.dart';
import 'package:get/get.dart';

class StaffPortalScreen {
  const StaffPortalScreen({
    required this.title,
    required this.description,
    this.route,
    this.arguments,
    this.opensAssistant = false,
  });

  final String title;
  final String description;
  final String? route;
  final dynamic arguments;
  final bool opensAssistant;
}

class StaffPortalNavigation {
  StaffPortalNavigation._();

  static List<StaffPortalScreen> screensForModule(String moduleId) {
    switch (moduleId) {
      case 'dashboard':
        return const [
          StaffPortalScreen(
            title: 'Staff Dashboard',
            description: 'Live schedule, notifications, and workload summary.',
            route: AppRoutes.STAFF_HOME,
            arguments: {'tabIndex': 0},
          ),
          StaffPortalScreen(
            title: 'Reports',
            description: 'View current reporting and analytics.',
            route: AppRoutes.STAFF_HOME,
            arguments: {'tabIndex': 3},
          ),
        ];
      case 'profile':
        return const [
          StaffPortalScreen(
            title: 'Staff Profile',
            description: 'Live identity, department, and document details.',
            route: AppRoutes.STAFF_HOME,
            arguments: {'tabIndex': 1},
          ),
          StaffPortalScreen(
            title: 'Settings',
            description: 'Review account preferences and session controls.',
            route: AppRoutes.STAFF_HOME,
            arguments: {'tabIndex': 4},
          ),
        ];
      case 'attendance_leave':
        return const [
          StaffPortalScreen(
            title: 'Attendance & Leave Management',
            description:
                'Manage staff attendance, leave flow, approvals, reports, and late tracking.',
            route: AppRoutes.STAFF_ATTENDANCE_LEAVE,
          ),
          StaffPortalScreen(
            title: 'Attendance Reports',
            description: 'Open the attendance report dashboard view.',
            route: AppRoutes.STAFF_ATTENDANCE_LEAVE,
            arguments: {'tab': 'reports'},
          ),
        ];
      case 'class_teaching':
        return const [
          StaffPortalScreen(
            title: 'Class & Teaching Management',
            description:
                'Manage class list, students, assignments, schedule, and notes.',
            route: AppRoutes.STAFF_CLASS_TEACHING,
          ),
          StaffPortalScreen(
            title: 'Classroom Schedule',
            description: 'Open teaching schedule workspace.',
            route: AppRoutes.STAFF_CLASS_TEACHING,
            arguments: {'tab': 'schedule'},
          ),
        ];
      case 'lesson_planning':
        return const [
          StaffPortalScreen(
            title: 'Lesson Planning',
            description:
                'Create lesson plans, schedule topics, and manage lesson notes.',
            route: AppRoutes.STAFF_LESSON_PLANNING,
          ),
          StaffPortalScreen(
            title: 'Topic Scheduling',
            description: 'Open the lesson topic scheduling workspace.',
            route: AppRoutes.STAFF_LESSON_PLANNING,
            arguments: {'tab': 'topics'},
          ),
          StaffPortalScreen(
            title: 'Lesson Notes',
            description: 'Open lesson notes workspace.',
            route: AppRoutes.STAFF_LESSON_PLANNING,
            arguments: {'tab': 'notes'},
          ),
        ];
      case 'homework_assignment':
        return const [
          StaffPortalScreen(
            title: 'Homework & Assignment Management',
            description:
                'Create homework, set deadlines, review submissions, and share feedback.',
            route: AppRoutes.STAFF_HOMEWORK_ASSIGNMENT,
          ),
          StaffPortalScreen(
            title: 'Submissions',
            description: 'Open assignment submission tracking workspace.',
            route: AppRoutes.STAFF_HOMEWORK_ASSIGNMENT,
            arguments: {'tab': 'submissions'},
          ),
          StaffPortalScreen(
            title: 'Feedback',
            description: 'Open assignment feedback workspace.',
            route: AppRoutes.STAFF_HOMEWORK_ASSIGNMENT,
            arguments: {'tab': 'feedback'},
          ),
        ];
      case 'exam_assessment':
        return const [
          StaffPortalScreen(
            title: 'Exam & Assessment Management',
            description:
                'Create exams, upload papers, enter marks, configure grading, and publish results.',
            route: AppRoutes.STAFF_EXAM_ASSESSMENT,
          ),
          StaffPortalScreen(
            title: 'Marks Entry',
            description: 'Open marks entry workflow.',
            route: AppRoutes.STAFF_EXAM_ASSESSMENT,
            arguments: {'tab': 'marks'},
          ),
          StaffPortalScreen(
            title: 'Result Publishing',
            description: 'Open result publishing workflow.',
            route: AppRoutes.STAFF_EXAM_ASSESSMENT,
            arguments: {'tab': 'results'},
          ),
        ];
      case 'performance':
        return const [
          StaffPortalScreen(
            title: 'Student Performance Monitoring',
            description:
                'Track marks, attendance, progress reports, and weak students.',
            route: AppRoutes.STAFF_PERFORMANCE_MONITORING,
          ),
          StaffPortalScreen(
            title: 'Attendance Monitoring',
            description: 'Open student attendance monitoring workspace.',
            route: AppRoutes.STAFF_PERFORMANCE_MONITORING,
            arguments: {'tab': 'attendance'},
          ),
          StaffPortalScreen(
            title: 'Weak Students',
            description: 'Open weak student identification workspace.',
            route: AppRoutes.STAFF_PERFORMANCE_MONITORING,
            arguments: {'tab': 'weak'},
          ),
        ];
      case 'communication':
      case 'communication_ai':
        return const [
          StaffPortalScreen(
            title: 'Communication Center',
            description: 'Live messages, meetings, and announcements.',
            route: AppRoutes.STAFF_HOME,
            arguments: {'tabIndex': 2},
          ),
          StaffPortalScreen(
            title: 'Message Parents',
            description: 'Open the parent communication directory.',
            route: AppRoutes.STAFF_COMMUNICATION_RECIPIENTS,
            arguments: {'audience': 'parent'},
          ),
          StaffPortalScreen(
            title: 'Message Students',
            description: 'Open the student communication directory.',
            route: AppRoutes.STAFF_COMMUNICATION_RECIPIENTS,
            arguments: {'audience': 'student'},
          ),
          StaffPortalScreen(
            title: 'Announcements',
            description: 'Create and publish school announcements.',
            route: AppRoutes.STAFF_COMMUNICATION_ANNOUNCEMENTS,
          ),
          StaffPortalScreen(
            title: 'Notifications',
            description: 'Review communication and system notifications.',
            route: AppRoutes.STAFF_COMMUNICATION_NOTIFICATIONS,
          ),
          StaffPortalScreen(
            title: 'Parent-Teacher Meetings',
            description: 'Schedule PTMs and send meeting invitations.',
            route: AppRoutes.STAFF_COMMUNICATION_MEETINGS,
          ),
          StaffPortalScreen(
            title: 'AI Communication Drafting',
            description: 'Open AI support for notices and message drafts.',
            opensAssistant: true,
          ),
        ];
      case 'study_material':
        return const [
          StaffPortalScreen(
            title: 'Study Material Management',
            description: 'Manage notes, videos, PDFs, and learning resources.',
            route: AppRoutes.STAFF_STUDY_MATERIAL,
          ),
          StaffPortalScreen(
            title: 'Reports',
            description: 'Track material-related reporting visibility.',
            route: AppRoutes.STAFF_HOME,
            arguments: {'tabIndex': 3},
          ),
        ];
      case 'events':
        return const [
          StaffPortalScreen(
            title: 'Announcements',
            description: 'Publish event and activity updates.',
            route: AppRoutes.TEACHER_ANNOUNCEMENTS,
          ),
          StaffPortalScreen(
            title: 'Communication Center',
            description: 'Coordinate updates with stakeholders.',
            route: AppRoutes.STAFF_HOME,
            arguments: {'tabIndex': 2},
          ),
        ];
      case 'library':
        return const [
          StaffPortalScreen(
            title: 'Reports',
            description: 'Use current analytics for library-linked activity.',
            route: AppRoutes.STAFF_HOME,
            arguments: {'tabIndex': 3},
          ),
          StaffPortalScreen(
            title: 'Staff Dashboard',
            description: 'Stay aligned with the latest operational snapshot.',
            route: AppRoutes.STAFF_HOME,
            arguments: {'tabIndex': 0},
          ),
        ];
      case 'transport':
        return const [
          StaffPortalScreen(
            title: 'Reports',
            description: 'Inspect transport-linked operational reporting.',
            route: AppRoutes.STAFF_HOME,
            arguments: {'tabIndex': 3},
          ),
          StaffPortalScreen(
            title: 'Communication Center',
            description: 'Share route and coordination updates.',
            route: AppRoutes.STAFF_HOME,
            arguments: {'tabIndex': 2},
          ),
        ];
      case 'hostel':
        return const [
          StaffPortalScreen(
            title: 'Reports',
            description: 'Review hostel-linked operational summaries.',
            route: AppRoutes.STAFF_HOME,
            arguments: {'tabIndex': 3},
          ),
          StaffPortalScreen(
            title: 'Communication Center',
            description: 'Coordinate meetings and hostel notices.',
            route: AppRoutes.STAFF_HOME,
            arguments: {'tabIndex': 2},
          ),
        ];
      case 'inventory_lab':
        return const [
          StaffPortalScreen(
            title: 'Reports',
            description: 'Monitor inventory-linked reporting and trends.',
            route: AppRoutes.STAFF_HOME,
            arguments: {'tabIndex': 3},
          ),
          StaffPortalScreen(
            title: 'Staff Dashboard',
            description: 'Use the live dashboard for workload context.',
            route: AppRoutes.STAFF_HOME,
            arguments: {'tabIndex': 0},
          ),
        ];
      case 'payroll_hr':
        return const [
          StaffPortalScreen(
            title: 'Staff Profile',
            description: 'Review live staff identity and role details.',
            route: AppRoutes.STAFF_HOME,
            arguments: {'tabIndex': 1},
          ),
          StaffPortalScreen(
            title: 'Settings',
            description: 'Check account preferences and session controls.',
            route: AppRoutes.STAFF_HOME,
            arguments: {'tabIndex': 4},
          ),
        ];
      case 'reports':
        return const [
          StaffPortalScreen(
            title: 'Reports',
            description: 'Live staff analytics and reporting tiles.',
            route: AppRoutes.STAFF_HOME,
            arguments: {'tabIndex': 3},
          ),
          StaffPortalScreen(
            title: 'Staff Dashboard',
            description: 'Pair analytics with current workload context.',
            route: AppRoutes.STAFF_HOME,
            arguments: {'tabIndex': 0},
          ),
        ];
      case 'ai_teaching_assistant':
        return const [
          StaffPortalScreen(
            title: 'AI Teaching Assistant',
            description: 'Open the live assistant backed by the server.',
            opensAssistant: true,
          ),
          StaffPortalScreen(
            title: 'Staff Dashboard',
            description: 'Return to the main dashboard after AI actions.',
            route: AppRoutes.STAFF_HOME,
            arguments: {'tabIndex': 0},
          ),
        ];
      case 'settings':
        return const [
          StaffPortalScreen(
            title: 'Settings',
            description:
                'Manage live notification, privacy, and layout settings.',
            route: AppRoutes.STAFF_HOME,
            arguments: {'tabIndex': 4},
          ),
          StaffPortalScreen(
            title: 'Staff Profile',
            description: 'Open account and identity details.',
            route: AppRoutes.STAFF_HOME,
            arguments: {'tabIndex': 1},
          ),
        ];
      default:
        return const [
          StaffPortalScreen(
            title: 'Staff Dashboard',
            description:
                'Use the live dashboard for current operational context.',
            route: AppRoutes.STAFF_HOME,
            arguments: {'tabIndex': 0},
          ),
          StaffPortalScreen(
            title: 'Reports',
            description: 'Use reporting to inspect active ERP data.',
            route: AppRoutes.STAFF_HOME,
            arguments: {'tabIndex': 3},
          ),
        ];
    }
  }

  static void openScreen(
    StaffPortalScreen screen, {
    bool replaceCurrent = true,
  }) {
    if (screen.opensAssistant) {
      StaffAiAssistantSheet.open();
      return;
    }
    if (screen.route != null) {
      if (screen.route == AppRoutes.STAFF_HOME &&
          Get.isRegistered<StaffShellController>()) {
        final args = screen.arguments;
        final index = StaffShellController.resolveIndex(arguments: args);
        if (Get.currentRoute == AppRoutes.STAFF_HOME) {
          Get.find<StaffShellController>().setTab(index);
          return;
        }
      }
      if (replaceCurrent) {
        SafeNavigation.offNamed(screen.route!, arguments: screen.arguments);
      } else {
        SafeNavigation.toNamed(screen.route!, arguments: screen.arguments);
      }
    }
  }

  static void openModule(
    String moduleId, {
    String? feature,
    bool replaceCurrent = true,
  }) {
    final screens = screensForModule(moduleId);
    if (screens.isNotEmpty) {
      openScreen(screens.first, replaceCurrent: replaceCurrent);
      return;
    }
    final arguments = {
      'moduleId': moduleId,
      'module': moduleId.replaceAll('_', ' ').toUpperCase(),
      'feature': feature ?? 'Feature',
    };
    if (replaceCurrent) {
      SafeNavigation.offNamed(
        AppRoutes.STAFF_FEATURE_DETAIL,
        arguments: arguments,
      );
    } else {
      SafeNavigation.toNamed(
        AppRoutes.STAFF_FEATURE_DETAIL,
        arguments: arguments,
      );
    }
  }
}
