import 'package:get/get.dart';

class AuditLog {
  final String action;
  final String admin;
  final String time;
  final String? ip;
  final String? details;
  final String? type; // login, fee, config, etc.
  final bool isCritical;
  AuditLog({
    required this.action,
    required this.admin,
    required this.time,
    this.ip,
    this.details,
    this.type,
    this.isCritical = false,
  });
}

class AdminAuditLogsController extends GetxController {
  final searchQuery = ''.obs;
  final selectedFilter = 'All Logs'.obs;

  final logsToday = <AuditLog>[
    AuditLog(
      action: 'Successful Login',
      admin: 'Sarah Jenkins',
      time: '10:45 AM',
      ip: '192.168.1.45',
      details: 'iOS App',
    ),
    AuditLog(
      action: 'Fee Structure Modified',
      admin: 'Robert Chen',
      time: '09:12 AM',
      details: 'Changed "Lab Fees" from \$120.00 to \$150.00 for Grade 10-B.',
    ),
    AuditLog(
      action: 'System Permission Update',
      admin: 'Principal Office',
      time: '08:30 AM',
      isCritical: true,
    ),
  ];

  final logsYesterday = <AuditLog>[
    AuditLog(
      action: 'Failed Login Attempt',
      admin: 'm_wilson_admin',
      time: '11:20 PM',
      details: 'Invalid password entered 3 times. Account temporarily locked.',
    ),
    AuditLog(
      action: 'New Announcement Published',
      admin: 'Sarah Jenkins',
      time: '04:15 PM',
      details: 'Subject: "Annual Sports Day Schedule Update"',
    ),
  ];

  void onSearch(String value) => searchQuery.value = value;

  void onFilter(String filter) => selectedFilter.value = filter;

  void onLogTap(AuditLog log) {
    Get.snackbar('Audit Log', '${log.action} by ${log.admin}');
  }
}
