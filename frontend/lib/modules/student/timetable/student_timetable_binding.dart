import 'package:get/get.dart';
import 'student_timetable_controller.dart';

class StudentTimetableBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentTimetableController>(() => StudentTimetableController());
  }
}
