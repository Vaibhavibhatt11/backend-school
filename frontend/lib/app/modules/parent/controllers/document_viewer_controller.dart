import 'package:get/get.dart';
import '../../../../common/services/parent/parent_context_service.dart';
import '../../../../common/services/parent/parent_profile_service.dart';

class DocumentViewerController extends GetxController {
  final ParentProfileService _profileService = Get.find<ParentProfileService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final isLoading = false.obs;
  final documentTitle = ''.obs;
  final studentName = ''.obs;
  final studentClass = ''.obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  /// HTTPS URL from document list when backend provides `url` / `fileUrl` / `previewUrl`.
  final previewUrl = ''.obs;

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
      if (docs is List && docs.isNotEmpty) {
        final first = docs.first;
        if (first is Map) {
          final m = Map<String, dynamic>.from(first);
          if (documentTitle.value.isEmpty && m['name'] != null) {
            documentTitle.value = m['name'].toString();
          }
          previewUrl.value =
              (m['url'] ?? m['fileUrl'] ?? m['previewUrl'] ?? '').toString().trim();
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

  Future<void> download() async => loadDocuments();
  Future<void> share() async => loadDocuments();
  Future<void> print() async => loadDocuments();
}
