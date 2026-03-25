import 'package:get/get.dart';
import 'models/timetable_models.dart';

class StudentTimetableController extends GetxController {
  /// Available class IDs to choose from (e.g. 2, 4, 9).
  final List<String> availableClassIds = ['2', '4', '9'];
  /// Label for display.
  String classLabel(String id) => 'Class $id';

  /// Currently selected class IDs (1 or more). Always at least one.
  final RxList<String> selectedClassIds = <String>[].obs;

  /// All timetables (classId -> ClassTimetable). Filled with mock data.
  final Map<String, ClassTimetable> _timetables = {};

  @override
  void onInit() {
    super.onInit();
    _timetables.addAll(_buildMockTimetables());
    if (selectedClassIds.isEmpty) {
      selectedClassIds.add(availableClassIds.first);
    }
  }

  bool isSelected(String classId) => selectedClassIds.contains(classId);

  void toggleClass(String classId) {
    if (selectedClassIds.contains(classId)) {
      if (selectedClassIds.length > 1) {
        selectedClassIds.remove(classId);
      }
    } else {
      selectedClassIds.add(classId);
    }
  }

  ClassTimetable? timetableForClass(String classId) => _timetables[classId];

  /// Get slot at (dayIndex, periodIndex) for a class. dayIndex 0=Mon, periodIndex 1-based.
  TimetableSlot? getSlot(String classId, int dayIndex, int periodIndex) {
    final t = _timetables[classId];
    if (t == null) return null;
    try {
      return t.slots.firstWhere(
        (s) => s.dayIndex == dayIndex && s.periodIndex == periodIndex,
      );
    } catch (_) {
      return null;
    }
  }

  static Map<String, ClassTimetable> _buildMockTimetables() {
    const subjects = [
      'Math', 'English', 'Science', 'Hindi', 'SST', 'EVS', 'Art', 'PE', 'Music', 'IT',
    ];
    const teachers = ['Mr. Sharma', 'Ms. Patel', 'Mr. Kumar', 'Ms. Singh', 'Mr. Roy'];
    const rooms = ['101', '102', '103', '201', '202', 'Lab 1', 'Hall'];

    const startTimes = ['8:00', '8:50', '9:40', '10:40', '11:30', '12:20', '13:10', '14:00'];
    const endTimes = ['8:45', '9:35', '10:25', '11:25', '12:15', '13:05', '13:55', '14:45'];
    ClassTimetable buildForClass(String classId) {
      final slots = <TimetableSlot>[];
      for (var d = 0; d < 5; d++) {
        for (var p = 1; p <= 8; p++) {
          final idx = (int.tryParse(classId) ?? 0) + d * 3 + p;
          final sub = subjects[idx % subjects.length];
          final teacher = teachers[(d + p) % teachers.length];
          final room = rooms[(d + p) % rooms.length];
          slots.add(TimetableSlot(
            dayIndex: d,
            periodIndex: p,
            startTime: startTimes[p - 1],
            endTime: endTimes[p - 1],
            subject: sub,
            teacher: teacher,
            room: room,
          ));
        }
      }
      return ClassTimetable(classId: classId, classLabel: 'Class $classId', slots: slots);
    }

    return {
      '2': buildForClass('2'),
      '4': buildForClass('4'),
      '9': buildForClass('9'),
    };
  }
}
