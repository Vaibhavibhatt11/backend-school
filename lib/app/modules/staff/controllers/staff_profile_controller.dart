import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/services/staff/staff_service.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';

class StaffProfileController extends GetxController {
  StaffProfileController(this._staffService);

  final StaffService _staffService;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final name = ''.obs;
  final department = ''.obs;
  final qualification = ''.obs;
  final experience = ''.obs;
  final contact = ''.obs;
  final email = ''.obs;
  final documents = <String>[].obs;
  final documentRows = <Map<String, String>>[].obs;
  final staffId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _staffService.getProfile();
      name.value = (data['name'] ?? '').toString();
      department.value = (data['department'] ?? '').toString();
      qualification.value = (data['qualification'] ?? '').toString();
      experience.value = (data['experience'] ?? '').toString();
      contact.value = (data['contact'] ?? '').toString();
      email.value = (data['email'] ?? '').toString();
      staffId.value = (data['staffId'] ?? '').toString();
      final rawDocs = data['documents'];
      if (rawDocs is List) {
        documents.assignAll(rawDocs.map((e) => e.toString()));
      } else {
        documents.clear();
      }
      documentRows.clear();
      final rows = data['documentRows'];
      if (rows is List) {
        for (final e in rows) {
          if (e is Map) {
            documentRows.add({
              'id': (e['id'] ?? '').toString(),
              'name': (e['name'] ?? '').toString(),
              'url': (e['url'] ?? '').toString(),
              'type': (e['type'] ?? '').toString(),
            });
          }
        }
      }
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      AppToast.show(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }
}

