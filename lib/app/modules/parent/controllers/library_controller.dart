import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LibraryController extends GetxController {
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

  void search(String query) => searchQuery.value = query;
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
