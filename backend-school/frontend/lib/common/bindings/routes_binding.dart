import 'package:get/get.dart';

import '../../views/onboarding-screens/splash_screen.dart';
import '../routes/common_routes_screens.dart';
import '../../modules/auth/login/login_binding.dart';
import '../../modules/auth/login/login_screen.dart';
import '../../modules/auth/forgot_password/forgot_password_binding.dart';
import '../../modules/auth/forgot_password/forgot_password_screen.dart';

// Main shell (bottom nav)
import '../../modules/main_shell/main_shell_binding.dart';
import '../../modules/main_shell/main_shell_screen.dart';

// Student
import '../../modules/student/dashboard/student_dashboard_binding.dart';
import '../../modules/student/dashboard/student_dashboard_screen.dart';
import '../../modules/student/profile/student_profile_binding.dart';
import '../../modules/student/profile/student_profile_screen.dart';
import '../../modules/student/profile/sub_screens/profile_sub_screen.dart';
import '../../modules/student/timetable/student_timetable_binding.dart';
import '../../modules/student/timetable/student_timetable_screen.dart';
import '../../modules/student/attendance/student_attendance_binding.dart';
import '../../modules/student/attendance/student_attendance_screen.dart';
import '../../modules/student/homework/student_homework_binding.dart';
import '../../modules/student/homework/student_homework_screen.dart';
import '../../modules/student/study_materials/student_study_materials_binding.dart';
import '../../modules/student/study_materials/student_study_materials_screen.dart';
import '../../modules/student/exams/student_exams_binding.dart';
import '../../modules/student/exams/student_exams_screen.dart';
import '../../modules/student/fees/student_fees_binding.dart';
import '../../modules/student/fees/student_fees_screen.dart';
import '../../modules/student/communication/student_communication_binding.dart';
import '../../modules/student/communication/student_communication_screen.dart';
import '../../modules/student/events/student_events_binding.dart';
import '../../modules/student/events/student_events_screen.dart';
import '../../modules/student/health/student_health_binding.dart';
import '../../modules/student/health/student_health_screen.dart';
import '../../modules/student/transport/student_transport_binding.dart';
import '../../modules/student/transport/student_transport_screen.dart';
import '../../modules/student/library/student_library_binding.dart';
import '../../modules/student/library/student_library_screen.dart';
import '../../modules/student/achievements/student_achievements_binding.dart';
import '../../modules/student/achievements/student_achievements_screen.dart';
import '../../modules/student/settings/student_settings_binding.dart';
import '../../modules/student/settings/student_settings_screen.dart';

class RoutesBinding {
  static final RoutesBinding _instance = RoutesBinding._internal();

  factory RoutesBinding() => _instance;

  RoutesBinding._internal();

  static final routes = [
    GetPage(
      name: CommonScreenRoutes.splashScreen,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: CommonScreenRoutes.loginScreen,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: CommonScreenRoutes.forgotPasswordScreen,
      page: () => const ForgotPasswordScreen(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: CommonScreenRoutes.mainShell,
      page: () => const MainShellScreen(),
      binding: MainShellBinding(),
    ),
    GetPage(
      name: CommonScreenRoutes.studentDashboard,
      page: () => const StudentDashboardScreen(),
      binding: StudentDashboardBinding(),
    ),
    GetPage(
      name: CommonScreenRoutes.studentProfile,
      page: () => const StudentProfileScreen(),
      binding: StudentProfileBinding(),
    ),
    GetPage(
      name: CommonScreenRoutes.studentTimetable,
      page: () => const StudentTimetableScreen(),
      binding: StudentTimetableBinding(),
    ),
    GetPage(
      name: CommonScreenRoutes.studentAttendance,
      page: () => const StudentAttendanceScreen(),
      binding: StudentAttendanceBinding(),
    ),
    GetPage(
      name: CommonScreenRoutes.studentHomework,
      page: () => const StudentHomeworkScreen(),
      binding: StudentHomeworkBinding(),
    ),
    GetPage(
      name: CommonScreenRoutes.studentStudyMaterials,
      page: () => const StudentStudyMaterialsScreen(),
      binding: StudentStudyMaterialsBinding(),
    ),
    GetPage(
      name: CommonScreenRoutes.studentExams,
      page: () => const StudentExamsScreen(),
      binding: StudentExamsBinding(),
    ),
    GetPage(
      name: CommonScreenRoutes.studentFees,
      page: () => const StudentFeesScreen(),
      binding: StudentFeesBinding(),
    ),
    GetPage(
      name: CommonScreenRoutes.studentCommunication,
      page: () => const StudentCommunicationScreen(),
      binding: StudentCommunicationBinding(),
    ),
    GetPage(
      name: CommonScreenRoutes.studentEvents,
      page: () => const StudentEventsScreen(),
      binding: StudentEventsBinding(),
    ),
    GetPage(
      name: CommonScreenRoutes.studentHealth,
      page: () => const StudentHealthScreen(),
      binding: StudentHealthBinding(),
    ),
    GetPage(
      name: CommonScreenRoutes.studentTransport,
      page: () => const StudentTransportScreen(),
      binding: StudentTransportBinding(),
    ),
    GetPage(
      name: CommonScreenRoutes.studentLibrary,
      page: () => const StudentLibraryScreen(),
      binding: StudentLibraryBinding(),
    ),
    GetPage(
      name: CommonScreenRoutes.studentAchievements,
      page: () => const StudentAchievementsScreen(),
      binding: StudentAchievementsBinding(),
    ),
    GetPage(
      name: CommonScreenRoutes.studentSettings,
      page: () => const StudentSettingsScreen(),
      binding: StudentSettingsBinding(),
    ),
    // Profile sub-screens
    GetPage(
      name: CommonScreenRoutes.profilePersonalDetails,
      page: () => ProfileSubScreen(title: 'Personal details'),
    ),
    GetPage(
      name: CommonScreenRoutes.profileParentDetails,
      page: () => ProfileSubScreen(title: 'Parent details'),
    ),
    GetPage(
      name: CommonScreenRoutes.profileClassSection,
      page: () => ProfileSubScreen(title: 'Class & section'),
    ),
    GetPage(
      name: CommonScreenRoutes.profileIdCard,
      page: () => ProfileSubScreen(title: 'Student ID card'),
    ),
    GetPage(
      name: CommonScreenRoutes.profileAcademicRecords,
      page: () => ProfileSubScreen(title: 'Academic records'),
    ),
    GetPage(
      name: CommonScreenRoutes.profileMedical,
      page: () => ProfileSubScreen(title: 'Medical information'),
    ),
    GetPage(
      name: CommonScreenRoutes.profileDocuments,
      page: () => ProfileSubScreen(title: 'Documents storage'),
    ),
  ];
}
