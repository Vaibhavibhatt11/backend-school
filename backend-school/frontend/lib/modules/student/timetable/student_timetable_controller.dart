import 'package:get/get.dart';
import 'models/timetable_models.dart';

class StudentTimetableController extends GetxController {
  /// Available class IDs fetched by integration layer. Empty until loaded.
  final List<String> availableClassIds = [];
  /// Label for display.
  String classLabel(String id) => 'Class $id';

  /// Currently selected class IDs (1 or more). Always at least one.
  final RxList<String> selectedClassIds = <String>[].obs;

  /// All timetables (classId -> ClassTimetable) from API.
  final Map<String, ClassTimetable> _timetables = {};

  @override
  void onInit() {
    super.onInit();
    _timetables.clear();
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

}
