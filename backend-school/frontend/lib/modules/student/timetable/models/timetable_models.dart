/// One slot in the timetable: a single period on a given day.
class TimetableSlot {
  const TimetableSlot({
    required this.dayIndex,
    required this.periodIndex,
    required this.startTime,
    required this.endTime,
    required this.subject,
    this.teacher,
    this.room,
  });

  /// 0 = Monday, 4 = Friday.
  final int dayIndex;
  /// 1-based period number.
  final int periodIndex;
  final String startTime;
  final String endTime;
  final String subject;
  final String? teacher;
  final String? room;
}

/// Timetable for a single class (e.g. Class 2, Class 9).
class ClassTimetable {
  const ClassTimetable({
    required this.classId,
    required this.classLabel,
    required this.slots,
  });

  final String classId;
  final String classLabel;
  final List<TimetableSlot> slots;
}

/// Day labels for the grid (Mon–Fri).
const List<String> kTimetableDayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

/// Default period times (can be overridden per school).
const List<String> kDefaultPeriodTimes = [
  '8:00–8:45',
  '8:50–9:35',
  '9:40–10:25',
  '10:40–11:25',
  '11:30–12:15',
  '12:20–13:05',
  '13:10–13:55',
  '14:00–14:45',
];
