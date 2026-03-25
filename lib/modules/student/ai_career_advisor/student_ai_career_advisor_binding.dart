import 'package:get/get.dart';
import 'student_ai_career_advisor_controller.dart';

class StudentAiCareerAdvisorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentAiCareerAdvisorController>(() => StudentAiCareerAdvisorController());
  }
}
