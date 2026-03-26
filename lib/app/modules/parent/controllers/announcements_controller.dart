import 'package:get/get.dart';
import '../../../../common/services/parent/parent_communication_service.dart';
import '../../../../common/services/parent/parent_context_service.dart';

class AnnouncementsController extends GetxController {
  final ParentCommunicationService _communicationService = Get.find<ParentCommunicationService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final isLoading = false.obs;
  final selectedFilter = 'All'.obs;

  final announcements = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
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
          items.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
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
}
