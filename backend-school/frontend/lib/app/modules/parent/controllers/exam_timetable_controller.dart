import 'package:get/get.dart';
import '../../../../common/services/parent/parent_academics_service.dart';
import '../../../../common/services/parent/parent_context_service.dart';
import '../../../../common/services/parent/parent_api_utils.dart';

class ExamTimetableController extends GetxController {
  final ParentAcademicsService _academicsService = Get.find<ParentAcademicsService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final month = DateTime(DateTime.now().year, DateTime.now().month).obs;
  final exams = <Map<String, dynamic>>[].obs;
  Worker? _childWorker;

  @override
  void onInit() {
    super.onInit();
    _childWorker = ever<String?>(
      _parentContext.selectedChildId,
      (_) => loadExams(),
    );
    loadExams();
  }

  Future<void> loadExams() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final monthStr = '${month.value.year}-${month.value.month.toString().padLeft(2, '0')}';
      final data = await _academicsService.getExamTimetable(
        childId: _parentContext.selectedChildId.value,
        month: monthStr,
      );
      final items = data['items'] ?? data['exams'];
      if (items is List) {
        exams.assignAll(items.whereType<Map>().map((e) => Map<String, dynamic>.from(e)));
      } else {
        exams.clear();
      }
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      exams.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void shiftMonth(int delta) {
    month.value = DateTime(month.value.year, month.value.month + delta);
    loadExams();
  }

  @override
  void onClose() {
    _childWorker?.dispose();
    super.onClose();
  }
}
