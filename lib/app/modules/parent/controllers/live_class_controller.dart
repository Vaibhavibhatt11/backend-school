import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LiveClassController extends GetxController {
  final subject = ''.obs;
  @override
  void onInit() {
    super.onInit();
    subject.value = Get.arguments['subject'] ?? 'Physics';
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
