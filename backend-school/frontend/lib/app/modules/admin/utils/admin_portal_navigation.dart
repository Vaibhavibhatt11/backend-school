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
            title: 'Admissions Center',
            description:
                'Create, review, document, and onboard real admission applications.',
            route: AppRoutes.ADMIN_ADMISSIONS,
          ),
          AdminPortalScreen(
            title: 'Approvals Queue',
            description:
                'Review pending approvals linked to admissions activity.',
            route: AppRoutes.ADMIN_APPROVALS,
            arguments: {'tabIndex': 1},
          ),
          AdminPortalScreen(
            title: 'Notice Board',
            description: 'Share admission updates and onboarding notices.',
            route: AppRoutes.ADMIN_NOTICE_BOARD,
            arguments: {'tabIndex': 3},
          ),
        ];
      case 'students':
        return const [
          AdminPortalScreen(
            title: 'Student Management',
            description:
                'Create, update, move, deactivate, and document real student records.',
            route: AppRoutes.ADMIN_STUDENTS,
          ),
          AdminPortalScreen(
            title: 'Parent Directory',
            description: 'Manage linked parents and guardian invitations.',
            route: AppRoutes.ADMIN_PEOPLE,
            arguments: {'initialTab': 0},
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
            title: 'Staff Management',
            description:
                'Premium management of teachers, support staff, and administrative personnel.',
            route: AppRoutes.ADMIN_STAFF,
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
            title: 'Academic Setup',
            description: 'Manage live classes and subjects from one place.',
            route: AppRoutes.ADMIN_ACADEMICS,
            arguments: {'initialTab': 0},
          ),
          AdminPortalScreen(
            title: 'Subject Catalog',
            description: 'Create and update subject masters with real data.',
            route: AppRoutes.ADMIN_ACADEMICS,
            arguments: {'initialTab': 1},
          ),
          AdminPortalScreen(
            title: 'Reports',
            description: 'View live academic and class performance summaries.',
            route: AppRoutes.ADMIN_REPORTS,
            arguments: {'tabIndex': 2},
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
            title: 'Exam Control',
            description: 'Create exams, publish them, and enter marks.',
            route: AppRoutes.ADMIN_SCHEDULE,
            arguments: {'initialTab': 1},
          ),
          AdminPortalScreen(
            title: 'Exam Reports',
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
        ];
      case 'timetable':
        return const [
          AdminPortalScreen(
            title: 'Schedule Manager',
            description: 'Manage timetable slots and live class sessions.',
            route: AppRoutes.ADMIN_SCHEDULE,
            arguments: {'initialTab': 0},
          ),
          AdminPortalScreen(
            title: 'Reports',
            description: 'See live class coverage and operational trends.',
            route: AppRoutes.ADMIN_REPORTS,
            arguments: {'tabIndex': 2},
          ),
        ];
      case 'library':
        return const [
          AdminPortalScreen(
            title: 'Librarian Portal',
            description:
                'Dedicated library operations flow for catalog, issue/return, and membership.',
            route: AppRoutes.LIBRARIAN_HOME,
          ),
          AdminPortalScreen(
            title: 'Admin Library Desk',
            description: 'Open admin resources view for library controls.',
            route: AppRoutes.ADMIN_RESOURCES,
            arguments: {'initialTab': 0, 'scope': 'library'},
          ),
        ];
      case 'operations':
        return const [
          AdminPortalScreen(
            title: 'Operations Hub',
            description: 'Manage Hostel, Transport, Events, and Inventory in one place.',
            route: AppRoutes.ADMIN_OPERATIONS,
          ),
        ];
      case 'study_material':
        return const [
          AdminPortalScreen(
            title: 'Study Material Hub',
            description: 'Centralized access to school library and resource composer.',
            route: AppRoutes.ADMIN_STUDY_MATERIAL,
          ),
          AdminPortalScreen(
            title: 'Content Library',
            description: 'Browse and manage existing study materials.',
            route: AppRoutes.ADMIN_STUDY_MATERIAL_LIBRARY,
          ),
          AdminPortalScreen(
            title: 'Compose Material',
            description: 'Upload new notes, videos, and PDFs.',
            route: AppRoutes.ADMIN_STUDY_MATERIAL_COMPOSER,
          ),
        ];
      case 'transport':
        return const [
          AdminPortalScreen(
            title: 'Transport Desk',
            description: 'Manage routes, drivers, and student allocations.',
            route: AppRoutes.ADMIN_OPERATIONS,
            arguments: {'initialTab': 2},
          ),
        ];
      case 'hostel':
        return const [
          AdminPortalScreen(
            title: 'Hostel Warden Portal',
            description:
                'Dedicated hostel operations flow for rooming, attendance, visitors, and complaints.',
            route: AppRoutes.HOSTEL_WARDEN_HOME,
          ),
          AdminPortalScreen(
            title: 'Admin Hostel Desk',
            description: 'Open admin operations hostel workspace.',
            route: AppRoutes.ADMIN_OPERATIONS,
            arguments: {'initialTab': 0, 'scope': 'hostel'},
          ),
        ];
      case 'inventory':
        return const [
          AdminPortalScreen(
            title: 'Inventory Desk',
            description: 'Manage stock items and transaction movements.',
            route: AppRoutes.ADMIN_RESOURCES,
            arguments: {'initialTab': 1, 'scope': 'inventory'},
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
            title: 'Events Hub',
            description:
                'Manage school events, competitions, and registrations.',
            route: AppRoutes.ADMIN_EVENTS_HUB,
          ),
          AdminPortalScreen(
            title: 'Reports',
            description: 'Analytics for event participation and statistics.',
            route: AppRoutes.ADMIN_EVENTS_REPORTS,
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
            description: 'Manage admin-side system configuration.',
            route: AppRoutes.ADMIN_SETTINGS,
            arguments: {'tabIndex': 4},
          ),
        ];
      case 'settings':
        return const [
          AdminPortalScreen(
            title: 'Settings',
            description: 'Manage school configuration and controls.',
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
    SafeNavigation.toNamed(screen.route, arguments: screen.arguments);
  }

  static void openFromCatalog({
    required String moduleId,
    required String feature,
  }) {
    final m = moduleId.toLowerCase().trim();
    final f = feature.toLowerCase();

    bool has(String s) => m.contains(s) || f.contains(s);

    if (m == 'fees' || has('fee') && !has('feedback')) {
      SafeNavigation.toNamed(AppRoutes.ADMIN_FEE_SNAPSHOT);
      return;
    }
    if (m == 'attendance' || has('attendance') || has('leave')) {
      SafeNavigation.toNamed(AppRoutes.ADMIN_ATTENDANCE);
      return;
    }
    if (m == 'admissions' ||
        has('admission') ||
        has('approv') ||
        has('waiting')) {
      SafeNavigation.toNamed(AppRoutes.ADMIN_ADMISSIONS);
      return;
    }
    if (has('parent') || has('guardian')) {
      SafeNavigation.toNamed(
        AppRoutes.ADMIN_PEOPLE,
        arguments: {'initialTab': 0},
      );
      return;
    }
    if (m == 'students' || has('student') || has('enroll')) {
      SafeNavigation.toNamed(AppRoutes.ADMIN_STUDENTS);
      return;
    }
    if (m == 'staff' || has('staff') || has('teacher') || has('employee')) {
      SafeNavigation.toNamed(AppRoutes.ADMIN_STAFF);
      return;
    }
    if (m == 'academics' ||
        has('class') ||
        has('subject') ||
        has('curriculum') ||
        has('syllabus')) {
      SafeNavigation.toNamed(
        AppRoutes.ADMIN_ACADEMICS,
        arguments: {'initialTab': has('subject') ? 1 : 0},
      );
      return;
    }
    if (m == 'timetable' || has('timetable') || has('schedule')) {
      SafeNavigation.toNamed(
        AppRoutes.ADMIN_SCHEDULE,
        arguments: {'initialTab': 0},
      );
      return;
    }
    if (m == 'exams' || has('exam') || has('marks') || has('result')) {
      SafeNavigation.toNamed(
        AppRoutes.ADMIN_SCHEDULE,
        arguments: {'initialTab': 1},
      );
      return;
    }
    if (m == 'library' || has('library') || has('book')) {
      SafeNavigation.toNamed(
        AppRoutes.ADMIN_RESOURCES,
        arguments: {'initialTab': 0, 'scope': 'library'},
      );
      return;
    }
    if (m == 'inventory' || has('inventory') || has('asset') || has('stock')) {
      SafeNavigation.toNamed(
        AppRoutes.ADMIN_RESOURCES,
        arguments: {'initialTab': 1, 'scope': 'inventory'},
      );
      return;
    }
    if (m == 'transport' || has('transport') || has('route') || has('bus')) {
      SafeNavigation.toNamed(
        AppRoutes.ADMIN_OPERATIONS,
        arguments: {'initialTab': 2},
      );
      return;
    }
    if (m == 'operations') {
      SafeNavigation.toNamed(AppRoutes.ADMIN_OPERATIONS);
      return;
    }
    if (m == 'study_material' || (has('study') && has('material'))) {
      SafeNavigation.toNamed(AppRoutes.ADMIN_STUDY_MATERIAL);
      return;
    }
    if (m == 'hostel' || has('hostel') || has('room') || has('visitor')) {
      SafeNavigation.toNamed(
        AppRoutes.ADMIN_OPERATIONS,
        arguments: {'initialTab': 0},
      );
      return;
    }
    if (m == 'events' ||
        has('event') ||
        has('activity') ||
        has('gallery') ||
        has('competition')) {
      SafeNavigation.toNamed(AppRoutes.ADMIN_EVENTS_HUB);
      return;
    }
    if (m == 'communication' ||
        has('announce') ||
        has('broadcast') ||
        has('notif') ||
        has('sms') ||
        has('whatsapp')) {
      SafeNavigation.toNamed(
        AppRoutes.ADMIN_NOTICE_BOARD,
        arguments: {'tabIndex': 3},
      );
      return;
    }
    if (m == 'reports' || has('report') || has('analytic')) {
      SafeNavigation.toNamed(
        AppRoutes.ADMIN_REPORTS,
        arguments: {'tabIndex': 2},
      );
      return;
    }
    if (m == 'security' || has('audit') || has('permission')) {
      SafeNavigation.toNamed(AppRoutes.ADMIN_AUDIT_LOGS);
      return;
    }
    if (m == 'settings' || has('setting') || has('privacy')) {
      SafeNavigation.toNamed(
        AppRoutes.ADMIN_SETTINGS,
        arguments: {'tabIndex': 4},
      );
      return;
    }
    if (m == 'dashboard') {
      SafeNavigation.toNamed(AppRoutes.ADMIN_HOME, arguments: {'tabIndex': 0});
      return;
    }
    final screens = screensForModule(moduleId);
    if (screens.isNotEmpty) {
      openScreen(screens.first);
      return;
    }

    SafeNavigation.toNamed(
      AppRoutes.ADMIN_FEATURE_DETAIL,
      arguments: {'moduleId': moduleId, 'feature': feature},
    );
  }
}
