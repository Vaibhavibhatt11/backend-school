import 'package:get/get.dart';
import 'student_health_controller.dart';

class StudentHealthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentHealthController>(() => StudentHealthController());
  }
}
