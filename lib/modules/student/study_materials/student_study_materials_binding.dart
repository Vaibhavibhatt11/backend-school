import 'package:get/get.dart';
import 'student_study_materials_controller.dart';

class StudentStudyMaterialsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentStudyMaterialsController>(() => StudentStudyMaterialsController());
  }
}
