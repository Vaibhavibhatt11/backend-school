import 'package:get/get.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import '../../../../common/services/parent/parent_communication_service.dart';
import '../../../../common/services/parent/parent_context_service.dart';

class NotificationsController extends GetxController {
  final ParentCommunicationService _communicationService = Get.find<ParentCommunicationService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final isLoading = false.obs;
  final selectedFilter = 'All'.obs;

  final notifications = <Map<String, dynamic>>[].obs;
  Worker? _childWorker;

  @override
  void onInit() {
    super.onInit();
    _childWorker = ever<String?>(
      _parentContext.selectedChildId,
      (_) => loadNotifications(),
    );
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      final data = await _communicationService.getNotifications(
        childId: _parentContext.selectedChildId.value,
      );
      final items = data['notifications'];
      if (items is List) {
        notifications.assignAll(
          items.whereType<Map>().map((e) {
            final section = Map<String, dynamic>.from(e);
            final rawItems = section['items'];
            return {
              'section': (section['section'] ?? '').toString(),
              'items': rawItems is List
                  ? rawItems.whereType<Map>().map((item) {
                      final m = Map<String, dynamic>.from(item);
                      return {
                        'type': (m['type'] ?? 'general').toString(),
                        'title': (m['title'] ?? '').toString(),
                        'description': (m['description'] ?? '').toString(),
                        'time': (m['time'] ?? '').toString(),
                        'unread': m['unread'] == true,
                        'action': m['action']?.toString(),
                      };
                    }).toList()
                  : <Map<String, dynamic>>[],
            };
          }),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(String filter) => selectedFilter.value = filter;
  void markAllRead() =>
      AppToast.show('All notifications marked as read');

  @override
  void onClose() {
    _childWorker?.dispose();
    super.onClose();
  }
}
