import 'package:get/get.dart';
import 'models/study_material_models.dart';

class StudentStudyMaterialsController extends GetxController {
  final RxString selectedCategory = 'All'.obs;
  final RxList<StudyMaterialItem> materials = <StudyMaterialItem>[].obs;

  static const List<String> categories = ['All', 'PDF', 'PPT', 'Image'];

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() {
    materials.assignAll([
      StudyMaterialItem(
        id: '1',
        type: StudyMaterialFileType.pdf,
        title: 'Chapter 5 – Motion & Force',
        subject: 'Physics',
        description: 'Notes and solved examples',
      ),
      StudyMaterialItem(
        id: '2',
        type: StudyMaterialFileType.ppt,
        title: 'Chemical Reactions – Overview',
        subject: 'Chemistry',
        description: 'Presentation slides',
      ),
      StudyMaterialItem(
        id: '3',
        type: StudyMaterialFileType.image,
        title: 'Algebra formulae chart',
        subject: 'Mathematics',
        description: 'Reference chart',
      ),
      StudyMaterialItem(
        id: '4',
        type: StudyMaterialFileType.pdf,
        title: 'History – Independence movement',
        subject: 'Social Studies',
        description: 'Summary notes',
      ),
      StudyMaterialItem(
        id: '5',
        type: StudyMaterialFileType.ppt,
        title: 'Cell structure & functions',
        subject: 'Biology',
        description: 'Lecture slides',
      ),
      StudyMaterialItem(
        id: '6',
        type: StudyMaterialFileType.pdf,
        title: 'Essay writing guide',
        subject: 'English',
        description: 'Tips and samples',
      ),
    ]);
  }

  List<StudyMaterialItem> get filteredMaterials {
    final cat = selectedCategory.value;
    if (cat == 'All') return materials;
    if (cat == 'PDF') return materials.where((e) => e.type == StudyMaterialFileType.pdf).toList();
    if (cat == 'PPT') return materials.where((e) => e.type == StudyMaterialFileType.ppt).toList();
    if (cat == 'Image') return materials.where((e) => e.type == StudyMaterialFileType.image).toList();
    return materials;
  }

  void setCategory(String cat) => selectedCategory.value = cat;

  void openMaterial(StudyMaterialItem item) {
    // Placeholder: in real app would open PDF/PPT/image viewer (e.g. webview or native viewer)
    Get.snackbar(
      'Open',
      '${item.title} (${item.type.name.toUpperCase()}) – viewer would open here',
    );
  }
}
