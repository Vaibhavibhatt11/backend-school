import 'package:get/get.dart';
import '../../../common/routes/common_routes_screens.dart';

class StudentDashboardController extends GetxController {
  final RxString greeting = 'Hello'.obs;
  final RxString userName = 'Student'.obs;

  @override
  void onInit() {
    super.onInit();
    _setGreeting();
  }

  void _setGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      greeting.value = 'Good Morning';
    } else if (hour < 17) {
      greeting.value = 'Good Afternoon';
    } else {
      greeting.value = 'Good Evening';
    }
  }

  void goToProfile() => Get.toNamed(CommonScreenRoutes.studentProfile);
  void goToTimetable() => Get.toNamed(CommonScreenRoutes.studentTimetable);
  void goToAttendance() => Get.toNamed(CommonScreenRoutes.studentAttendance);
  void goToHomework() => Get.toNamed(CommonScreenRoutes.studentHomework);
  void goToStudyMaterials() => Get.toNamed(CommonScreenRoutes.studentStudyMaterials);
  void goToExams() => Get.toNamed(CommonScreenRoutes.studentExams);
  void goToFees() => Get.toNamed(CommonScreenRoutes.studentFees);
  void goToCommunication() => Get.toNamed(CommonScreenRoutes.studentCommunication);
  void goToEvents() => Get.toNamed(CommonScreenRoutes.studentEvents);
  void goToHealth() => Get.toNamed(CommonScreenRoutes.studentHealth);
  void goToTransport() => Get.toNamed(CommonScreenRoutes.studentTransport);
  void goToLibrary() => Get.toNamed(CommonScreenRoutes.studentLibrary);
  void goToAchievements() => Get.toNamed(CommonScreenRoutes.studentAchievements);
  void goToSettings() => Get.toNamed(CommonScreenRoutes.studentSettings);
}
