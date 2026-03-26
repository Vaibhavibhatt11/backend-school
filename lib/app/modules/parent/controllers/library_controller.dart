import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/services/parent/parent_context_service.dart';
import '../../../../common/services/parent/parent_profile_service.dart';

class LibraryController extends GetxController {
  final ParentProfileService _profileService = Get.find<ParentProfileService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final selectedTab = 0.obs; // 0: Browse, 1: My History
  final recommendedBooks =
      [
        {
          'title': 'Modern Poetry',
          'author': 'Rupi Kaur',
          'cover': 'poetry',
          'new': false,
        },
        {
          'title': 'Classical History',
          'author': 'S. Green',
          'cover': 'history',
          'new': true,
        },
        {
          'title': 'Quantum Physics',
          'author': 'Neil Bohr',
          'cover': 'physics',
          'new': false,
        },
      ].obs;

  final activeLoans =
      [
        {
          'title': 'The Great Gatsby',
          'author': 'F. Scott Fitzgerald',
          'due': '3 days',
          'status': 'On Time',
        },
        {
          'title': 'Organic Chemistry',
          'author': 'Dr. Jonathan Lee',
          'due': 'Overdue by 1 day',
          'status': 'Action Required',
        },
      ].obs;

  @override
  void onInit() {
    super.onInit();
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
          recommended.whereType<Map>().map((e) => Map<String, Object>.from(e)),
        );
      }
      final loans = data['activeLoans'];
      if (loans is List) {
        activeLoans.assignAll(
          loans.whereType<Map>().map(
            (e) => e.map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')),
          ),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void search(String query) {
    searchQuery.value = query;
    loadLibrary();
  }
  void scanQR() => Get.snackbar('Scan', 'QR scanner opened');
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
}
