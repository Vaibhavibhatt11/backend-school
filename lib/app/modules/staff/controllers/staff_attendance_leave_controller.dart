import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';

class StaffAttendanceLeaveController extends GetxController {
  final activeTab = 0.obs;

  final attendanceRecords = <Map<String, String>>[].obs;
  final leaveApplications = <Map<String, String>>[].obs;
  final approvalQueue = <Map<String, String>>[].obs;
  final lateArrivals = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _seedData();
    final args = Get.arguments;
    if (args is Map && args['tab'] == 'reports') {
      activeTab.value = 3;
    }
  }

  void setTab(int index) {
    if (index < 0 || index > 4) return;
    activeTab.value = index;
  }

  void markAttendance({
    required String date,
    required String checkIn,
    required String status,
  }) {
    attendanceRecords.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'date': date,
      'checkIn': checkIn,
      'status': status,
    });
    if (status == 'LATE') {
      lateArrivals.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'date': date,
        'checkIn': checkIn,
        'minutesLate': '15',
        'status': 'OPEN',
      });
    }
    AppToast.show('Attendance marked');
  }

  void submitLeave({
    required String type,
    required String fromDate,
    required String toDate,
    required String reason,
  }) {
    if (reason.trim().isEmpty) {
      AppToast.show('Reason is required');
      return;
    }
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final row = {
      'id': id,
      'type': type,
      'fromDate': fromDate,
      'toDate': toDate,
      'reason': reason,
      'status': 'PENDING',
    };
    leaveApplications.insert(0, row);
    approvalQueue.insert(0, row);
    AppToast.show('Leave application submitted');
  }

  void decideLeave(String id, String decision) {
    approvalQueue.assignAll(
      approvalQueue.map((row) {
        if (row['id'] != id) return row;
        return {...row, 'status': decision};
      }),
    );
    leaveApplications.assignAll(
      leaveApplications.map((row) {
        if (row['id'] != id) return row;
        return {...row, 'status': decision};
      }),
    );
    AppToast.show('Leave marked $decision');
  }

  void closeLateEntry(String id) {
    lateArrivals.assignAll(
      lateArrivals.map((row) {
        if (row['id'] != id) return row;
        return {...row, 'status': 'RESOLVED'};
      }),
    );
    AppToast.show('Late arrival resolved');
  }

  Map<String, int> reportMetrics() {
    final total = attendanceRecords.length;
    final present = attendanceRecords.where((e) => e['status'] == 'PRESENT').length;
    final late = attendanceRecords.where((e) => e['status'] == 'LATE').length;
    final leaveApproved = leaveApplications.where((e) => e['status'] == 'APPROVED').length;
    final leavePending = leaveApplications.where((e) => e['status'] == 'PENDING').length;
    return {
      'total': total,
      'present': present,
      'late': late,
      'leaveApproved': leaveApproved,
      'leavePending': leavePending,
    };
  }

  void _seedData() {
    if (attendanceRecords.isNotEmpty) return;
    attendanceRecords.assignAll([
      {
        'id': 'att-1',
        'date': '2026-04-20',
        'checkIn': '08:47',
        'status': 'PRESENT',
      },
      {
        'id': 'att-2',
        'date': '2026-04-19',
        'checkIn': '09:18',
        'status': 'LATE',
      },
    ]);
    leaveApplications.assignAll([
      {
        'id': 'lv-1',
        'type': 'Casual',
        'fromDate': '2026-04-24',
        'toDate': '2026-04-24',
        'reason': 'Medical appointment',
        'status': 'PENDING',
      },
    ]);
    approvalQueue.assignAll(List<Map<String, String>>.from(leaveApplications));
    lateArrivals.assignAll([
      {
        'id': 'late-1',
        'date': '2026-04-19',
        'checkIn': '09:18',
        'minutesLate': '18',
        'status': 'OPEN',
      },
    ]);
  }
}
