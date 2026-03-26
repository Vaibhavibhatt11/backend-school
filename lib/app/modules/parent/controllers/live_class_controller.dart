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
    subject.value = Get.arguments['subject'] ?? 'Physics';
    loadLiveClasses();
  }

  final selectedDate = DateTime.now().obs;
  final liveClass =
      {
        'subject': 'Physics',
        'title': 'Quantum Mechanics & Particle Theory',
        'teacher': 'Dr. Robert Chen',
        'time': '09:00 AM - 10:30 AM',
        'participants': 24,
      }.obs;

  final upcomingClasses =
      [
        {
          'time': '11:00 AM',
          'subject': 'Advanced Mathematics',
          'teacher': 'Prof. Alan Turing',
          'room': 'Room 402',
        },
        {
          'time': '01:30 PM',
          'subject': 'English Literature',
          'teacher': 'Sarah Jenkins',
          'room': 'Room 101',
        },
        {
          'time': '03:00 PM',
          'subject': 'Computer Science',
          'teacher': 'Marco Rossi',
          'room': 'Lab A',
        },
      ].obs;

  Future<void> loadLiveClasses() async {
    isLoading.value = true;
    try {
      final data = await _academicsService.getLiveClasses(
        childId: _parentContext.selectedChildId.value,
      );
      final current = data['liveClass'];
      if (current is Map) {
        liveClass.assignAll(Map<String, Object>.from(current));
      }
      final upcoming = data['upcomingClasses'];
      if (upcoming is List) {
        upcomingClasses.assignAll(
          upcoming.whereType<Map>().map(
            (e) => e.map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')),
          ),
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
