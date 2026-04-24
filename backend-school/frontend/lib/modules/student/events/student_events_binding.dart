import 'package:get/get.dart';
import 'student_events_controller.dart';

class StudentEventsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentEventsController>(() => StudentEventsController());
  }
}
