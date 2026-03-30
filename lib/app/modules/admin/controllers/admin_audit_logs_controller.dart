import 'package:get/get.dart';
import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';

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
  AdminAuditLogsController(this._adminService);

  final AdminService _adminService;
  final searchQuery = ''.obs;
  final selectedFilter = 'All Logs'.obs;
  final isLoading = false.obs;

  final logsToday = <AuditLog>[].obs;
  final logsYesterday = <AuditLog>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadLogs();
  }

  Future<void> loadLogs() async {
    isLoading.value = true;
    try {
      final data = await _adminService.getAuditLogs(page: 1, limit: 100);
      final rawItems = data['items'] ?? data['logs'] ?? data['records'];
      final items = rawItems is List
          ? rawItems.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
          : <Map<String, dynamic>>[];

      final today = <AuditLog>[];
      final yesterday = <AuditLog>[];
      final now = DateTime.now();
      final todayDate = DateTime(now.year, now.month, now.day);
      final yesterdayDate = todayDate.subtract(const Duration(days: 1));

      for (final item in items) {
        final createdAtRaw = item['createdAt']?.toString();
        final createdAt = DateTime.tryParse(createdAtRaw ?? '');
        final bucketDate = createdAt == null
            ? null
            : DateTime(createdAt.year, createdAt.month, createdAt.day);
        final log = AuditLog(
          action: item['action']?.toString() ?? 'Audit Event',
          admin: item['actorName']?.toString() ?? item['actorId']?.toString() ?? 'System',
          time: createdAtRaw ?? '-',
          ip: item['ip']?.toString(),
          details: item['details']?.toString(),
          type: item['type']?.toString(),
          isCritical: (item['severity']?.toString().toUpperCase() == 'CRITICAL'),
        );

        if (bucketDate == todayDate) {
          today.add(log);
        } else if (bucketDate == yesterdayDate) {
          yesterday.add(log);
        }
      }

      logsToday.assignAll(today);
      logsYesterday.assignAll(yesterday);
    } catch (e) {
      logsToday.clear();
      logsYesterday.clear();
      AppToast.show(dioOrApiErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  void onSearch(String value) => searchQuery.value = value;

  void onFilter(String filter) => selectedFilter.value = filter;

  void onLogTap(AuditLog log) {
    searchQuery.value = log.action;
  }
}
