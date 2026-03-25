import 'package:get/get.dart';
import 'models/event_models.dart';

class StudentEventsController extends GetxController {
  final RxList<EventItem> events = <EventItem>[].obs;
  final Rx<EventCategory?> selectedFilter = Rx<EventCategory?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadMockEvents();
  }

  void _loadMockEvents() {
    final now = DateTime.now();
    events.assignAll([
      EventItem(
        id: 'E1',
        title: 'Annual Science Exhibition',
        description:
            'Display your science projects and working models. Shortlisted teams will represent school at district level.',
        venue: 'Main Auditorium',
        organizer: 'Science Department',
        startAt: DateTime(now.year, now.month, now.day + 2, 10, 0),
        category: EventCategory.newEvent,
      ),
      EventItem(
        id: 'E2',
        title: 'Inter-house Football Tournament',
        description:
            'League stage fixtures for all houses. Students from classes 7-10 can participate.',
        venue: 'School Ground',
        organizer: 'Sports Committee',
        startAt: DateTime(now.year, now.month, now.day + 6, 8, 30),
        category: EventCategory.upcoming,
      ),
      EventItem(
        id: 'E3',
        title: 'Mathematics Quiz Challenge',
        description:
            'Team-based quiz for logical reasoning and rapid calculations. Register through class teacher.',
        venue: 'Seminar Hall',
        organizer: 'Mathematics Department',
        startAt: DateTime(now.year, now.month, now.day + 9, 11, 0),
        category: EventCategory.upcoming,
      ),
      EventItem(
        id: 'E4',
        title: 'Republic Day Celebration',
        description:
            'Flag hoisting, cultural performances, and prize distribution for achievers.',
        venue: 'School Campus',
        organizer: 'School Admin',
        startAt: DateTime(now.year, now.month, now.day - 25, 8, 0),
        category: EventCategory.past,
      ),
      EventItem(
        id: 'E5',
        title: 'Art & Craft Showcase',
        description:
            'Exhibition of student art work with jury feedback and merit certificates.',
        venue: 'Art Room Block',
        organizer: 'Arts Department',
        startAt: DateTime(now.year, now.month, now.day - 12, 9, 30),
        category: EventCategory.past,
      ),
    ]);
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
