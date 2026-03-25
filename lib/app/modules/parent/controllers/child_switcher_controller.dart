import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/app_storage.dart';

class ChildSwitcherController extends GetxController {
  final _storage = AppStorage();
  final children =
      [
        {
          'name': 'Alex Johnson',
          'grade': 'Grade 4-B',
          'id': '2024098',
          'active': true,
        },
        {
          'name': 'Mia Johnson',
          'grade': 'Grade 7-A',
          'id': '2021142',
          'active': false,
        },
        {
          'name': 'Ryan Johnson',
          'grade': 'Kindergarten',
          'id': '2024551',
          'active': false,
        },
      ].obs;

  void selectChild(int index) {
    // In real app, update active child in storage
    Get.back();
    Get.snackbar('Child Switched', 'Now viewing ${children[index]['name']}');
  }

  void linkAnotherChild() {
    Get.dialog(
      AlertDialog(
        title: const Text('Link Another Child'),
        content: const Text('Feature coming soon.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('OK')),
        ],
      ),
    );
  }
}
