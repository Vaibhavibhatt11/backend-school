import 'package:get/get.dart';
import 'student_transport_controller.dart';

class StudentTransportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentTransportController>(() => StudentTransportController());
  }
}
