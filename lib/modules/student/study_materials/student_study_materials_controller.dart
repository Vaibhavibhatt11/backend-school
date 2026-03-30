import 'package:get/get.dart';
import '../../../common/utils/app_toast.dart';
import 'models/study_material_models.dart';

class StudentStudyMaterialsController extends GetxController {
  final RxString selectedCategory = 'All'.obs;
  final RxList<StudyMaterialItem> materials = <StudyMaterialItem>[].obs;

  static const List<String> categories = ['All', 'PDF', 'PPT', 'Image'];

  @override
  void onInit() {
    super.onInit();
    materials.clear();
  }

  List<StudyMaterialItem> get filteredMaterials {
    final cat = selectedCategory.value;
    if (cat == 'All') return materials;
    if (cat == 'PDF') {
      return materials.where((e) => e.type == StudyMaterialFileType.pdf).toList();
    }
    if (cat == 'PPT') {
      return materials.where((e) => e.type == StudyMaterialFileType.ppt).toList();
    }
    if (cat == 'Image') {
      return materials.where((e) => e.type == StudyMaterialFileType.image).toList();
    }
    return materials;
  }

  void setCategory(String cat) => selectedCategory.value = cat;

  void openMaterial(StudyMaterialItem item) {
    AppToast.show('${item.title} (${item.type.name.toUpperCase()})');
  }
}
