import 'package:get/get.dart';
import 'student_exams_controller.dart';

class StudentExamsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentExamsController>(() => StudentExamsController());
  }
}
