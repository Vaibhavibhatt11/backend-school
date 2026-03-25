import 'package:get/get.dart';

class Students {
  final String name;
  final String rollNo;
  final String imageUrl;
  RxString status; // 'P', 'A', 'L'

  Students({
    required this.name,
    required this.rollNo,
    required this.imageUrl,
    required String initialStatus,
  }) : status = RxString(initialStatus);
}

class MarkAttendanceController extends GetxController {
  final allStudents = <Students>[
    Students(
      name: 'Alex Johnson',
      rollNo: '10A01',
      imageUrl: '...',
      initialStatus: 'P',
    ),
    Students(
      name: 'Bella Thorne',
      rollNo: '10A02',
      imageUrl: '...',
      initialStatus: 'A',
    ),
    Students(
      name: 'Charlie Davis',
      rollNo: '10A03',
      imageUrl: '...',
      initialStatus: 'L',
    ),
    // ... more
  ];

  final filteredStudents = <Students>[].obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    filteredStudents.assignAll(allStudents);
    ever(searchQuery, _filter);
  }

  void _filter(String query) {
    if (query.isEmpty) {
      filteredStudents.assignAll(allStudents);
    } else {
      filteredStudents.assignAll(
        allStudents.where(
          (s) =>
              s.name.toLowerCase().contains(query.toLowerCase()) ||
              s.rollNo.toLowerCase().contains(query.toLowerCase()),
        ),
      );
    }
  }

  void updateStatus(Students student, String newStatus) {
    student.status.value = newStatus;
  }

  void markAllPresent() {
    for (var s in allStudents) {
      s.status.value = 'P';
    }
  }

  void submitAttendance() {
    // Process and save attendance
    Get.back();
    Get.snackbar('Success', 'Attendance submitted');
  }
}
