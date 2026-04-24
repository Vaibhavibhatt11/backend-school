import 'package:get/get.dart';
import '../../../../common/services/parent/parent_academics_service.dart';
import '../../../../common/services/parent/parent_api_utils.dart';
import '../../../../common/services/parent/parent_context_service.dart';

class AchievementsHubController extends GetxController {
  final ParentAcademicsService _academicsService =
      Get.find<ParentAcademicsService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final selectedTab = 'academic'.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final academicAchievements = <Map<String, String>>[].obs;
  final competitionCertificates = <Map<String, String>>[].obs;
  final activityRecords = <Map<String, String>>[].obs;
  final digitalCertificates = <Map<String, String>>[].obs;

  Worker? _childWorker;

  @override
  void onInit() {
    super.onInit();
    _childWorker = ever<String?>(
      _parentContext.selectedChildId,
      (_) => loadAchievements(),
    );
    loadAchievements();
  }

  @override
  void onClose() {
    _childWorker?.dispose();
    super.onClose();
  }

  void changeTab(String tab) => selectedTab.value = tab;

  Future<void> loadAchievements() async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _academicsService.getAchievements(
        childId: _parentContext.selectedChildId.value,
      );
      academicAchievements.assignAll(
        _mapStringList(data['academicAchievements']),
      );
      competitionCertificates.assignAll(
        _mapStringList(data['competitionCertificates']),
      );
      activityRecords.assignAll(_mapStringList(data['activityRecords']));
      digitalCertificates.assignAll(
        _mapStringList(data['digitalCertificates']),
      );
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      academicAchievements.clear();
      competitionCertificates.clear();
      activityRecords.clear();
      digitalCertificates.clear();
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, String>> _mapStringList(dynamic raw) {
    if (raw is! List) return const <Map<String, String>>[];
    return raw.whereType<Map>().map((e) {
      final m = Map<String, dynamic>.from(e);
      return m.map(
        (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
      );
    }).toList();
  }
}
