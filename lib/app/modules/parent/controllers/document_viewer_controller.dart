import 'package:get/get.dart';
import '../../../../common/services/parent/parent_context_service.dart';
import '../../../../common/services/parent/parent_profile_service.dart';

class DocumentViewerController extends GetxController {
  final ParentProfileService _profileService = Get.find<ParentProfileService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final isLoading = false.obs;
  final documentTitle = 'Term 1 Report Card'.obs;
  final studentName = 'Arjun Sharma'.obs;
  final studentClass = 'Grade 10-B'.obs;
  final currentPage = 1.obs;
  final totalPages = 2.obs;

  @override
  void onInit() {
    super.onInit();
    final argDoc = (Get.arguments is Map) ? Get.arguments['document']?.toString() : null;
    if (argDoc != null && argDoc.isNotEmpty) {
      documentTitle.value = argDoc;
    }
    loadDocuments();
  }

  Future<void> loadDocuments() async {
    isLoading.value = true;
    try {
      final data = await _profileService.getDocuments(
        childId: _parentContext.selectedChildId.value,
        page: currentPage.value,
      );
      final pagination = data['pagination'];
      if (pagination is Map) {
        final map = Map<String, dynamic>.from(pagination);
        currentPage.value = int.tryParse(map['currentPage']?.toString() ?? '') ?? currentPage.value;
        totalPages.value = int.tryParse(map['totalPages']?.toString() ?? '') ?? totalPages.value;
      }
      final docs = data['documents'];
      if (docs is List && docs.isNotEmpty && documentTitle.value.isEmpty) {
        final first = docs.first;
        if (first is Map && first['name'] != null) {
          documentTitle.value = first['name'].toString();
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      loadDocuments();
    }
  }

  void prevPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      loadDocuments();
    }
  }

  void download() => Get.snackbar('Download', 'Downloading document...');
  void share() => Get.snackbar('Share', 'Sharing document...');
  void print() => Get.snackbar('Print', 'Printing document...');
}
