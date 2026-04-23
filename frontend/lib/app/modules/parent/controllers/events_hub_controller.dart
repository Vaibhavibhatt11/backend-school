import 'package:get/get.dart';

class EventsHubController extends GetxController {
  final selectedTab = 'all'.obs;
  final allEvents = <Map<String, dynamic>>[].obs;
  final registeredEventIds = <String>{}.obs;
  final eventPhotos = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _seedData();
  }

  void changeTab(String tab) => selectedTab.value = tab;

  List<Map<String, dynamic>> get competitions =>
      allEvents.where((e) => (e['type'] ?? '') == 'competition').toList();

  List<Map<String, dynamic>> get sportsActivities =>
      allEvents.where((e) => (e['type'] ?? '') == 'sports').toList();

  List<Map<String, dynamic>> get registrations =>
      allEvents.where((e) => registeredEventIds.contains((e['id'] ?? '').toString())).toList();

  bool isRegistered(String eventId) => registeredEventIds.contains(eventId);

  void registerForEvent(String eventId) {
    registeredEventIds.add(eventId);
    registeredEventIds.refresh();
  }

  void cancelRegistration(String eventId) {
    registeredEventIds.remove(eventId);
    registeredEventIds.refresh();
  }

  void _seedData() {
    final now = DateTime.now();
    allEvents.assignAll([
      {
        'id': 'ev1',
        'title': 'Annual Science Exhibition',
        'type': 'competition',
        'description': 'Model presentation and innovation challenge.',
        'date': DateTime(now.year, now.month, now.day + 4),
        'venue': 'School Auditorium',
      },
      {
        'id': 'ev2',
        'title': 'Inter-house Football League',
        'type': 'sports',
        'description': 'Knockout tournament for all houses.',
        'date': DateTime(now.year, now.month, now.day + 7),
        'venue': 'Main Ground',
      },
      {
        'id': 'ev3',
        'title': 'Art & Craft Challenge',
        'type': 'competition',
        'description': 'Creative art, collage and handmade craft event.',
        'date': DateTime(now.year, now.month, now.day + 10),
        'venue': 'Art Room',
      },
      {
        'id': 'ev4',
        'title': 'Athletics Practice Camp',
        'type': 'sports',
        'description': 'Track and field preparation with coaches.',
        'date': DateTime(now.year, now.month, now.day + 13),
        'venue': 'Sports Complex',
      },
    ]);

    registeredEventIds.addAll({'ev1'});

    eventPhotos.assignAll([
      {'id': 'ph1', 'title': 'Sports Day Opening', 'event': 'Sports Day'},
      {'id': 'ph2', 'title': 'Football Final Match', 'event': 'Football League'},
      {'id': 'ph3', 'title': 'Science Fair Model', 'event': 'Science Exhibition'},
      {'id': 'ph4', 'title': 'Prize Distribution', 'event': 'Annual Function'},
      {'id': 'ph5', 'title': 'Art Competition', 'event': 'Art Challenge'},
      {'id': 'ph6', 'title': 'Relay Race', 'event': 'Athletics Camp'},
    ]);
  }
}
