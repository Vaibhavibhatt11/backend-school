import 'package:get/get.dart';
import 'student_communication_controller.dart';

class StudentCommunicationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentCommunicationController>(() => StudentCommunicationController());
  }
}
