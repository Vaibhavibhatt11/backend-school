import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/services/auth_service.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/services/staff/staff_service.dart';
import 'package:get/get.dart';

class TeacherProfileController extends GetxController {
  final StaffService _staffService = Get.find<StaffService>();
  final AuthService _authService = Get.find<AuthService>();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final name = ''.obs;
  final staffId = ''.obs;
  final department = ''.obs;
  final qualification = ''.obs;
  final experience = ''.obs;
  final contact = ''.obs;
  final email = ''.obs;
  final documents = <String>[].obs;

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
      staffId.value = (data['staffId'] ?? '').toString();
      department.value = (data['department'] ?? '').toString();
      qualification.value = (data['qualification'] ?? '').toString();
      experience.value = (data['experience'] ?? '').toString();
      contact.value = (data['contact'] ?? '').toString();
      email.value = (data['email'] ?? '').toString();

      final rawDocuments = data['documents'];
      if (rawDocuments is List) {
        documents.assignAll(
          rawDocuments
              .map((item) => item.toString().trim())
              .where((item) => item.isNotEmpty),
        );
      } else {
        documents.clear();
      }
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      documents.clear();
    } finally {
      isLoading.value = false;
    }
  }

  String get initials {
    final parts = name.value
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .toList();
    if (parts.isEmpty) {
      return 'TR';
    }
    return parts.join();
  }

  Future<void> logout() async {
    await _authService.logout();
    Get.offAllNamed(AppRoutes.LOGIN);
  }
}
