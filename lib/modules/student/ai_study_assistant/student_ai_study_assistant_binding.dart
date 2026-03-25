import 'package:get/get.dart';
import 'student_ai_study_assistant_controller.dart';

class StudentAiStudyAssistantBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentAiStudyAssistantController>(() => StudentAiStudyAssistantController());
  }
}
