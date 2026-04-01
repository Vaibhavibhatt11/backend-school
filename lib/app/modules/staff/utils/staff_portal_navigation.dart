import 'package:erp_frontend/app/modules/staff/widgets/staff_ai_assistant_sheet.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/utils/safe_navigation.dart';

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
            title: 'Attendance Selector',
            description: 'Open the attendance workflow used by staff.',
            route: AppRoutes.TEACHER_ATTENDANCE_SELECTOR,
          ),
          StaffPortalScreen(
            title: 'Staff Dashboard',
            description: 'Cross-check workload and schedule impact.',
            route: AppRoutes.STAFF_HOME,
            arguments: {'tabIndex': 0},
          ),
        ];
      case 'class_teaching':
        return const [
          StaffPortalScreen(
            title: 'Student Directory',
            description: 'Access class and student-linked teaching workflows.',
            route: AppRoutes.TEACHER_STUDENT_DIRECTORY,
          ),
          StaffPortalScreen(
            title: 'Staff Dashboard',
            description: 'Review today\'s class coverage and assignments.',
            route: AppRoutes.STAFF_HOME,
            arguments: {'tabIndex': 0},
          ),
        ];
      case 'lesson_planning':
        return const [
          StaffPortalScreen(
            title: 'Upload Center',
            description:
                'Use the teaching upload flow for plans and materials.',
            route: AppRoutes.TEACHER_UPLOAD,
          ),
          StaffPortalScreen(
            title: 'Reports',
            description: 'Track the latest teaching-related reporting.',
            route: AppRoutes.STAFF_HOME,
            arguments: {'tabIndex': 3},
          ),
        ];
      case 'homework_assignment':
        return const [
          StaffPortalScreen(
            title: 'Upload Center',
            description: 'Manage assignment and homework resources.',
            route: AppRoutes.TEACHER_UPLOAD,
          ),
          StaffPortalScreen(
            title: 'Student Directory',
            description: 'Open students connected to assignment workflows.',
            route: AppRoutes.TEACHER_STUDENT_DIRECTORY,
          ),
        ];
      case 'exam_assessment':
        return const [
          StaffPortalScreen(
            title: 'Upload Center',
            description: 'Use the current exam-content workflow.',
            route: AppRoutes.TEACHER_UPLOAD,
          ),
          StaffPortalScreen(
            title: 'Reports',
            description: 'Review reporting tied to academic outcomes.',
            route: AppRoutes.STAFF_HOME,
            arguments: {'tabIndex': 3},
          ),
        ];
      case 'performance':
        return const [
          StaffPortalScreen(
            title: 'Student Directory',
            description: 'Open student-level monitoring and records.',
            route: AppRoutes.TEACHER_STUDENT_DIRECTORY,
          ),
          StaffPortalScreen(
            title: 'Reports',
            description: 'View academic and attendance analytics.',
            route: AppRoutes.STAFF_HOME,
            arguments: {'tabIndex': 3},
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
            title: 'Staff Dashboard',
            description: 'See alerts and notification context.',
            route: AppRoutes.STAFF_HOME,
            arguments: {'tabIndex': 0},
          ),
        ];
      case 'study_material':
        return const [
          StaffPortalScreen(
            title: 'Upload Center',
            description: 'Use the current study material publishing flow.',
            route: AppRoutes.TEACHER_UPLOAD,
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

  static void openScreen(StaffPortalScreen screen) {
    if (screen.opensAssistant) {
      StaffAiAssistantSheet.open();
      return;
    }
    if (screen.route != null) {
      SafeNavigation.offNamed(screen.route!, arguments: screen.arguments);
    }
  }

  static void openModule(String moduleId, {String? feature}) {
    final screens = screensForModule(moduleId);
    if (screens.isNotEmpty) {
      openScreen(screens.first);
      return;
    }
    SafeNavigation.offNamed(
      AppRoutes.STAFF_FEATURE_DETAIL,
      arguments: {
        'moduleId': moduleId,
        'module': moduleId.replaceAll('_', ' ').toUpperCase(),
        'feature': feature ?? 'Feature',
      },
    );
  }
}
