import 'package:get/get.dart';
import '../../../../common/services/parent/parent_academics_service.dart';
import '../../../../common/services/parent/parent_context_service.dart';

class LiveClassController extends GetxController {
  final ParentAcademicsService _academicsService =
      Get.find<ParentAcademicsService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final isLoading = false.obs;
  final subject = ''.obs;
  @override
  void onInit() {
    super.onInit();
    subject.value = Get.arguments['subject'] ?? '';
    _childWorker = ever<String?>(
      _parentContext.selectedChildId,
      (_) => loadLiveClasses(),
    );
    loadLiveClasses();
  }

  final selectedDate = DateTime.now().obs;
  final liveClass = <String, dynamic>{}.obs;

  final upcomingClasses = <Map<String, dynamic>>[].obs;
  Worker? _childWorker;

  @override
  void onClose() {
    _childWorker?.dispose();
    super.onClose();
  }

  Future<void> loadLiveClasses() async {
    isLoading.value = true;
    try {
      final data = await _academicsService.getLiveClasses(
        childId: _parentContext.selectedChildId.value,
      );
      final current = data['liveClass'];
      if (current is Map) {
        final m = Map<String, dynamic>.from(current);
        final title = (m['title'] ?? m['subject'] ?? '').toString();
        final teacher = (m['teacher'] ?? '').toString();
        final timeIso = (m['time'] ?? '').toString();
        liveClass.assignAll({
          'title': title,
          'subject': title,
          'teacher': teacher,
          'time': _displayTime(timeIso),
        });
        if (subject.value.isEmpty && title.isNotEmpty) subject.value = title;
      } else {
        liveClass.clear();
      }
      final upcoming = data['upcomingClasses'];
      if (upcoming is List) {
        upcomingClasses.assignAll(
          upcoming.whereType<Map>().map((e) {
            final m = Map<String, dynamic>.from(e);
            final title = (m['title'] ?? m['subject'] ?? '').toString();
            return {
              'title': title,
              'subject': title,
              'teacher': (m['teacher'] ?? '').toString(),
              'room': (m['room'] ?? '').toString(),
              'time': _displayTime((m['time'] ?? '').toString()),
              'isLive': m['isLive'] == true,
            };
          }),
        );
      } else {
        upcomingClasses.clear();
      }
    } finally {
      isLoading.value = false;
    }
  }

  String _displayTime(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Future<void> joinClass() async => loadLiveClasses();
}
