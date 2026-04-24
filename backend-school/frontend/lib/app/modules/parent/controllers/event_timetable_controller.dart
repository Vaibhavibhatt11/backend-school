import 'package:get/get.dart';
import '../../../../common/services/parent/parent_communication_service.dart';
import '../../../../common/services/parent/parent_context_service.dart';
import '../../../../common/services/parent/parent_api_utils.dart';

class EventTimetableController extends GetxController {
  final ParentCommunicationService _communicationService = Get.find<ParentCommunicationService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final month = DateTime(DateTime.now().year, DateTime.now().month).obs;
  final events = <Map<String, dynamic>>[].obs;
  Worker? _childWorker;

  @override
  void onInit() {
    super.onInit();
    _childWorker = ever<String?>(
      _parentContext.selectedChildId,
      (_) => loadEvents(),
    );
    loadEvents();
  }

  Future<void> loadEvents() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final monthStr = '${month.value.year}-${month.value.month.toString().padLeft(2, '0')}';
      final data = await _communicationService.getEventTimetable(
        childId: _parentContext.selectedChildId.value,
        month: monthStr,
      );
      final items = data['items'] ?? data['events'];
      if (items is List) {
        events.assignAll(items.whereType<Map>().map((e) => Map<String, dynamic>.from(e)));
      } else {
        events.clear();
      }
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      events.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void shiftMonth(int delta) {
    month.value = DateTime(month.value.year, month.value.month + delta);
    loadEvents();
  }

  @override
  void onClose() {
    _childWorker?.dispose();
    super.onClose();
  }
}
