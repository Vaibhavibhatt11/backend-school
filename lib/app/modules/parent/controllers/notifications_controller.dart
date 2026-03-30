import 'package:get/get.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import '../../../../common/services/parent/parent_communication_service.dart';
import '../../../../common/services/parent/parent_context_service.dart';
import '../../../../common/services/parent/parent_api_utils.dart';

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
      final grouped = data['notifications'];
      if (grouped is List) {
        notifications.assignAll(
          grouped.whereType<Map>().map((e) {
            final section = Map<String, dynamic>.from(e);
            final rawItems = section['items'];
            return {
              'section': (section['section'] ?? '').toString(),
              'items': rawItems is List
                  ? rawItems.whereType<Map>().map(_mapNotificationItem).toList()
                  : <Map<String, dynamic>>[],
            };
          }),
        );
        return;
      }
      notifications.clear();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
      notifications.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _mapNotificationItem(Map<dynamic, dynamic> raw) {
    final m = Map<String, dynamic>.from(raw);
    return {
      'type': (m['type'] ?? 'general').toString(),
      'title': (m['title'] ?? m['subject'] ?? '').toString(),
      'description': (m['description'] ?? m['body'] ?? m['message'] ?? '').toString(),
      'time': (m['time'] ?? m['createdAt'] ?? '').toString(),
      'unread': m['unread'] == true,
      'action': m['action']?.toString(),
    };
  }

  void setFilter(String filter) => selectedFilter.value = filter;
  Future<void> markAllRead() async {
    try {
      await _communicationService.markAllNotificationsRead(
        childId: _parentContext.selectedChildId.value,
      );
      await loadNotifications();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  @override
  void onClose() {
    _childWorker?.dispose();
    super.onClose();
  }
}
