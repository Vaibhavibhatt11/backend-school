import 'package:get/get.dart';

class StaffReportsController extends GetxController {
  final reportTiles = <Map<String, String>>[
    {'title': 'Academic Reports', 'value': '12 pending review'},
    {'title': 'Attendance Reports', 'value': '94% class average'},
    {'title': 'Staff Productivity', 'value': '8 tasks completed today'},
    {'title': 'Student Progress', 'value': '16 students need follow-up'},
  ].obs;
}

