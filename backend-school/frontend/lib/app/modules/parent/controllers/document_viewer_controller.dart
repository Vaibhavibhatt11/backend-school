import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
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
  final documents = <Map<String, dynamic>>[].obs;
  final selectedIndex = 0.obs;
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
        documents.assignAll(
          docs.whereType<Map>().map((e) {
            final m = Map<String, dynamic>.from(e);
            return {
              ...m,
              'name': (m['name'] ?? 'Document').toString(),
              'url': (m['url'] ?? m['fileUrl'] ?? m['previewUrl'] ?? '').toString().trim(),
            };
          }),
        );

        final requestedName = ((Get.arguments is Map) ? Get.arguments['document'] : null)?.toString();
        if (requestedName != null && requestedName.isNotEmpty) {
          final idx = documents.indexWhere(
            (d) => (d['name']?.toString().toLowerCase() ?? '') == requestedName.toLowerCase(),
          );
          selectedIndex.value = idx >= 0 ? idx : 0;
        } else {
          selectedIndex.value = 0;
        }
        _syncSelectedDocument();
      } else {
        documents.clear();
        previewUrl.value = '';
      }
    } finally {
      isLoading.value = false;
    }
  }

  void nextPage() {
    if (selectedIndex.value < documents.length - 1) {
      selectedIndex.value++;
      _syncSelectedDocument();
    }
  }

  void prevPage() {
    if (selectedIndex.value > 0) {
      selectedIndex.value--;
      _syncSelectedDocument();
    }
  }

  Future<void> download() async => _openCurrentDocumentUrl('download');
  Future<void> share() async => _openCurrentDocumentUrl('share');
  Future<void> print() async => _openCurrentDocumentUrl('print');

  void _syncSelectedDocument() {
    if (documents.isEmpty) return;
    final doc = documents[selectedIndex.value];
    documentTitle.value = (doc['name'] ?? 'Document').toString();
    previewUrl.value = (doc['url'] ?? '').toString().trim();
  }

  Future<void> _openCurrentDocumentUrl(String action) async {
    final url = previewUrl.value.trim();
    if (url.isEmpty) {
      Get.snackbar('Unavailable', 'No document URL found for this file.');
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null) {
      Get.snackbar('Invalid URL', 'Could not open document URL.');
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      Get.snackbar('Failed', 'Could not $action this document.');
    }
  }
}
