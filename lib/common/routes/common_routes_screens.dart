class CommonScreenRoutes {
  CommonScreenRoutes._();
  static final CommonScreenRoutes _instance = CommonScreenRoutes._();
  factory CommonScreenRoutes() => _instance;

  // Splash
  static const String splashScreen = '/SplashScreen';

  // Auth
  static const String loginScreen = '/LoginScreen';
  static const String forgotPasswordScreen = '/ForgotPasswordScreen';

  // Main app shell (bottom nav)
  static const String mainShell = '/MainShell';

  // Student / Parent
  static const String studentDashboard = '/StudentDashboard';
  static const String studentProfile = '/StudentProfile';
  static const String studentTimetable = '/StudentTimetable';
  static const String studentAttendance = '/StudentAttendance';
  static const String studentHomework = '/StudentHomework';
  static const String studentStudyMaterials = '/StudentStudyMaterials';
  static const String studentExams = '/StudentExams';
  static const String studentFees = '/StudentFees';
  static const String studentCommunication = '/StudentCommunication';
  static const String studentEvents = '/StudentEvents';
  static const String studentHealth = '/StudentHealth';
  static const String studentTransport = '/StudentTransport';
  static const String studentLibrary = '/StudentLibrary';
  static const String studentAchievements = '/StudentAchievements';
  static const String studentSettings = '/StudentSettings';

  // Profile sub-screens (can be same screen with tabs or separate)
  static const String profilePersonalDetails = '/ProfilePersonalDetails';
  static const String profileParentDetails = '/ProfileParentDetails';
  static const String profileClassSection = '/ProfileClassSection';
  static const String profileIdCard = '/ProfileIdCard';
  static const String profileAcademicRecords = '/ProfileAcademicRecords';
  static const String profileMedical = '/ProfileMedical';
  static const String profileDocuments = '/ProfileDocuments';
}
