import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/utils/safe_navigation.dart';

class AdminPortalScreen {
  const AdminPortalScreen({
    required this.title,
    required this.description,
    required this.route,
    this.arguments,
  });

  final String title;
  final String description;
  final String route;
  final dynamic arguments;
}

class AdminPortalNavigation {
  AdminPortalNavigation._();

  static List<AdminPortalScreen> screensForModule(String moduleId) {
    switch (moduleId) {
      case 'dashboard':
        return const [
          AdminPortalScreen(
            title: 'Executive Dashboard',
            description: 'Live school KPIs, alerts, and action shortcuts.',
            route: AppRoutes.ADMIN_HOME,
            arguments: {'tabIndex': 0},
          ),
          AdminPortalScreen(
            title: 'Attendance Overview',
            description: 'Current student and staff attendance performance.',
            route: AppRoutes.ADMIN_ATTENDANCE,
          ),
          AdminPortalScreen(
            title: 'Fee Snapshot',
            description: 'Collections, pending dues, and fee movement.',
            route: AppRoutes.ADMIN_FEE_SNAPSHOT,
          ),
        ];
      case 'admissions':
        return const [
          AdminPortalScreen(
            title: 'Approvals Queue',
            description: 'Review pending admissions and related requests.',
            route: AppRoutes.ADMIN_APPROVALS,
            arguments: {'tabIndex': 1},
          ),
          AdminPortalScreen(
            title: 'Notice Board',
            description: 'Share admission updates and onboarding notices.',
            route: AppRoutes.ADMIN_NOTICE_BOARD,
            arguments: {'tabIndex': 3},
          ),
          AdminPortalScreen(
            title: 'Reports',
            description: 'Track admission-related operational trends.',
            route: AppRoutes.ADMIN_REPORTS,
            arguments: {'tabIndex': 2},
          ),
        ];
      case 'students':
        return const [
          AdminPortalScreen(
            title: 'Executive Dashboard',
            description: 'Student totals and school-wide snapshot.',
            route: AppRoutes.ADMIN_HOME,
            arguments: {'tabIndex': 0},
          ),
          AdminPortalScreen(
            title: 'Attendance Overview',
            description: 'Monitor student attendance patterns.',
            route: AppRoutes.ADMIN_ATTENDANCE,
          ),
          AdminPortalScreen(
            title: 'Reports',
            description: 'View student-related reporting and class trends.',
            route: AppRoutes.ADMIN_REPORTS,
            arguments: {'tabIndex': 2},
          ),
        ];
      case 'staff':
        return const [
          AdminPortalScreen(
            title: 'Executive Dashboard',
            description: 'Track teacher presence and staffing KPIs.',
            route: AppRoutes.ADMIN_HOME,
            arguments: {'tabIndex': 0},
          ),
          AdminPortalScreen(
            title: 'Attendance Overview',
            description: 'See staff attendance and presence ratios.',
            route: AppRoutes.ADMIN_ATTENDANCE,
          ),
          AdminPortalScreen(
            title: 'Audit Logs',
            description: 'Review recent admin and staff actions.',
            route: AppRoutes.ADMIN_AUDIT_LOGS,
          ),
        ];
      case 'academics':
        return const [
          AdminPortalScreen(
            title: 'Reports',
            description: 'View live academic and class performance summaries.',
            route: AppRoutes.ADMIN_REPORTS,
            arguments: {'tabIndex': 2},
          ),
          AdminPortalScreen(
            title: 'Executive Dashboard',
            description: 'Stay on top of school-wide academic operations.',
            route: AppRoutes.ADMIN_HOME,
            arguments: {'tabIndex': 0},
          ),
          AdminPortalScreen(
            title: 'Notice Board',
            description: 'Publish class and academic announcements.',
            route: AppRoutes.ADMIN_NOTICE_BOARD,
            arguments: {'tabIndex': 3},
          ),
        ];
      case 'attendance':
        return const [
          AdminPortalScreen(
            title: 'Attendance Overview',
            description: 'Live student and staff attendance metrics.',
            route: AppRoutes.ADMIN_ATTENDANCE,
          ),
          AdminPortalScreen(
            title: 'Reports',
            description: 'Analyze attendance movement across time ranges.',
            route: AppRoutes.ADMIN_REPORTS,
            arguments: {'tabIndex': 2},
          ),
          AdminPortalScreen(
            title: 'Audit Logs',
            description: 'Inspect recent operational attendance activity.',
            route: AppRoutes.ADMIN_AUDIT_LOGS,
          ),
        ];
      case 'fees':
        return const [
          AdminPortalScreen(
            title: 'Fee Snapshot',
            description: 'Live fee collections, pending dues, and breakdowns.',
            route: AppRoutes.ADMIN_FEE_SNAPSHOT,
          ),
          AdminPortalScreen(
            title: 'Reports',
            description: 'Analyze outstanding balances and collections.',
            route: AppRoutes.ADMIN_REPORTS,
            arguments: {'tabIndex': 2},
          ),
          AdminPortalScreen(
            title: 'Notice Board',
            description: 'Publish reminders and payment communication.',
            route: AppRoutes.ADMIN_NOTICE_BOARD,
            arguments: {'tabIndex': 3},
          ),
        ];
      case 'exams':
        return const [
          AdminPortalScreen(
            title: 'Reports',
            description: 'Track academic reporting and performance outcomes.',
            route: AppRoutes.ADMIN_REPORTS,
            arguments: {'tabIndex': 2},
          ),
          AdminPortalScreen(
            title: 'Notice Board',
            description: 'Share exam schedules and result notifications.',
            route: AppRoutes.ADMIN_NOTICE_BOARD,
            arguments: {'tabIndex': 3},
          ),
          AdminPortalScreen(
            title: 'Executive Dashboard',
            description: 'Keep exam operations visible in the main dashboard.',
            route: AppRoutes.ADMIN_HOME,
            arguments: {'tabIndex': 0},
          ),
        ];
      case 'timetable':
        return const [
          AdminPortalScreen(
            title: 'Reports',
            description: 'See live class coverage and operational trends.',
            route: AppRoutes.ADMIN_REPORTS,
            arguments: {'tabIndex': 2},
          ),
          AdminPortalScreen(
            title: 'Attendance Overview',
            description: 'Monitor attendance impact on timetable coverage.',
            route: AppRoutes.ADMIN_ATTENDANCE,
          ),
          AdminPortalScreen(
            title: 'Executive Dashboard',
            description: 'View the latest school-wide scheduling context.',
            route: AppRoutes.ADMIN_HOME,
            arguments: {'tabIndex': 0},
          ),
        ];
      case 'library':
        return const [
          AdminPortalScreen(
            title: 'Reports',
            description:
                'Use live reporting to monitor library-linked activity.',
            route: AppRoutes.ADMIN_REPORTS,
            arguments: {'tabIndex': 2},
          ),
          AdminPortalScreen(
            title: 'Notice Board',
            description: 'Share library and circulation announcements.',
            route: AppRoutes.ADMIN_NOTICE_BOARD,
            arguments: {'tabIndex': 3},
          ),
        ];
      case 'transport':
        return const [
          AdminPortalScreen(
            title: 'Reports',
            description:
                'Monitor route-related operations and school coverage.',
            route: AppRoutes.ADMIN_REPORTS,
            arguments: {'tabIndex': 2},
          ),
          AdminPortalScreen(
            title: 'Attendance Overview',
            description: 'Compare transport-linked attendance movement.',
            route: AppRoutes.ADMIN_ATTENDANCE,
          ),
        ];
      case 'hostel':
        return const [
          AdminPortalScreen(
            title: 'Reports',
            description: 'Review hostel-linked operational summaries.',
            route: AppRoutes.ADMIN_REPORTS,
            arguments: {'tabIndex': 2},
          ),
          AdminPortalScreen(
            title: 'Notice Board',
            description: 'Post hostel updates and visitor notices.',
            route: AppRoutes.ADMIN_NOTICE_BOARD,
            arguments: {'tabIndex': 3},
          ),
        ];
      case 'inventory':
        return const [
          AdminPortalScreen(
            title: 'Reports',
            description:
                'Track live operational reporting for assets and stock.',
            route: AppRoutes.ADMIN_REPORTS,
            arguments: {'tabIndex': 2},
          ),
          AdminPortalScreen(
            title: 'Audit Logs',
            description: 'Review recent system changes affecting operations.',
            route: AppRoutes.ADMIN_AUDIT_LOGS,
          ),
        ];
      case 'communication':
        return const [
          AdminPortalScreen(
            title: 'Notice Board',
            description: 'Create, manage, and send live notices.',
            route: AppRoutes.ADMIN_NOTICE_BOARD,
            arguments: {'tabIndex': 3},
          ),
          AdminPortalScreen(
            title: 'Audit Logs',
            description: 'Track recent communication activity.',
            route: AppRoutes.ADMIN_AUDIT_LOGS,
          ),
        ];
      case 'events':
        return const [
          AdminPortalScreen(
            title: 'Notice Board',
            description: 'Publish event updates and activity announcements.',
            route: AppRoutes.ADMIN_NOTICE_BOARD,
            arguments: {'tabIndex': 3},
          ),
          AdminPortalScreen(
            title: 'Reports',
            description: 'Monitor operational event reporting.',
            route: AppRoutes.ADMIN_REPORTS,
            arguments: {'tabIndex': 2},
          ),
        ];
      case 'reports':
        return const [
          AdminPortalScreen(
            title: 'Reports',
            description: 'Centralized attendance, fee, and school analytics.',
            route: AppRoutes.ADMIN_REPORTS,
            arguments: {'tabIndex': 2},
          ),
          AdminPortalScreen(
            title: 'Executive Dashboard',
            description: 'Pair analytics with the main school snapshot.',
            route: AppRoutes.ADMIN_HOME,
            arguments: {'tabIndex': 0},
          ),
        ];
      case 'security':
        return const [
          AdminPortalScreen(
            title: 'Audit Logs',
            description: 'Review recent security and access activity.',
            route: AppRoutes.ADMIN_AUDIT_LOGS,
          ),
          AdminPortalScreen(
            title: 'Settings',
            description: 'Manage admin-side system preferences.',
            route: AppRoutes.ADMIN_SETTINGS,
            arguments: {'tabIndex': 4},
          ),
        ];
      case 'settings':
        return const [
          AdminPortalScreen(
            title: 'Settings',
            description: 'Manage school configuration and preferences.',
            route: AppRoutes.ADMIN_SETTINGS,
            arguments: {'tabIndex': 4},
          ),
          AdminPortalScreen(
            title: 'Admin Profile',
            description: 'View live school admin profile details.',
            route: AppRoutes.ADMIN_PROFILE,
          ),
        ];
      default:
        return const [
          AdminPortalScreen(
            title: 'Executive Dashboard',
            description:
                'Use the main admin dashboard for live school context.',
            route: AppRoutes.ADMIN_HOME,
            arguments: {'tabIndex': 0},
          ),
          AdminPortalScreen(
            title: 'Reports',
            description: 'Use reporting to inspect current ERP activity.',
            route: AppRoutes.ADMIN_REPORTS,
            arguments: {'tabIndex': 2},
          ),
        ];
    }
  }

  static void openScreen(AdminPortalScreen screen) {
    SafeNavigation.offNamed(screen.route, arguments: screen.arguments);
  }

  static void openFromCatalog({
    required String moduleId,
    required String feature,
  }) {
    final m = moduleId.toLowerCase().trim();
    final f = feature.toLowerCase();

    bool has(String s) => m.contains(s) || f.contains(s);

    if (m == 'fees' || has('fee') && !has('feedback')) {
      SafeNavigation.offNamed(AppRoutes.ADMIN_FEE_SNAPSHOT);
      return;
    }
    if (m == 'attendance' || has('attendance') || has('leave')) {
      SafeNavigation.offNamed(AppRoutes.ADMIN_ATTENDANCE);
      return;
    }
    if (m == 'admissions' ||
        has('admission') ||
        has('approv') ||
        has('waiting')) {
      SafeNavigation.offNamed(
        AppRoutes.ADMIN_APPROVALS,
        arguments: {'tabIndex': 1},
      );
      return;
    }
    if (m == 'communication' ||
        m == 'events' ||
        has('announce') ||
        has('broadcast') ||
        has('notif') ||
        has('sms') ||
        has('whatsapp')) {
      SafeNavigation.offNamed(
        AppRoutes.ADMIN_NOTICE_BOARD,
        arguments: {'tabIndex': 3},
      );
      return;
    }
    if (m == 'reports' || has('report') || has('analytic')) {
      SafeNavigation.offNamed(
        AppRoutes.ADMIN_REPORTS,
        arguments: {'tabIndex': 2},
      );
      return;
    }
    if (m == 'security' || has('audit') || has('permission')) {
      SafeNavigation.offNamed(AppRoutes.ADMIN_AUDIT_LOGS);
      return;
    }
    if (m == 'settings' || has('setting') || has('privacy')) {
      SafeNavigation.offNamed(
        AppRoutes.ADMIN_SETTINGS,
        arguments: {'tabIndex': 4},
      );
      return;
    }
    if (m == 'dashboard') {
      SafeNavigation.offNamed(AppRoutes.ADMIN_HOME, arguments: {'tabIndex': 0});
      return;
    }
    if (m == 'students' ||
        m == 'staff' ||
        m == 'academics' ||
        m == 'exams' ||
        m == 'timetable' ||
        m == 'library' ||
        m == 'transport' ||
        m == 'hostel' ||
        m == 'inventory' ||
        m == 'payroll') {
      SafeNavigation.offNamed(
        AppRoutes.ADMIN_REPORTS,
        arguments: {'tabIndex': 2},
      );
      return;
    }

    final screens = screensForModule(moduleId);
    if (screens.isNotEmpty) {
      openScreen(screens.first);
      return;
    }

    SafeNavigation.offNamed(
      AppRoutes.ADMIN_FEATURE_DETAIL,
      arguments: {'moduleId': moduleId, 'feature': feature},
    );
  }
}
