import 'package:get/get.dart';
import 'models/event_models.dart';

class StudentEventsController extends GetxController {
  final RxList<EventItem> events = <EventItem>[].obs;
  final Rx<EventCategory?> selectedFilter = Rx<EventCategory?>(null);

  @override
  void onInit() {
    super.onInit();
    events.clear();
  }

  List<EventItem> get filteredEvents {
    final filter = selectedFilter.value;
    if (filter == null) return events;
    return events.where((e) => e.category == filter).toList();
  }

  void setFilter(EventCategory? filter) {
    selectedFilter.value = filter;
  }
}
