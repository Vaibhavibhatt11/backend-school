import 'package:get/get.dart';
import '../../../../common/services/parent/parent_academics_service.dart';
import '../../../../common/services/parent/parent_context_service.dart';
import '../../../../common/services/parent/parent_api_utils.dart';

class MonthlyTimetableController extends GetxController {
  final ParentAcademicsService _academicsService = Get.find<ParentAcademicsService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final selectedMonth = DateTime(DateTime.now().year, DateTime.now().month).obs;
  final selectedDate = DateTime.now().obs;
  final dayItems = <Map<String, dynamic>>[].obs;
  Worker? _childWorker;

  @override
  void onInit() {
    super.onInit();
    _childWorker = ever<String?>(
      _parentContext.selectedChildId,
      (_) => loadForSelectedDate(),
    );
    loadForSelectedDate();
  }

  Future<void> loadForSelectedDate() async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final day = selectedDate.value.toIso8601String().split('T').first;
      final data = await _academicsService.getTimetable(
        childId: _parentContext.selectedChildId.value,
        day: day,
      );
      final items = data['items'];
      if (items is List) {
        dayItems.assignAll(
          items.whereType<Map>().map((e) {
            final m = Map<String, dynamic>.from(e);
            return {
              'time': (m['time'] ?? '').toString(),
              'subject': (m['subject'] ?? '').toString(),
              'teacher': (m['teacher'] ?? '').toString(),
              'room': (m['room'] ?? '').toString(),
              'period': (m['period'] ?? '').toString(),
            };
          }),
        );
      } else {
        dayItems.clear();
      }
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
    } finally {
      isLoading.value = false;
    }
  }

  void changeMonth(DateTime month) {
    selectedMonth.value = DateTime(month.year, month.month);
    final d = selectedDate.value;
    selectedDate.value = DateTime(month.year, month.month, d.day.clamp(1, 28));
    loadForSelectedDate();
  }

  void selectDate(DateTime date) {
    selectedDate.value = DateTime(date.year, date.month, date.day);
    loadForSelectedDate();
  }

  @override
  void onClose() {
    _childWorker?.dispose();
    super.onClose();
  }
}
