import 'package:get/get.dart';
import 'student_fees_controller.dart';

class StudentFeesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentFeesController>(() => StudentFeesController());
  }
}
