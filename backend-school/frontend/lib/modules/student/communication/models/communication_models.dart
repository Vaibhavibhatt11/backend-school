/// Type of communication item.
enum CommunicationType {
  message,
  alert,
  announcement,
}

/// A single message, alert, or announcement.
class CommunicationItem {
  const CommunicationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.from,
    required this.date,
    this.isRead = false,
  });

  final String id;
  final CommunicationType type;
  final String title;
  final String body;
  final String from;
  final DateTime date;
  final bool isRead;
}

/// Student scheduled meeting request.
class ScheduledMeeting {
  const ScheduledMeeting({
    required this.id,
    required this.facultyName,
    required this.subject,
    required this.reason,
    required this.date,
    required this.day,
    required this.time,
    this.status = 'Scheduled',
  });

  final String id;
  final String facultyName;
  final String subject;
  final String reason;
  final DateTime date;
  final String day;
  final String time;
  final String status;
}
