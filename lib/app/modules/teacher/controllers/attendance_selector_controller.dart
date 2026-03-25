import 'package:get/get.dart';

class AttendanceSelectorController extends GetxController {
  var selectedTabIndex = 0.obs;

  final pendingClasses = [
    {
      'title': 'Grade 10-A',
      'subtitle': 'Mathematics • Room 302',
      'time': '08:30 AM — 09:30 AM',
    },
    {
      'title': 'Grade 11-B',
      'subtitle': 'Physics • Lab 01',
      'time': '10:15 AM — 11:15 AM',
    },
    {
      'title': 'Grade 9-A',
      'subtitle': 'Geometry • Room 204',
      'time': '11:30 AM — 12:30 PM',
    },
  ];
}
