import 'package:get/get.dart';
import 'student_library_controller.dart';

class StudentLibraryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentLibraryController>(() => StudentLibraryController());
  }
}
