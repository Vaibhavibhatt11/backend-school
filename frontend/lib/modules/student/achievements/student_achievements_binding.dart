import 'package:get/get.dart';
import 'student_achievements_controller.dart';

class StudentAchievementsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentAchievementsController>(() => StudentAchievementsController());
  }
}
