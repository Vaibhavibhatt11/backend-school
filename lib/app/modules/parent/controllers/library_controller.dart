import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import '../../../../common/services/parent/parent_api_utils.dart';
import '../../../../common/services/parent/parent_context_service.dart';
import '../../../../common/services/parent/parent_profile_service.dart';

class LibraryController extends GetxController {
  final ParentProfileService _profileService = Get.find<ParentProfileService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final selectedTab = 0.obs; // 0: Browse, 1: My History
  final recommendedBooks = <Map<String, dynamic>>[].obs;

  final activeLoans = <Map<String, dynamic>>[].obs;
  Worker? _childWorker;

  @override
  void onInit() {
    super.onInit();
    _childWorker = ever<String?>(
      _parentContext.selectedChildId,
      (_) => loadLibrary(),
    );
    loadLibrary();
  }

  Future<void> loadLibrary() async {
    isLoading.value = true;
    try {
      final data = await _profileService.getLibrary(
        childId: _parentContext.selectedChildId.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );
      final recommended = data['recommendedBooks'];
      if (recommended is List) {
        recommendedBooks.assignAll(
          recommended.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
        );
      }
      final loans = data['activeLoans'];
      if (loans is List) {
        activeLoans.assignAll(
          loans.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
        );
      }
    } catch (e) {
      recommendedBooks.clear();
      activeLoans.clear();
      AppToast.show(dioOrApiErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  void search(String query) {
    searchQuery.value = query;
    loadLibrary();
  }
  void scanQR() => AppToast.show('QR scanner opened');
  void viewBookDetails(String title) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: const Text('Book details will be shown here.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  void onClose() {
    _childWorker?.dispose();
    super.onClose();
  }
}
