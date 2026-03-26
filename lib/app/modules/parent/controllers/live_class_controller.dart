import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/services/parent/parent_academics_service.dart';
import '../../../../common/services/parent/parent_context_service.dart';

class LiveClassController extends GetxController {
  final ParentAcademicsService _academicsService = Get.find<ParentAcademicsService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final isLoading = false.obs;
  final subject = ''.obs;
  @override
  void onInit() {
    super.onInit();
    subject.value = Get.arguments['subject'] ?? '';
    loadLiveClasses();
  }

  final selectedDate = DateTime.now().obs;
  final liveClass = <String, dynamic>{}.obs;

  final upcomingClasses = <Map<String, dynamic>>[].obs;

  Future<void> loadLiveClasses() async {
    isLoading.value = true;
    try {
      final data = await _academicsService.getLiveClasses(
        childId: _parentContext.selectedChildId.value,
      );
      final current = data['liveClass'];
      if (current is Map) {
        liveClass.assignAll(Map<String, dynamic>.from(current));
      }
      final upcoming = data['upcomingClasses'];
      if (upcoming is List) {
        upcomingClasses.assignAll(
          upcoming.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void joinClass() {
    Get.dialog(
      AlertDialog(
        title: const Text('Join Class'),
        content: Text('Joining ${subject.value}...'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('OK')),
        ],
      ),
    );
  }
}
