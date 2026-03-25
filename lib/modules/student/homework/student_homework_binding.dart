import 'package:get/get.dart';
import 'student_homework_controller.dart';

class StudentHomeworkBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentHomeworkController>(() => StudentHomeworkController());
  }
}
