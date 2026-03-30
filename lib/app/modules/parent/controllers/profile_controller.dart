import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';
import '../../../../common/services/parent/parent_context_service.dart';
import '../../../../common/services/parent/parent_profile_service.dart';

class ProfileController extends GetxController {
  final ParentProfileService _profileService = Get.find<ParentProfileService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final isLoading = false.obs;
  final studentName = ''.obs;
  final studentClass = ''.obs;
  final studentPhotoUrl = ''.obs;
  final academicYear = ''.obs;
  final dob = ''.obs;
  final bloodGroup = ''.obs;
  final fatherName = ''.obs;
  final motherName = ''.obs;
  final currentTermGrade = ''.obs;
  final currentTermPercentage = 0.0.obs;
  final classAvg = 0.0.obs;

  final documents = <Map<String, dynamic>>[].obs;
  Worker? _childWorker;

  @override
  void onInit() {
    super.onInit();
    _childWorker = ever<String?>(
      _parentContext.selectedChildId,
      (_) => loadProfile(),
    );
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
      studentPhotoUrl.value =
          (data['photoUrl'] ?? data['avatarUrl'] ?? data['studentPhotoUrl'] ?? studentPhotoUrl.value)
              .toString();
      academicYear.value = data['academicYear']?.toString() ?? academicYear.value;
      dob.value = data['dob']?.toString() ?? dob.value;
      bloodGroup.value = data['bloodGroup']?.toString() ?? bloodGroup.value;
      fatherName.value = data['fatherName']?.toString() ?? fatherName.value;
      motherName.value = data['motherName']?.toString() ?? motherName.value;
      final termPercent = data['currentTermPercentage'];
      currentTermPercentage.value = termPercent is num ? termPercent.toDouble() : 0.0;
      final avg = data['classAvg'];
      classAvg.value = avg is num ? avg.toDouble() : 0.0;
      currentTermGrade.value = _gradeFromPercent(currentTermPercentage.value);
      final docs = data['documents'];
      if (docs is List) {
        documents.assignAll(docs.whereType<Map>().map((e) => Map<String, dynamic>.from(e)));
      } else {
        documents.clear();
      }
    } finally {
      isLoading.value = false;
    }
  }

  String _gradeFromPercent(double percent) {
    if (percent >= 90) return 'A+';
    if (percent >= 80) return 'A';
    if (percent >= 70) return 'B';
    if (percent >= 60) return 'C';
    if (percent >= 50) return 'D';
    return 'E';
  }

  void editPersonal() => AppToast.show('Edit personal info');
  void editGuardian() => AppToast.show('Edit guardian info');
  void viewAllDocuments() => AppToast.show('All documents list');
  void downloadDocument(String docName) => AppToast.show('Downloading $docName');
  void openSettings() => Get.toNamed(AppRoutes.PARENT_SETTINGS);
  void goToLibrary() => Get.toNamed(AppRoutes.PARENT_LIBRARY);

  void viewDocument(String docName) => Get.toNamed(
    AppRoutes.PARENT_DOCUMENT_VIEWER,
    arguments: {'document': docName},
  );

  @override
  void onClose() {
    _childWorker?.dispose();
    super.onClose();
  }
}
