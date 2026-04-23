import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/staff/staff_portal_store_service.dart';
import 'package:erp_frontend/common/services/staff/staff_service.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';

class StaffAttendanceLeaveController extends GetxController {
  StaffAttendanceLeaveController(
    this._adminService,
    this._staffService,
    this._store,
  );

  final AdminService _adminService;
  final StaffService _staffService;
  final StaffPortalStoreService _store;

  final activeTab = 0.obs;

  final attendanceRecords = <Map<String, String>>[].obs;
  final leaveApplications = <Map<String, String>>[].obs;
  final approvalQueue = <Map<String, String>>[].obs;
  final lateArrivals = <Map<String, String>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
    final args = Get.arguments;
    if (args is Map && args['tab'] == 'reports') {
      activeTab.value = 3;
    }
  }

  void setTab(int index) {
    if (index < 0 || index > 4) return;
    activeTab.value = index;
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final remoteAttendance = await _loadRemoteAttendance();
      final manualAttendance = await _loadCollection('manualAttendanceRecords');
      attendanceRecords.assignAll(_mergeRows(remoteAttendance, manualAttendance));

      leaveApplications.assignAll(await _loadCollection('leaveApplications'));
      approvalQueue.assignAll(List<Map<String, String>>.from(leaveApplications));

      final lateOverrides = await _loadCollection('lateArrivals');
      lateArrivals.assignAll(_buildLateArrivals(attendanceRecords, lateOverrides));
    } catch (_) {
      attendanceRecords.assignAll(await _loadCollection('manualAttendanceRecords'));
      leaveApplications.assignAll(await _loadCollection('leaveApplications'));
      approvalQueue.assignAll(List<Map<String, String>>.from(leaveApplications));
      lateArrivals.assignAll(await _loadCollection('lateArrivals'));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAttendance({
    required String date,
    required String checkIn,
    required String status,
  }) async {
    try {
      final profile = await _staffService.getProfile();
      final staffId = profile['staffId']?.toString().trim() ?? '';
      if (staffId.isNotEmpty) {
        try {
          await _adminService.markAttendanceBulk(
            type: 'staff',
            date: date.trim(),
            records: [
              {
                'staffId': staffId,
                'status': _backendStatus(status),
              },
            ],
          );
        } catch (_) {
          // Keep the local persisted record even when the lightweight
          // mark action cannot fully map to the backend schema.
        }
      }
    } catch (_) {}
    await _store.upsertCollectionItem(
      moduleKey: 'attendanceLeave',
      collectionKey: 'manualAttendanceRecords',
      id: date.trim(),
      payload: {
        'date': date.trim(),
        'checkIn': checkIn.trim(),
        'status': status.trim(),
      },
    );
    await loadData();
    AppToast.show('Attendance marked');
  }

  Future<void> submitLeave({
    required String type,
    required String fromDate,
    required String toDate,
    required String reason,
  }) async {
    if (reason.trim().isEmpty) {
      AppToast.show('Reason is required');
      return;
    }
    await _store.upsertCollectionItem(
      moduleKey: 'attendanceLeave',
      collectionKey: 'leaveApplications',
      payload: {
        'type': type.trim(),
        'fromDate': fromDate.trim(),
        'toDate': toDate.trim(),
        'reason': reason.trim(),
        'status': 'PENDING',
      },
    );
    await loadData();
    AppToast.show('Leave application submitted');
  }

  Future<void> decideLeave(String id, String decision) async {
    final current = await _loadCollection('leaveApplications');
    final next = current
        .map((row) => row['id'] == id ? {...row, 'status': decision} : row)
        .toList(growable: false);
    await _store.saveCollection(
      'attendanceLeave',
      'leaveApplications',
      next.map((row) => <String, dynamic>{...row}).toList(growable: false),
    );
    await loadData();
    AppToast.show('Leave marked $decision');
  }

  Future<void> closeLateEntry(String id) async {
    final current = lateArrivals
        .map((row) => row['id'] == id ? {...row, 'status': 'RESOLVED'} : row)
        .toList(growable: false);
    await _store.saveCollection(
      'attendanceLeave',
      'lateArrivals',
      current.map((row) => <String, dynamic>{...row}).toList(growable: false),
    );
    await loadData();
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

  Future<List<Map<String, String>>> _loadRemoteAttendance() async {
    final profile = await _staffService.getProfile();
    final data = await _adminService.getAttendanceRecords(
      type: 'staff',
      limit: 200,
    );
    final rawItems = data['items'];
    if (rawItems is! List) {
      return const <Map<String, String>>[];
    }
    return rawItems.whereType<Map>().map((row) {
      final item = row.cast<String, dynamic>();
      final staff = item['staff'] as Map<String, dynamic>? ?? const {};
      if (!_matchesCurrentStaff(profile, item, staff)) {
        return <String, String>{};
      }
      return <String, String>{
        'id': _firstText([item['id'], item['date'], staff['id'], item['staffId']]),
        'date': _firstText([item['date'], item['createdAt']]),
        'checkIn': _firstText([
          item['checkIn'],
          item['inTime'],
          item['checkInTime'],
        ]),
        'status': _uiStatus(_firstText([item['status']])),
      };
    }).where((row) => row.isNotEmpty).toList(growable: false);
  }

  Future<List<Map<String, String>>> _loadCollection(String key) async {
    final rows = await _store.readCollection('attendanceLeave', key);
    return rows.map((row) {
      return row.map(
        (entryKey, value) => MapEntry(entryKey, value?.toString() ?? ''),
      );
    }).toList(growable: false);
  }

  List<Map<String, String>> _mergeRows(
    List<Map<String, String>> remote,
    List<Map<String, String>> local,
  ) {
    final merged = <String, Map<String, String>>{};
    for (final item in remote) {
      final id = item['id'] ?? '';
      if (id.isNotEmpty) {
        merged[id] = item;
      }
    }
    for (final item in local) {
      final id = item['id'] ?? '';
      if (id.isNotEmpty) {
        merged[id] = item;
      } else {
        merged['local-${merged.length}'] = item;
      }
    }
    final rows = merged.values.toList(growable: false);
    rows.sort((a, b) => (b['date'] ?? '').compareTo(a['date'] ?? ''));
    return rows;
  }

  List<Map<String, String>> _buildLateArrivals(
    List<Map<String, String>> source,
    List<Map<String, String>> overrides,
  ) {
    final mapped = <String, Map<String, String>>{};
    for (final row in source.where((item) => item['status'] == 'LATE')) {
      final id = row['id'] ?? '';
      if (id.isEmpty) continue;
      mapped[id] = {
        'id': id,
        'date': row['date'] ?? '',
        'checkIn': row['checkIn'] ?? '',
        'minutesLate': '15',
        'status': 'OPEN',
      };
    }
    for (final row in overrides) {
      final id = row['id'] ?? '';
      if (id.isEmpty) continue;
      mapped[id] = {
        ...?mapped[id],
        ...row,
      };
    }
    return mapped.values.toList(growable: false);
  }

  String _backendStatus(String value) {
    switch (value.trim().toUpperCase()) {
      case 'LATE':
        return 'LATE';
      case 'ABSENT':
        return 'ABSENT';
      default:
        return 'PRESENT';
    }
  }

  String _uiStatus(String value) {
    final normalized = value.trim().toUpperCase();
    if (normalized == 'P' || normalized == 'PRESENT') return 'PRESENT';
    if (normalized == 'L' || normalized == 'LATE') return 'LATE';
    if (normalized == 'A' || normalized == 'ABSENT') return 'ABSENT';
    return normalized.isEmpty ? 'PRESENT' : normalized;
  }

  String _firstText(List<dynamic> values) {
    for (final value in values) {
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  bool _matchesCurrentStaff(
    Map<String, dynamic> profile,
    Map<String, dynamic> item,
    Map<String, dynamic> staff,
  ) {
    final currentKeys = <String>{
      ..._normalizedKeys([
        profile['staffId'],
        profile['id'],
        profile['employeeCode'],
        profile['email'],
        profile['name'],
      ]),
    };
    if (currentKeys.isEmpty) {
      return true;
    }

    final rowKeys = <String>{
      ..._normalizedKeys([
        item['staffId'],
        item['employeeCode'],
        staff['id'],
        staff['staffId'],
        staff['employeeCode'],
        staff['email'],
        staff['fullName'],
        staff['name'],
      ]),
    };
    if (rowKeys.isEmpty) {
      return false;
    }
    return rowKeys.any(currentKeys.contains);
  }

  Iterable<String> _normalizedKeys(List<dynamic> values) sync* {
    for (final value in values) {
      final normalized = value?.toString().trim().toLowerCase() ?? '';
      if (normalized.isNotEmpty) {
        yield normalized;
      }
    }
  }
}
