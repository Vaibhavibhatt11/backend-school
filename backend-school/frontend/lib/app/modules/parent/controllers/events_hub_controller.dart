import 'package:get/get.dart';
import '../../../../common/services/parent/parent_api_utils.dart';
import '../../../../common/services/parent/parent_communication_service.dart';
import '../../../../common/services/parent/parent_context_service.dart';

class EventsHubController extends GetxController {
  final ParentCommunicationService _communicationService =
      Get.find<ParentCommunicationService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final selectedTab = 'all'.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final allEvents = <Map<String, dynamic>>[].obs;
  final registeredEventIds = <String>{}.obs;
  final eventPhotos = <Map<String, dynamic>>[].obs;

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

  @override
  void onClose() {
    _childWorker?.dispose();
    super.onClose();
  }

  void changeTab(String tab) => selectedTab.value = tab;

  List<Map<String, dynamic>> get competitions =>
      allEvents.where((e) => (e['type'] ?? '') == 'competition').toList();

  List<Map<String, dynamic>> get sportsActivities =>
      allEvents.where((e) => (e['type'] ?? '') == 'sports').toList();

  List<Map<String, dynamic>> get registrations => allEvents
      .where((e) => registeredEventIds.contains((e['id'] ?? '').toString()))
      .toList();

  bool isRegistered(String eventId) => registeredEventIds.contains(eventId);

  Future<void> loadEvents() async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _communicationService.getEventsHub(
        childId: _parentContext.selectedChildId.value,
      );
      final rawEvents = data['events'];
      final rawIds = data['registeredEventIds'];
      final rawPhotos = data['eventPhotos'];

      if (rawEvents is List) {
        allEvents.assignAll(
          rawEvents.whereType<Map>().map((e) {
            final m = Map<String, dynamic>.from(e);
            return {
              'id': (m['id'] ?? '').toString(),
              'title': (m['title'] ?? '').toString(),
              'type': (m['type'] ?? 'all').toString(),
              'description': (m['description'] ?? '').toString(),
              'date': DateTime.tryParse((m['date'] ?? '').toString()),
              'venue': (m['venue'] ?? '').toString(),
            };
          }),
        );
      } else {
        allEvents.clear();
      }

      if (rawIds is List) {
        registeredEventIds
          ..clear()
          ..addAll(rawIds.map((e) => e.toString()));
        registeredEventIds.refresh();
      } else {
        registeredEventIds.clear();
        registeredEventIds.refresh();
      }

      if (rawPhotos is List) {
        eventPhotos.assignAll(
          rawPhotos.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
        );
      } else {
        eventPhotos.clear();
      }
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      allEvents.clear();
      registeredEventIds.clear();
      registeredEventIds.refresh();
      eventPhotos.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> registerForEvent(String eventId) async {
    if (eventId.isEmpty) return;
    try {
      await _communicationService.registerForEvent(
        eventId,
        childId: _parentContext.selectedChildId.value,
      );
      registeredEventIds.add(eventId);
      registeredEventIds.refresh();
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
    }
  }

  Future<void> cancelRegistration(String eventId) async {
    if (eventId.isEmpty) return;
    try {
      await _communicationService.cancelEventRegistration(
        eventId,
        childId: _parentContext.selectedChildId.value,
      );
      registeredEventIds.remove(eventId);
      registeredEventIds.refresh();
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
    }
  }
}
