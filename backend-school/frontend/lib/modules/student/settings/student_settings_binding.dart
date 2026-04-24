import 'package:get/get.dart';
import 'student_settings_controller.dart';

class StudentSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentSettingsController>(() => StudentSettingsController());
  }
}
