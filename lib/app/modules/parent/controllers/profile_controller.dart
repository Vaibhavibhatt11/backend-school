import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';
import '../../../../common/services/parent/parent_context_service.dart';
import '../../../../common/services/parent/parent_profile_service.dart';

class ProfileController extends GetxController {
  final ParentProfileService _profileService = Get.find<ParentProfileService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final isLoading = false.obs;
  final studentName = ''.obs;
  final studentClass = ''.obs;
  final academicYear = ''.obs;
  final dob = ''.obs;
  final bloodGroup = ''.obs;
  final fatherName = ''.obs;
  final motherName = ''.obs;
  final currentTermGrade = ''.obs;
  final currentTermPercentage = 0.0.obs;
  final classAvg = 0.0.obs;

  final documents = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      final data = await _profileService.getProfileHub(
        childId: _parentContext.selectedChildId.value,
      );
      studentName.value = data['studentName']?.toString() ?? studentName.value;
      studentClass.value = data['studentClass']?.toString() ?? studentClass.value;
      academicYear.value = data['academicYear']?.toString() ?? academicYear.value;
      dob.value = data['dob']?.toString() ?? dob.value;
      bloodGroup.value = data['bloodGroup']?.toString() ?? bloodGroup.value;
      fatherName.value = data['fatherName']?.toString() ?? fatherName.value;
      motherName.value = data['motherName']?.toString() ?? motherName.value;
      final termPercent = data['currentTermPercentage'];
      if (termPercent is num) currentTermPercentage.value = termPercent.toDouble();
      final avg = data['classAvg'];
      if (avg is num) classAvg.value = avg.toDouble();
      final docs = data['documents'];
      if (docs is List) {
        documents.assignAll(docs.whereType<Map>().map((e) => Map<String, dynamic>.from(e)));
      }
    } finally {
      isLoading.value = false;
    }
  }

  void editPersonal() => Get.snackbar('Edit', 'Edit personal info');
  void editGuardian() => Get.snackbar('Edit', 'Edit guardian info');
  void viewAllDocuments() => Get.snackbar('Documents', 'All documents list');
  void downloadDocument(String docName) =>
      Get.snackbar('Download', 'Downloading $docName');
  void openSettings() => Get.toNamed(AppRoutes.PARENT_SETTINGS);
  void goToLibrary() => Get.toNamed(AppRoutes.PARENT_LIBRARY);

  void viewDocument(String docName) => Get.toNamed(
    AppRoutes.PARENT_DOCUMENT_VIEWER,
    arguments: {'document': docName},
  );
}
