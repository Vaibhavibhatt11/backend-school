import 'package:get/get.dart';
import '../../../../common/services/parent/parent_communication_service.dart';
import '../../../../common/services/parent/parent_context_service.dart';

class AnnouncementsController extends GetxController {
  final ParentCommunicationService _communicationService = Get.find<ParentCommunicationService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final isLoading = false.obs;
  final selectedFilter = 'All'.obs;

  final announcements = <Map<String, dynamic>>[].obs;
  Worker? _childWorker;

  @override
  void onInit() {
    super.onInit();
    _childWorker = ever<String?>(
      _parentContext.selectedChildId,
      (_) => loadAnnouncements(),
    );
    loadAnnouncements();
  }

  Future<void> loadAnnouncements() async {
    isLoading.value = true;
    try {
      final type = selectedFilter.value.toLowerCase() == 'all'
          ? null
          : selectedFilter.value.toLowerCase();
      final data = await _communicationService.getAnnouncements(
        childId: _parentContext.selectedChildId.value,
        type: type,
      );
      final items = data['announcements'];
      if (items is List) {
        announcements.assignAll(
          items.whereType<Map>().map((e) {
            final m = Map<String, dynamic>.from(e);
            return {
              'type': (m['type'] ?? 'general').toString().toLowerCase(),
              'title': (m['title'] ?? '').toString(),
              'description': (m['description'] ?? '').toString(),
              'postedBy': (m['postedBy'] ?? '').toString(),
              'time': (m['time'] ?? '').toString(),
              'teacherName': (m['teacherName'] ?? '').toString(),
              'teacherClass': (m['teacherClass'] ?? '').toString(),
              'attachment': m['attachment']?.toString(),
            };
          }),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    loadAnnouncements();
  }

  @override
  void onClose() {
    _childWorker?.dispose();
    super.onClose();
  }
}
