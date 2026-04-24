import 'package:get/get.dart';
import '../../../common/api/api_client.dart';
import '../../../common/api/api_endpoints.dart';
import '../../../common/services/parent/parent_api_utils.dart';
import '../../../common/utils/app_toast.dart';
import 'models/study_material_models.dart';

class StudentStudyMaterialsController extends GetxController {
  StudentStudyMaterialsController() : _apiClient = Get.find<ApiClient>();

  final ApiClient _apiClient;

  final selectedCategory = StudyMaterialCategory.all.obs;
  final materials = <StudyMaterialItem>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadMaterials();
  }

  Future<void> loadMaterials({bool showErrors = false}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final res = await _apiClient.get(
        ApiEndpoints.schoolStudyMaterials,
        query: {'page': 1, 'limit': 200},
      );
      final payload = extractApiData(res.data, context: 'study materials');
      final items = payload['items'];
      if (items is! List) {
        materials.clear();
        return;
      }

      final next =
          items
              .whereType<Map>()
              .map(
                (item) =>
                    StudyMaterialItem.fromJson(item.cast<String, dynamic>()),
              )
              .where((item) => item.isPublished && item.url.trim().isNotEmpty)
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      materials.assignAll(next);
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      materials.clear();
      if (showErrors) {
        AppToast.show(errorMessage.value);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void setCategory(StudyMaterialCategory category) {
    selectedCategory.value = category;
  }

  void setSearchQuery(String value) {
    searchQuery.value = value.trim().toLowerCase();
  }

  List<StudyMaterialItem> get filteredMaterials {
    final category = selectedCategory.value;
    final query = searchQuery.value;
    return materials.where((item) {
      if (category != StudyMaterialCategory.all && item.category != category) {
        return false;
      }
      if (query.isEmpty) return true;
      final haystack =
          '${item.title} ${item.subject} ${item.classLabel} ${item.description} ${item.hostLabel}'
              .toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  int countForCategory(StudyMaterialCategory category) {
    if (category == StudyMaterialCategory.all) {
      return materials.length;
    }
    return materials.where((item) => item.category == category).length;
  }
}
