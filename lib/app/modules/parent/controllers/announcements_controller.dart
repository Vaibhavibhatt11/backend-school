import 'package:get/get.dart';
import '../../../../common/services/parent/parent_communication_service.dart';
import '../../../../common/services/parent/parent_context_service.dart';

class AnnouncementsController extends GetxController {
  final ParentCommunicationService _communicationService = Get.find<ParentCommunicationService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final isLoading = false.obs;
  final selectedFilter = 'All'.obs;

  final announcements =
      [
        {
          'type': 'urgent',
          'title': 'Emergency Water Main Repair',
          'description':
              'Main entrance will be closed for the next 2 hours. Please use the South Gate for student pickup...',
          'postedBy': 'Admin',
          'time': '12m ago',
          'urgent': true,
        },
        {
          'type': 'teacher',
          'teacherName': 'Mrs. Henderson',
          'teacherClass': 'Grade 4B',
          'time': '2h ago',
          'title': 'Weekly Science Project Materials',
          'description':
              'Friendly reminder that we need cardboard boxes and plastic caps for Friday\'s robot building session. Looking forward to seeing the creations!',
          'attachment': 'Project_Guide.pdf',
        },
        // ... more
      ].obs;

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
          items.whereType<Map>().map((e) => Map<String, Object>.from(e)),
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
