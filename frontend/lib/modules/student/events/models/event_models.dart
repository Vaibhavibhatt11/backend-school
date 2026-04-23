enum EventCategory { newEvent, upcoming, past }

class EventItem {
  const EventItem({
    required this.id,
    required this.title,
    required this.description,
    required this.venue,
    required this.organizer,
    required this.startAt,
    required this.category,
  });

  final String id;
  final String title;
  final String description;
  final String venue;
  final String organizer;
  final DateTime startAt;
  final EventCategory category;
}
