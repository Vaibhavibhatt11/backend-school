import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminTransportRouteRecord {
  const AdminTransportRouteRecord({
    required this.id,
    required this.name,
    required this.routeCode,
    required this.isActive,
  });

  final String id;
  final String name;
  final String routeCode;
  final bool isActive;

  factory AdminTransportRouteRecord.fromJson(Map<String, dynamic> json) {
    return AdminTransportRouteRecord(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      routeCode: json['routeCode']?.toString() ?? '',
      isActive: json['isActive'] != false,
    );
  }
}

class AdminTransportDriverRecord {
  const AdminTransportDriverRecord({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.licenseNo,
    required this.routeId,
    required this.routeName,
    required this.isActive,
  });

  final String id;
  final String fullName;
  final String phone;
  final String licenseNo;
  final String routeId;
  final String routeName;
  final bool isActive;

  factory AdminTransportDriverRecord.fromJson(Map<String, dynamic> json) {
    final route = json['route'] as Map?;
    final routeName = json['routeName']?.toString() ?? '';
    final nestedRouteName = route == null
        ? ''
        : [
            if ((route['name']?.toString() ?? '').isNotEmpty)
              route['name'].toString(),
            if ((route['routeCode']?.toString() ?? '').isNotEmpty)
              '(${route['routeCode']})',
          ].join(' ');
    return AdminTransportDriverRecord(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      licenseNo: json['licenseNo']?.toString() ?? '',
      routeId: json['routeId']?.toString() ?? '',
      routeName: routeName.isNotEmpty ? routeName : nestedRouteName,
      isActive: json['isActive'] != false,
    );
  }
}

class AdminTransportAllocationRecord {
  const AdminTransportAllocationRecord({
    required this.id,
    required this.studentId,
    required this.routeId,
    required this.studentLabel,
    required this.routeLabel,
    required this.stopName,
    required this.feeAmount,
  });

  final String id;
  final String studentId;
  final String routeId;
  final String studentLabel;
  final String routeLabel;
  final String stopName;
  final double? feeAmount;

  String get routeName => routeLabel;

  factory AdminTransportAllocationRecord.fromJson(Map<String, dynamic> json) {
    final student =
        json['student'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final route =
        json['route'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final studentLabel =
        '${student['firstName']?.toString() ?? ''} ${student['lastName']?.toString() ?? ''} (${student['admissionNo']?.toString() ?? ''})'
            .trim();
    final routeLabel = json['routeLabel']?.toString().isNotEmpty == true
        ? json['routeLabel'].toString()
        : json['routeName']?.toString().isNotEmpty == true
        ? json['routeName'].toString()
        : '${route['name']?.toString() ?? ''} (${route['routeCode']?.toString() ?? ''})'
              .trim();
    return AdminTransportAllocationRecord(
      id: json['id']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? '',
      routeId: json['routeId']?.toString() ?? '',
      studentLabel: studentLabel,
      routeLabel: routeLabel,
      stopName: json['stopName']?.toString() ?? '',
      feeAmount: (json['feeAmount'] as num?)?.toDouble(),
    );
  }
}

class AdminHostelRoomRecord {
  const AdminHostelRoomRecord({
    required this.id,
    required this.block,
    required this.roomNo,
    required this.capacity,
    required this.isActive,
  });

  final String id;
  final String block;
  final String roomNo;
  final int capacity;
  final bool isActive;

  String get label => '$block - $roomNo';

  factory AdminHostelRoomRecord.fromJson(Map<String, dynamic> json) {
    return AdminHostelRoomRecord(
      id: json['id']?.toString() ?? '',
      block: json['block']?.toString() ?? '',
      roomNo: json['roomNo']?.toString() ?? '',
      capacity: (json['capacity'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] != false,
    );
  }
}

class AdminHostelAllocationRecord {
  const AdminHostelAllocationRecord({
    required this.id,
    required this.studentId,
    required this.roomId,
    required this.studentLabel,
    required this.roomLabel,
    required this.fromDate,
    required this.toDate,
  });

  final String id;
  final String studentId;
  final String roomId;
  final String studentLabel;
  final String roomLabel;
  final DateTime? fromDate;
  final DateTime? toDate;

  factory AdminHostelAllocationRecord.fromJson(Map<String, dynamic> json) {
    final student =
        json['student'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final room =
        json['room'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final studentLabel =
        '${student['firstName']?.toString() ?? ''} ${student['lastName']?.toString() ?? ''} (${student['admissionNo']?.toString() ?? ''})'
            .trim();
    final roomLabel =
        '${room['block']?.toString() ?? ''} - ${room['roomNo']?.toString() ?? ''}'
            .trim();
    return AdminHostelAllocationRecord(
      id: json['id']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? '',
      roomId: json['roomId']?.toString() ?? '',
      studentLabel: studentLabel,
      roomLabel: roomLabel,
      fromDate: _opsDate(json['fromDate']),
      toDate: _opsDate(json['toDate']),
    );
  }
}

class AdminHostelAttendanceRecord {
  const AdminHostelAttendanceRecord({
    required this.id,
    required this.studentId,
    required this.status,
    required this.remark,
    required this.date,
  });

  final String id;
  final String studentId;
  final String status;
  final String remark;
  final DateTime? date;

  factory AdminHostelAttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AdminHostelAttendanceRecord(
      id: json['id']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      remark: json['remark']?.toString() ?? '',
      date: _opsDate(json['date']),
    );
  }
}

class AdminHostelVisitorRecord {
  const AdminHostelVisitorRecord({
    required this.id,
    required this.visitorName,
    required this.studentId,
    required this.purpose,
    required this.idProof,
    required this.inTime,
    required this.outTime,
  });

  final String id;
  final String visitorName;
  final String studentId;
  final String purpose;
  final String idProof;
  final DateTime? inTime;
  final DateTime? outTime;

  factory AdminHostelVisitorRecord.fromJson(Map<String, dynamic> json) {
    return AdminHostelVisitorRecord(
      id: json['id']?.toString() ?? '',
      visitorName: json['visitorName']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? '',
      purpose: json['purpose']?.toString() ?? '',
      idProof: json['idProof']?.toString() ?? '',
      inTime: _opsDate(json['inTime']),
      outTime: _opsDate(json['outTime']),
    );
  }
}

class AdminHostelFeeStructureRecord {
  const AdminHostelFeeStructureRecord({
    required this.id,
    required this.name,
    required this.amount,
    required this.frequency,
    required this.dueDay,
    required this.isActive,
  });

  final String id;
  final String name;
  final double amount;
  final String frequency;
  final int dueDay;
  final bool isActive;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'amount': amount,
    'frequency': frequency,
    'dueDay': dueDay,
    'isActive': isActive,
  };

  factory AdminHostelFeeStructureRecord.fromJson(Map<String, dynamic> json) {
    return AdminHostelFeeStructureRecord(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      frequency: json['frequency']?.toString() ?? 'MONTHLY',
      dueDay: (json['dueDay'] as num?)?.toInt() ?? 5,
      isActive: json['isActive'] != false,
    );
  }
}

class AdminHostelFeePaymentRecord {
  const AdminHostelFeePaymentRecord({
    required this.id,
    required this.studentId,
    required this.studentLabel,
    required this.structureId,
    required this.structureLabel,
    required this.amount,
    required this.paidOn,
    required this.status,
  });

  final String id;
  final String studentId;
  final String studentLabel;
  final String structureId;
  final String structureLabel;
  final double amount;
  final String paidOn;
  final String status;

  Map<String, dynamic> toJson() => {
    'id': id,
    'studentId': studentId,
    'studentLabel': studentLabel,
    'structureId': structureId,
    'structureLabel': structureLabel,
    'amount': amount,
    'paidOn': paidOn,
    'status': status,
  };

  factory AdminHostelFeePaymentRecord.fromJson(Map<String, dynamic> json) {
    return AdminHostelFeePaymentRecord(
      id: json['id']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? '',
      studentLabel: json['studentLabel']?.toString() ?? '',
      structureId: json['structureId']?.toString() ?? '',
      structureLabel: json['structureLabel']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      paidOn: json['paidOn']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PAID',
    );
  }
}

class AdminHostelComplaintRecord {
  const AdminHostelComplaintRecord({
    required this.id,
    required this.studentId,
    required this.studentLabel,
    required this.category,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.resolutionNote,
  });

  final String id;
  final String studentId;
  final String studentLabel;
  final String category;
  final String description;
  final String status;
  final String createdAt;
  final String resolutionNote;

  Map<String, dynamic> toJson() => {
    'id': id,
    'studentId': studentId,
    'studentLabel': studentLabel,
    'category': category,
    'description': description,
    'status': status,
    'createdAt': createdAt,
    'resolutionNote': resolutionNote,
  };

  factory AdminHostelComplaintRecord.fromJson(Map<String, dynamic> json) {
    return AdminHostelComplaintRecord(
      id: json['id']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? '',
      studentLabel: json['studentLabel']?.toString() ?? '',
      category: json['category']?.toString() ?? 'GENERAL',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'OPEN',
      createdAt: json['createdAt']?.toString() ?? '',
      resolutionNote: json['resolutionNote']?.toString() ?? '',
    );
  }
}

class AdminEventRecord {
  const AdminEventRecord({
    required this.id,
    required this.title,
    required this.eventType,
    required this.location,
    required this.isPublished,
    required this.registrationsCount,
    required this.startDate,
    required this.endDate,
  });

  final String id;
  final String title;
  final String eventType;
  final String location;
  final bool isPublished;
  final int registrationsCount;
  final DateTime? startDate;
  final DateTime? endDate;

  factory AdminEventRecord.fromJson(Map<String, dynamic> json) {
    final counts =
        json['_count'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    return AdminEventRecord(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      eventType: json['eventType']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      isPublished: json['isPublished'] == true,
      registrationsCount: (counts['registrations'] as num?)?.toInt() ?? 0,
      startDate: _opsDate(json['startDate']),
      endDate: _opsDate(json['endDate']),
    );
  }
}

class AdminEventRegistrationRecord {
  const AdminEventRegistrationRecord({
    required this.id,
    required this.eventId,
    required this.participantLabel,
    required this.email,
    required this.createdAt,
  });

  final String id;
  final String eventId;
  final String participantLabel;
  final String email;
  final String createdAt;

  factory AdminEventRegistrationRecord.fromJson(
    Map<String, dynamic> json, {
    required String eventId,
  }) {
    return AdminEventRegistrationRecord(
      id: json['id']?.toString() ?? '',
      eventId: eventId,
      participantLabel:
          json['email']?.toString() ??
          json['studentId']?.toString() ??
          json['userId']?.toString() ??
          'Registrant',
      email: json['email']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

class AdminEventGalleryRecord {
  const AdminEventGalleryRecord({
    required this.id,
    required this.eventId,
    required this.url,
    required this.caption,
    required this.createdAt,
  });

  final String id;
  final String eventId;
  final String url;
  final String caption;
  final String createdAt;

  factory AdminEventGalleryRecord.fromJson(
    Map<String, dynamic> json, {
    required String eventId,
  }) {
    return AdminEventGalleryRecord(
      id: json['id']?.toString() ?? '',
      eventId: eventId,
      url: json['url']?.toString() ?? '',
      caption: json['caption']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

class AdminCompetitionRecord {
  const AdminCompetitionRecord({
    required this.id,
    required this.title,
    required this.category,
    required this.eventId,
    required this.eventTitle,
    required this.status,
    required this.participantsCount,
  });

  final String id;
  final String title;
  final String category;
  final String eventId;
  final String eventTitle;
  final String status;
  final int participantsCount;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'eventId': eventId,
    'eventTitle': eventTitle,
    'status': status,
    'participantsCount': participantsCount,
  };

  factory AdminCompetitionRecord.fromJson(Map<String, dynamic> json) {
    return AdminCompetitionRecord(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      eventId: json['eventId']?.toString() ?? '',
      eventTitle: json['eventTitle']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PLANNED',
      participantsCount: (json['participantsCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class AdminInventoryItemRecord {
  const AdminInventoryItemRecord({
    required this.id,
    required this.sku,
    required this.name,
    required this.category,
    required this.qty,
    required this.unit,
    required this.lowStockThreshold,
    required this.isActive,
  });
  final String id;
  final String sku;
  final String name;
  final String category;
  final int qty;
  final String unit;
  final int lowStockThreshold;
  final bool isActive;
  bool get isLowStock => qty <= lowStockThreshold;

  factory AdminInventoryItemRecord.fromJson(Map<String, dynamic> json) {
    return AdminInventoryItemRecord(
      id: json['id']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      qty: (json['qty'] as num?)?.toInt() ?? 0,
      unit: json['unit']?.toString() ?? 'pcs',
      lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] != false,
    );
  }
}

class AdminInventoryTransactionRecord {
  const AdminInventoryTransactionRecord({
    required this.id,
    required this.itemName,
    required this.type,
    required this.qty,
    required this.note,
    required this.createdAt,
  });
  final String id;
  final String itemName;
  final String type;
  final int qty;
  final String note;
  final DateTime? createdAt;

  factory AdminInventoryTransactionRecord.fromJson(Map<String, dynamic> json) {
    final item =
        json['item'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    return AdminInventoryTransactionRecord(
      id: json['id']?.toString() ?? '',
      itemName: item['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      qty: (json['qty'] as num?)?.toInt() ?? 0,
      note: json['note']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}

class AdminOperationsController extends GetxController {
  AdminOperationsController(this._adminService);

  final AdminService _adminService;

  final currentTab = 0.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final transportRoutes = <AdminTransportRouteRecord>[].obs;
  final transportDrivers = <AdminTransportDriverRecord>[].obs;
  final transportAllocations = <AdminTransportAllocationRecord>[].obs;
  final hostelRooms = <AdminHostelRoomRecord>[].obs;
  final hostelAllocations = <AdminHostelAllocationRecord>[].obs;
  final hostelAttendance = <AdminHostelAttendanceRecord>[].obs;
  final hostelVisitors = <AdminHostelVisitorRecord>[].obs;
  final hostelAllocationStatusById = <String, String>{}.obs;
  final hostelVisitorCheckoutById = <String, String>{}.obs;
  final hostelFeeStructures = <AdminHostelFeeStructureRecord>[].obs;
  final hostelFeePayments = <AdminHostelFeePaymentRecord>[].obs;
  final hostelComplaints = <AdminHostelComplaintRecord>[].obs;
  final hostelAttendanceDate = ''.obs;
  final events = <AdminEventRecord>[].obs;
  final eventRegistrations = <AdminEventRegistrationRecord>[].obs;
  final eventGallery = <AdminEventGalleryRecord>[].obs;
  final competitions = <AdminCompetitionRecord>[].obs;
  final selectedEventId = ''.obs;
  final inventoryItems = <AdminInventoryItemRecord>[].obs;
  final inventoryTransactions = <AdminInventoryTransactionRecord>[].obs;
  final studentOptions = <Map<String, String>>[].obs;

  bool _hostelLoaded = false;
  bool _eventsLoaded = false;
  bool _transportLoaded = false;
  bool _inventoryLoaded = false;

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments as Map?)?.cast<String, dynamic>() ?? const {};
    currentTab.value = _opsTab((args['initialTab'] as num?)?.toInt() ?? 0);
    loadCurrentTab(force: true);
  }

  Future<void> changeTab(int index) async {
    currentTab.value = _opsTab(index);
    await loadCurrentTab();
  }

  Future<void> refreshCurrentTab() async {
    await loadCurrentTab(force: true);
  }

  Future<void> loadCurrentTab({bool force = false}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      if (force || studentOptions.isEmpty) {
        await loadStudentOptions();
      }
      if (currentTab.value == 0) {
        if (force || !_hostelLoaded) {
          await Future.wait([
            loadHostelRooms(),
            loadHostelAllocations(),
            loadHostelAttendance(),
            loadHostelVisitors(),
            loadHostelManagementSettings(),
          ]);
          _hostelLoaded = true;
        }
      } else if (currentTab.value == 1) {
        if (force || !_eventsLoaded) {
          await Future.wait([loadEvents(), loadEventsWorkbenchSettings()]);
          _eventsLoaded = true;
        }
      } else if (currentTab.value == 2) {
        if (force || !_transportLoaded) {
          await Future.wait([
            loadTransportRoutes(),
            loadTransportDrivers(),
            loadTransportAllocations(),
          ]);
          _transportLoaded = true;
        }
      } else {
        if (force || !_inventoryLoaded) {
          await Future.wait([
            loadInventoryItems(),
            loadInventoryTransactions(),
          ]);
          _inventoryLoaded = true;
        }
      }
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      AppToast.show(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadStudentOptions() async {
    try {
      final data = await _adminService.getStudents(
        page: 1,
        limit: 100,
        status: 'ACTIVE',
      );
      final rawItems = data['items'];
      if (rawItems is! List) {
        studentOptions.clear();
        return;
      }
      studentOptions.assignAll(
        rawItems
            .whereType<Map>()
            .map((item) {
              final json = item.cast<String, dynamic>();
              return <String, String>{
                'id': json['id']?.toString() ?? '',
                'label':
                    '${json['firstName']?.toString() ?? ''} ${json['lastName']?.toString() ?? ''} (${json['admissionNo']?.toString() ?? ''})'
                        .trim(),
              };
            })
            .where((item) => item['id']!.isNotEmpty)
            .toList(),
      );
    } catch (_) {
      studentOptions.clear();
    }
  }

  Future<void> loadTransportRoutes() async {
    final data = await _adminService.getTransportRoutes(page: 1, limit: 50);
    final rawItems = data['items'];
    if (rawItems is! List) {
      transportRoutes.clear();
      return;
    }
    transportRoutes.assignAll(
      rawItems
          .whereType<Map>()
          .map(
            (item) => AdminTransportRouteRecord.fromJson(
              item.cast<String, dynamic>(),
            ),
          )
          .toList(),
    );
  }

  Future<void> loadTransportDrivers() async {
    final data = await _adminService.getTransportDrivers(page: 1, limit: 50);
    final rawItems = data['items'];
    if (rawItems is! List) {
      transportDrivers.clear();
      return;
    }
    transportDrivers.assignAll(
      rawItems
          .whereType<Map>()
          .map(
            (item) => AdminTransportDriverRecord.fromJson(
              item.cast<String, dynamic>(),
            ),
          )
          .toList(),
    );
  }

  Future<void> loadTransportAllocations() async {
    final data = await _adminService.getTransportAllocations(
      page: 1,
      limit: 50,
    );
    final rawItems = data['items'];
    if (rawItems is! List) {
      transportAllocations.clear();
      return;
    }
    transportAllocations.assignAll(
      rawItems
          .whereType<Map>()
          .map(
            (item) => AdminTransportAllocationRecord.fromJson(
              item.cast<String, dynamic>(),
            ),
          )
          .toList(),
    );
  }

  Future<void> loadHostelRooms() async {
    final data = await _adminService.getHostelRooms();
    final rawItems = data['items'];
    if (rawItems is! List) {
      hostelRooms.clear();
      return;
    }
    hostelRooms.assignAll(
      rawItems
          .whereType<Map>()
          .map(
            (item) =>
                AdminHostelRoomRecord.fromJson(item.cast<String, dynamic>()),
          )
          .toList(),
    );
  }

  Future<void> loadHostelAllocations() async {
    final data = await _adminService.getHostelAllocations(page: 1, limit: 50);
    final rawItems = data['items'];
    if (rawItems is! List) {
      hostelAllocations.clear();
      return;
    }
    hostelAllocations.assignAll(
      rawItems
          .whereType<Map>()
          .map(
            (item) => AdminHostelAllocationRecord.fromJson(
              item.cast<String, dynamic>(),
            ),
          )
          .toList(),
    );
  }

  Future<void> loadHostelAttendance() async {
    final data = await _adminService.getHostelAttendance(
      date: hostelAttendanceDate.value.trim().isEmpty
          ? null
          : hostelAttendanceDate.value.trim(),
    );
    final rawItems = data['items'];
    if (rawItems is! List) {
      hostelAttendance.clear();
      return;
    }
    hostelAttendance.assignAll(
      rawItems
          .whereType<Map>()
          .map(
            (item) => AdminHostelAttendanceRecord.fromJson(
              item.cast<String, dynamic>(),
            ),
          )
          .toList(),
    );
  }

  Future<void> loadHostelVisitors() async {
    final data = await _adminService.getHostelVisitors(page: 1, limit: 50);
    final rawItems = data['items'];
    if (rawItems is! List) {
      hostelVisitors.clear();
      return;
    }
    hostelVisitors.assignAll(
      rawItems
          .whereType<Map>()
          .map(
            (item) =>
                AdminHostelVisitorRecord.fromJson(item.cast<String, dynamic>()),
          )
          .toList(),
    );
  }

  Future<void> loadHostelManagementSettings() async {
    final data = await _adminService.getSchoolSettings();
    final raw = data['hostelManagement'];
    if (raw is! Map) {
      hostelAllocationStatusById.clear();
      hostelVisitorCheckoutById.clear();
      hostelFeeStructures.clear();
      hostelFeePayments.clear();
      return;
    }
    final map = Map<String, dynamic>.from(raw);
    final allocationStatus = map['allocationStatusById'];
    hostelAllocationStatusById.assignAll(
      allocationStatus is Map
          ? Map<String, String>.fromEntries(
              allocationStatus.entries.map(
                (e) => MapEntry(e.key.toString(), e.value.toString()),
              ),
            )
          : const <String, String>{},
    );
    final visitorCheckout = map['visitorCheckoutById'];
    hostelVisitorCheckoutById.assignAll(
      visitorCheckout is Map
          ? Map<String, String>.fromEntries(
              visitorCheckout.entries.map(
                (e) => MapEntry(e.key.toString(), e.value.toString()),
              ),
            )
          : const <String, String>{},
    );
    hostelFeeStructures.assignAll(
      (map['feeStructures'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map(
            (item) => AdminHostelFeeStructureRecord.fromJson(
              item.cast<String, dynamic>(),
            ),
          )
          .toList(),
    );
    hostelFeePayments.assignAll(
      (map['feePayments'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map(
            (item) => AdminHostelFeePaymentRecord.fromJson(
              item.cast<String, dynamic>(),
            ),
          )
          .toList(),
    );
    hostelComplaints.assignAll(
      (map['complaints'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map(
            (item) => AdminHostelComplaintRecord.fromJson(
              item.cast<String, dynamic>(),
            ),
          )
          .toList(),
    );
  }

  Future<void> loadEvents() async {
    final data = await _adminService.getEvents(page: 1, limit: 50);
    final rawItems = data['items'];
    if (rawItems is! List) {
      events.clear();
      return;
    }
    events.assignAll(
      rawItems
          .whereType<Map>()
          .map(
            (item) => AdminEventRecord.fromJson(item.cast<String, dynamic>()),
          )
          .toList(),
    );
    if (selectedEventId.value.isEmpty && events.isNotEmpty) {
      selectedEventId.value = events.first.id;
    }
    if (selectedEventId.value.isNotEmpty) {
      await loadEventInsights(selectedEventId.value);
    }
  }

  Future<void> loadEventInsights(String eventId) async {
    if (eventId.trim().isEmpty) {
      eventRegistrations.clear();
      eventGallery.clear();
      return;
    }
    selectedEventId.value = eventId;
    try {
      final data = await _adminService.getEventById(eventId);
      final rawRegs = data['registrations'];
      final rawGallery = data['gallery'];
      if (rawRegs is List) {
        eventRegistrations.assignAll(
          rawRegs
              .whereType<Map>()
              .map(
                (item) => AdminEventRegistrationRecord.fromJson(
                  item.cast<String, dynamic>(),
                  eventId: eventId,
                ),
              )
              .toList(),
        );
      } else {
        eventRegistrations.clear();
      }
      if (rawGallery is List) {
        eventGallery.assignAll(
          rawGallery
              .whereType<Map>()
              .map(
                (item) => AdminEventGalleryRecord.fromJson(
                  item.cast<String, dynamic>(),
                  eventId: eventId,
                ),
              )
              .toList(),
        );
      } else {
        eventGallery.clear();
      }
    } catch (_) {
      eventRegistrations.clear();
      eventGallery.clear();
    }
  }

  Future<void> loadEventsWorkbenchSettings() async {
    final data = await _adminService.getSchoolSettings();
    final raw = data['eventsWorkbench'];
    if (raw is! Map) {
      competitions.clear();
      return;
    }
    final map = Map<String, dynamic>.from(raw);
    competitions.assignAll(
      (map['competitions'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map(
            (e) => AdminCompetitionRecord.fromJson(e.cast<String, dynamic>()),
          )
          .toList(),
    );
  }

  Future<void> loadInventoryItems() async {
    final data = await _adminService.getInventoryItems(page: 1, limit: 100);
    final rawItems = data['items'];
    if (rawItems is! List) {
      inventoryItems.clear();
      return;
    }
    inventoryItems.assignAll(
      rawItems
          .whereType<Map>()
          .map(
            (item) =>
                AdminInventoryItemRecord.fromJson(item.cast<String, dynamic>()),
          )
          .toList(),
    );
  }

  Future<void> loadInventoryTransactions() async {
    final data = await _adminService.getInventoryTransactions(
      page: 1,
      limit: 50,
    );
    final rawItems = data['items'];
    if (rawItems is! List) {
      inventoryTransactions.clear();
      return;
    }
    inventoryTransactions.assignAll(
      rawItems
          .whereType<Map>()
          .map(
            (item) => AdminInventoryTransactionRecord.fromJson(
              item.cast<String, dynamic>(),
            ),
          )
          .toList(),
    );
  }

  Future<void> openCompetitionDialog({AdminCompetitionRecord? existing}) async {
    if (events.isEmpty) {
      AppToast.show('Create an event first.');
      return;
    }
    String eventId = existing?.eventId.isNotEmpty == true
        ? existing!.eventId
        : events.first.id;
    final titleController = TextEditingController(text: existing?.title ?? '');
    final categoryController = TextEditingController(
      text: existing?.category ?? '',
    );
    String status = existing?.status ?? 'PLANNED';
    final participantsController = TextEditingController(
      text: (existing?.participantsCount ?? 0).toString(),
    );

    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              existing == null ? 'Add Competition' : 'Update Competition',
            ),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: eventId,
                      decoration: const InputDecoration(labelText: 'Event'),
                      items: events
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item.id,
                              child: Text(item.title),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => eventId = value ?? ''),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Competition title',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items:
                          const ['PLANNED', 'ONGOING', 'COMPLETED', 'CANCELLED']
                              .map(
                                (item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                ),
                              )
                              .toList(),
                      onChanged: (value) =>
                          setState(() => status = value ?? 'PLANNED'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: participantsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Participants count',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
    final participants = int.tryParse(participantsController.text.trim());
    if (ok != true ||
        eventId.isEmpty ||
        titleController.text.trim().isEmpty ||
        participants == null) {
      if (ok == true) {
        AppToast.show('Event, title, and participants are required.');
      }
      return;
    }
    final event = events.firstWhereOrNull((e) => e.id == eventId);
    competitions.assignAll([
      ...competitions.where((e) => e.id != existing?.id),
      AdminCompetitionRecord(
        id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: titleController.text.trim(),
        category: categoryController.text.trim(),
        eventId: eventId,
        eventTitle: event?.title ?? 'Event',
        status: status,
        participantsCount: participants,
      ),
    ]);
    await _saveEventsWorkbench();
    AppToast.show('Competition saved.');
  }

  Future<void> deleteCompetition(AdminCompetitionRecord item) async {
    if (!await _confirm('Delete ${item.title}?')) return;
    competitions.removeWhere((e) => e.id == item.id);
    await _saveEventsWorkbench();
    AppToast.show('Competition deleted.');
  }

  Future<void> _saveEventsWorkbench() async {
    await _adminService.patchSchoolSettings({
      'eventsWorkbench': {
        'competitions': competitions.map((e) => e.toJson()).toList(),
      },
    });
  }

  Future<void> openRouteDialog({AdminTransportRouteRecord? existing}) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final routeCodeController = TextEditingController(
      text: existing?.routeCode ?? '',
    );
    bool isActive = existing?.isActive ?? true;

    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(existing == null ? 'Add Route' : 'Edit Route'),
            content: SizedBox(
              width: 460,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Route name'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: routeCodeController,
                    decoration: const InputDecoration(labelText: 'Route code'),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: isActive,
                    onChanged: (value) => setState(() => isActive = value),
                    title: const Text('Active'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: Text(existing == null ? 'Create' : 'Save'),
              ),
            ],
          );
        },
      ),
    );
    if (ok != true ||
        nameController.text.trim().isEmpty ||
        routeCodeController.text.trim().isEmpty) {
      if (ok == true) AppToast.show('Route name and code are required.');
      return;
    }

    try {
      final payload = {
        'name': nameController.text.trim(),
        'routeCode': routeCodeController.text.trim(),
        'isActive': isActive,
      };
      if (existing == null) {
        await _adminService.createTransportRoute(payload);
        AppToast.show('Transport route created.');
      } else {
        await _adminService.updateTransportRoute(
          id: existing.id,
          payload: payload,
        );
        AppToast.show('Transport route updated.');
      }
      await Future.wait([loadTransportRoutes(), loadTransportAllocations()]);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> deleteRoute(AdminTransportRouteRecord item) async {
    if (!await _confirm('Delete ${item.name}?')) return;
    try {
      await _adminService.deleteTransportRoute(item.id);
      AppToast.show('Transport route deleted.');
      await Future.wait([loadTransportRoutes(), loadTransportAllocations()]);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> openDriverDialog() async {
    String routeId = transportRoutes.isNotEmpty ? transportRoutes.first.id : '';
    final fullNameController = TextEditingController();
    final phoneController = TextEditingController();
    final licenseController = TextEditingController();

    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Driver'),
            content: SizedBox(
              width: 460,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: fullNameController,
                      decoration: const InputDecoration(labelText: 'Full name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Phone'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: licenseController,
                      decoration: const InputDecoration(
                        labelText: 'License no',
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: routeId,
                      decoration: const InputDecoration(labelText: 'Route'),
                      items: transportRoutes
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item.id,
                              child: Text('${item.name} (${item.routeCode})'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => routeId = value ?? ''),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Create'),
              ),
            ],
          );
        },
      ),
    );
    if (ok != true || fullNameController.text.trim().isEmpty) {
      if (ok == true) AppToast.show('Driver name is required.');
      return;
    }

    try {
      await _adminService.createTransportDriver({
        'fullName': fullNameController.text.trim(),
        'phone': phoneController.text.trim().isEmpty
            ? null
            : phoneController.text.trim(),
        'licenseNo': licenseController.text.trim().isEmpty
            ? null
            : licenseController.text.trim(),
        'routeId': routeId.isEmpty ? null : routeId,
      });
      AppToast.show('Driver created.');
      await loadTransportDrivers();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> openTransportAllocationDialog({
    AdminTransportAllocationRecord? existing,
  }) async {
    if (studentOptions.isEmpty || transportRoutes.isEmpty) {
      AppToast.show('Add students and routes first.');
      return;
    }
    String studentId = existing?.studentId.isNotEmpty == true
        ? existing!.studentId
        : studentOptions.first['id']!;
    String routeId = existing?.routeId.isNotEmpty == true
        ? existing!.routeId
        : transportRoutes.first.id;
    final stopController = TextEditingController(
      text: existing?.stopName ?? '',
    );
    final feeController = TextEditingController(
      text: existing?.feeAmount?.toStringAsFixed(0) ?? '',
    );

    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              existing == null ? 'Add Transport Allocation' : 'Edit Allocation',
            ),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: studentId,
                      decoration: const InputDecoration(labelText: 'Student'),
                      items: studentOptions
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item['id'],
                              child: Text(item['label'] ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => studentId = value ?? ''),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: routeId,
                      decoration: const InputDecoration(labelText: 'Route'),
                      items: transportRoutes
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item.id,
                              child: Text('${item.name} (${item.routeCode})'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => routeId = value ?? ''),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: stopController,
                      decoration: const InputDecoration(labelText: 'Stop name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: feeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Fee amount',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: Text(existing == null ? 'Create' : 'Save'),
              ),
            ],
          );
        },
      ),
    );
    if (ok != true || studentId.isEmpty || routeId.isEmpty) return;

    try {
      final payload = {
        'studentId': studentId,
        'routeId': routeId,
        'stopName': stopController.text.trim().isEmpty
            ? null
            : stopController.text.trim(),
        'feeAmount': feeController.text.trim().isEmpty
            ? null
            : double.tryParse(feeController.text.trim()),
      };
      if (existing == null) {
        await _adminService.createTransportAllocation(payload);
        AppToast.show('Transport allocation created.');
      } else {
        await _adminService.updateTransportAllocation(
          id: existing.id,
          payload: payload,
        );
        AppToast.show('Transport allocation updated.');
      }
      await loadTransportAllocations();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> deleteTransportAllocation(
    AdminTransportAllocationRecord item,
  ) async {
    if (!await _confirm('Delete this transport allocation?')) return;
    try {
      await _adminService.deleteTransportAllocation(item.id);
      AppToast.show('Transport allocation deleted.');
      await loadTransportAllocations();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> openRoomDialog({AdminHostelRoomRecord? existing}) async {
    final blockController = TextEditingController(text: existing?.block ?? '');
    final roomNoController = TextEditingController(
      text: existing?.roomNo ?? '',
    );
    final capacityController = TextEditingController(
      text: existing?.capacity.toString() ?? '1',
    );
    bool isActive = existing?.isActive ?? true;

    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(existing == null ? 'Add Room' : 'Edit Room'),
            content: SizedBox(
              width: 460,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: blockController,
                    decoration: const InputDecoration(labelText: 'Block'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: roomNoController,
                    decoration: const InputDecoration(labelText: 'Room no'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: capacityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Capacity'),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: isActive,
                    onChanged: (value) => setState(() => isActive = value),
                    title: const Text('Active'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: Text(existing == null ? 'Create' : 'Save'),
              ),
            ],
          );
        },
      ),
    );
    final capacity = int.tryParse(capacityController.text.trim());
    if (ok != true ||
        blockController.text.trim().isEmpty ||
        roomNoController.text.trim().isEmpty ||
        capacity == null) {
      if (ok == true) {
        AppToast.show('Block, room no, and capacity are required.');
      }
      return;
    }

    try {
      final payload = {
        'block': blockController.text.trim(),
        'roomNo': roomNoController.text.trim(),
        'capacity': capacity,
        'isActive': isActive,
      };
      if (existing == null) {
        await _adminService.createHostelRoom(payload);
        AppToast.show('Hostel room created.');
      } else {
        await _adminService.updateHostelRoom(id: existing.id, payload: payload);
        AppToast.show('Hostel room updated.');
      }
      await Future.wait([loadHostelRooms(), loadHostelAllocations()]);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> deleteRoom(AdminHostelRoomRecord item) async {
    if (!await _confirm('Delete ${item.label}?')) return;
    try {
      await _adminService.deleteHostelRoom(item.id);
      AppToast.show('Hostel room deleted.');
      await Future.wait([loadHostelRooms(), loadHostelAllocations()]);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> openHostelAllocationDialog({
    AdminHostelAllocationRecord? existing,
  }) async {
    if (studentOptions.isEmpty || hostelRooms.isEmpty) {
      AppToast.show('Add students and rooms first.');
      return;
    }
    String studentId = existing?.studentId.isNotEmpty == true
        ? existing!.studentId
        : studentOptions.first['id']!;
    String roomId = existing?.roomId.isNotEmpty == true
        ? existing!.roomId
        : hostelRooms.first.id;
    final fromDateController = TextEditingController();
    final toDateController = TextEditingController();

    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              existing == null ? 'Allocate Hostel Room' : 'Reassign Room',
            ),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: studentId,
                      decoration: const InputDecoration(labelText: 'Student'),
                      items: studentOptions
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item['id'],
                              child: Text(item['label'] ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => studentId = value ?? ''),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: roomId,
                      decoration: const InputDecoration(labelText: 'Room'),
                      items: hostelRooms
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item.id,
                              child: Text(item.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => roomId = value ?? ''),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: fromDateController,
                      decoration: const InputDecoration(
                        labelText: 'From date',
                        helperText: 'YYYY-MM-DD',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: toDateController,
                      decoration: const InputDecoration(
                        labelText: 'To date',
                        helperText: 'YYYY-MM-DD',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: Text(existing == null ? 'Create' : 'Reassign'),
              ),
            ],
          );
        },
      ),
    );
    if (ok != true) return;
    try {
      await _adminService.createHostelAllocation({
        'studentId': studentId,
        'roomId': roomId,
        'fromDate': _opsInputDate(fromDateController.text)?.toIso8601String(),
        'toDate': _opsInputDate(toDateController.text)?.toIso8601String(),
      });
      if (existing != null) {
        await setHostelAllocationStatus(existing, 'VACATED');
      }
      AppToast.show(
        existing == null
            ? 'Hostel allocation created.'
            : 'Hostel allocation reassigned.',
      );
      await loadHostelAllocations();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> markHostelAttendance() async {
    if (studentOptions.isEmpty) {
      AppToast.show('No active students available.');
      return;
    }
    String studentId = studentOptions.first['id']!;
    String status = 'PRESENT';
    final dateController = TextEditingController();
    final remarkController = TextEditingController();

    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Mark Hostel Attendance'),
            content: SizedBox(
              width: 460,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: studentId,
                      decoration: const InputDecoration(labelText: 'Student'),
                      items: studentOptions
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item['id'],
                              child: Text(item['label'] ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => studentId = value ?? ''),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: const ['PRESENT', 'ABSENT', 'LEAVE']
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => status = value ?? 'PRESENT'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: dateController,
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        helperText: 'YYYY-MM-DD',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: remarkController,
                      decoration: const InputDecoration(labelText: 'Remark'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
    final date = _opsInputDate(dateController.text);
    if (ok != true || date == null) {
      if (ok == true) AppToast.show('Valid date is required.');
      return;
    }
    try {
      await _adminService.markHostelAttendance({
        'studentId': studentId,
        'date': date.toIso8601String(),
        'status': status,
        'remark': remarkController.text.trim().isEmpty
            ? null
            : remarkController.text.trim(),
      });
      AppToast.show('Hostel attendance saved.');
      await loadHostelAttendance();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> setHostelAttendanceDate(String value) async {
    hostelAttendanceDate.value = value;
    await loadHostelAttendance();
  }

  Future<void> openVisitorDialog() async {
    String studentId = studentOptions.isNotEmpty
        ? studentOptions.first['id']!
        : '';
    final visitorNameController = TextEditingController();
    final purposeController = TextEditingController();
    final idProofController = TextEditingController();

    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Visitor'),
            content: SizedBox(
              width: 460,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: visitorNameController,
                      decoration: const InputDecoration(
                        labelText: 'Visitor name',
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: studentId.isEmpty ? null : studentId,
                      decoration: const InputDecoration(labelText: 'Student'),
                      items: studentOptions
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item['id'],
                              child: Text(item['label'] ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => studentId = value ?? ''),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: purposeController,
                      decoration: const InputDecoration(labelText: 'Purpose'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: idProofController,
                      decoration: const InputDecoration(labelText: 'ID proof'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Create'),
              ),
            ],
          );
        },
      ),
    );
    if (ok != true || visitorNameController.text.trim().isEmpty) return;
    try {
      await _adminService.createHostelVisitor({
        'visitorName': visitorNameController.text.trim(),
        'studentId': studentId.isEmpty ? null : studentId,
        'purpose': purposeController.text.trim().isEmpty
            ? null
            : purposeController.text.trim(),
        'idProof': idProofController.text.trim().isEmpty
            ? null
            : idProofController.text.trim(),
      });
      AppToast.show('Visitor added.');
      await loadHostelVisitors();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  String allocationStatus(AdminHostelAllocationRecord item) =>
      hostelAllocationStatusById[item.id] ?? 'ACTIVE';

  Future<void> setHostelAllocationStatus(
    AdminHostelAllocationRecord item,
    String status,
  ) async {
    hostelAllocationStatusById[item.id] = status;
    await _saveHostelManagementSettings();
    AppToast.show('Allocation status updated.');
  }

  Future<void> markVisitorCheckout(AdminHostelVisitorRecord item) async {
    hostelVisitorCheckoutById[item.id] = DateTime.now()
        .toIso8601String()
        .substring(0, 16);
    await _saveHostelManagementSettings();
    AppToast.show('Visitor checkout marked.');
  }

  Future<void> openHostelFeeStructureDialog({
    AdminHostelFeeStructureRecord? existing,
  }) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final amountController = TextEditingController(
      text: existing?.amount.toStringAsFixed(0) ?? '',
    );
    String frequency = existing?.frequency ?? 'MONTHLY';
    final dueDayController = TextEditingController(
      text: (existing?.dueDay ?? 5).toString(),
    );
    bool isActive = existing?.isActive ?? true;

    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              existing == null ? 'Add Hostel Fee' : 'Edit Hostel Fee',
            ),
            content: SizedBox(
              width: 460,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Fee name'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Amount'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: frequency,
                    decoration: const InputDecoration(labelText: 'Frequency'),
                    items: const ['MONTHLY', 'QUARTERLY', 'YEARLY']
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => frequency = value ?? 'MONTHLY'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: dueDayController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Due day'),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: isActive,
                    onChanged: (value) => setState(() => isActive = value),
                    title: const Text('Active'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
    final amount = double.tryParse(amountController.text.trim());
    final dueDay = int.tryParse(dueDayController.text.trim());
    if (ok != true ||
        nameController.text.trim().isEmpty ||
        amount == null ||
        dueDay == null) {
      if (ok == true) {
        AppToast.show('Valid fee name, amount, and due day are required.');
      }
      return;
    }
    final next = [
      ...hostelFeeStructures.where((e) => e.id != existing?.id),
      AdminHostelFeeStructureRecord(
        id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameController.text.trim(),
        amount: amount,
        frequency: frequency,
        dueDay: dueDay,
        isActive: isActive,
      ),
    ];
    hostelFeeStructures.assignAll(next);
    await _saveHostelManagementSettings();
    AppToast.show('Hostel fee structure saved.');
  }

  Future<void> deleteHostelFeeStructure(
    AdminHostelFeeStructureRecord item,
  ) async {
    if (!await _confirm('Delete ${item.name}?')) return;
    hostelFeeStructures.removeWhere((e) => e.id == item.id);
    await _saveHostelManagementSettings();
    AppToast.show('Hostel fee structure deleted.');
  }

  Future<void> recordHostelFeePayment() async {
    if (studentOptions.isEmpty || hostelFeeStructures.isEmpty) {
      AppToast.show('Add students and fee structures first.');
      return;
    }
    String studentId = studentOptions.first['id']!;
    String structureId = hostelFeeStructures.first.id;
    String status = 'PAID';
    final amountController = TextEditingController();
    final paidOnController = TextEditingController(
      text: DateTime.now().toIso8601String().substring(0, 10),
    );
    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Record Hostel Fee Payment'),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: studentId,
                      decoration: const InputDecoration(labelText: 'Student'),
                      items: studentOptions
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item['id'],
                              child: Text(item['label'] ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => studentId = value ?? ''),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: structureId,
                      decoration: const InputDecoration(labelText: 'Fee'),
                      items: hostelFeeStructures
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item.id,
                              child: Text(item.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => structureId = value ?? ''),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Amount'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: status,
                      decoration: const InputDecoration(
                        labelText: 'Payment status',
                      ),
                      items: const ['PAID', 'PARTIAL', 'PENDING', 'WAIVED']
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => status = value ?? 'PAID'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: paidOnController,
                      decoration: const InputDecoration(
                        labelText: 'Paid on',
                        helperText: 'YYYY-MM-DD',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
    final amount = double.tryParse(amountController.text.trim());
    if (ok != true || amount == null) {
      if (ok == true) AppToast.show('Valid amount is required.');
      return;
    }
    final studentLabel =
        studentOptions.firstWhereOrNull(
          (item) => item['id'] == studentId,
        )?['label'] ??
        studentId;
    final structure = hostelFeeStructures.firstWhereOrNull(
      (item) => item.id == structureId,
    );
    final next = [
      ...hostelFeePayments,
      AdminHostelFeePaymentRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        studentId: studentId,
        studentLabel: studentLabel,
        structureId: structureId,
        structureLabel: structure?.name ?? 'Fee',
        amount: amount,
        paidOn: paidOnController.text.trim(),
        status: status,
      ),
    ];
    hostelFeePayments.assignAll(next);
    await _saveHostelManagementSettings();
    AppToast.show('Hostel fee payment recorded.');
  }

  Future<void> openHostelComplaintDialog({
    AdminHostelComplaintRecord? existing,
  }) async {
    if (studentOptions.isEmpty) {
      AppToast.show('No active students available.');
      return;
    }
    String studentId = existing?.studentId.isNotEmpty == true
        ? existing!.studentId
        : studentOptions.first['id']!;
    final categoryController = TextEditingController(
      text: existing?.category ?? 'GENERAL',
    );
    final descriptionController = TextEditingController(
      text: existing?.description ?? '',
    );
    String status = existing?.status ?? 'OPEN';
    final resolutionController = TextEditingController(
      text: existing?.resolutionNote ?? '',
    );

    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              existing == null ? 'Add Complaint' : 'Update Complaint',
            ),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: studentId,
                      decoration: const InputDecoration(labelText: 'Student'),
                      items: studentOptions
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item['id'],
                              child: Text(item['label'] ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => studentId = value ?? ''),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category (e.g. Maintenance, Safety)',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Complaint description',
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: const ['OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED']
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => status = value ?? 'OPEN'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: resolutionController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Resolution note',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
    if (ok != true || descriptionController.text.trim().isEmpty) {
      if (ok == true) AppToast.show('Complaint description is required.');
      return;
    }
    final studentLabel =
        studentOptions.firstWhereOrNull(
          (item) => item['id'] == studentId,
        )?['label'] ??
        studentId;
    final next = [
      ...hostelComplaints.where((item) => item.id != existing?.id),
      AdminHostelComplaintRecord(
        id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        studentId: studentId,
        studentLabel: studentLabel,
        category: categoryController.text.trim().isEmpty
            ? 'GENERAL'
            : categoryController.text.trim(),
        description: descriptionController.text.trim(),
        status: status,
        createdAt: existing?.createdAt.isNotEmpty == true
            ? existing!.createdAt
            : DateTime.now().toIso8601String().substring(0, 10),
        resolutionNote: resolutionController.text.trim(),
      ),
    ];
    hostelComplaints.assignAll(next);
    await _saveHostelManagementSettings();
    AppToast.show('Hostel complaint saved.');
  }

  Future<void> setHostelComplaintStatus(
    AdminHostelComplaintRecord item,
    String status,
  ) async {
    hostelComplaints.assignAll(
      hostelComplaints
          .map(
            (entry) => entry.id == item.id
                ? AdminHostelComplaintRecord(
                    id: entry.id,
                    studentId: entry.studentId,
                    studentLabel: entry.studentLabel,
                    category: entry.category,
                    description: entry.description,
                    status: status,
                    createdAt: entry.createdAt,
                    resolutionNote: entry.resolutionNote,
                  )
                : entry,
          )
          .toList(),
    );
    await _saveHostelManagementSettings();
    AppToast.show('Complaint status updated.');
  }

  Future<void> deleteHostelComplaint(AdminHostelComplaintRecord item) async {
    if (!await _confirm('Delete hostel complaint?')) return;
    hostelComplaints.removeWhere((entry) => entry.id == item.id);
    await _saveHostelManagementSettings();
    AppToast.show('Hostel complaint deleted.');
  }

  Future<void> _saveHostelManagementSettings() async {
    await _adminService.patchSchoolSettings({
      'hostelManagement': {
        'allocationStatusById': hostelAllocationStatusById,
        'visitorCheckoutById': hostelVisitorCheckoutById,
        'feeStructures': hostelFeeStructures.map((e) => e.toJson()).toList(),
        'feePayments': hostelFeePayments.map((e) => e.toJson()).toList(),
        'complaints': hostelComplaints.map((e) => e.toJson()).toList(),
      },
    });
  }

  Future<void> openEventDialog({AdminEventRecord? existing}) async {
    String existingDescription = '';
    if (existing != null) {
      try {
        final data = await _adminService.getEventById(existing.id);
        existingDescription = data['description']?.toString() ?? '';
      } catch (_) {}
    }
    final titleController = TextEditingController(text: existing?.title ?? '');
    final typeController = TextEditingController(
      text: existing?.eventType ?? 'GENERAL',
    );
    final locationController = TextEditingController(
      text: existing?.location ?? '',
    );
    final startDateController = TextEditingController(
      text: _opsDateText(existing?.startDate),
    );
    final endDateController = TextEditingController(
      text: _opsDateText(existing?.endDate),
    );
    final descriptionController = TextEditingController(
      text: existingDescription,
    );
    bool isPublished = existing?.isPublished ?? true;

    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(existing == null ? 'Create Event' : 'Edit Event'),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: typeController,
                      decoration: const InputDecoration(labelText: 'Type'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(labelText: 'Location'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: startDateController,
                      decoration: const InputDecoration(
                        labelText: 'Start date',
                        helperText: 'YYYY-MM-DD',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: endDateController,
                      decoration: const InputDecoration(
                        labelText: 'End date',
                        helperText: 'YYYY-MM-DD',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: isPublished,
                      onChanged: (value) => setState(() => isPublished = value),
                      title: const Text('Published'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: Text(existing == null ? 'Create' : 'Save'),
              ),
            ],
          );
        },
      ),
    );
    final startDate = _opsInputDate(startDateController.text);
    final endDate = _opsInputDate(endDateController.text);
    if (ok != true ||
        titleController.text.trim().isEmpty ||
        startDate == null) {
      if (ok == true) AppToast.show('Title and valid start date are required.');
      return;
    }
    try {
      final eventTypeInput = typeController.text.trim();
      final descriptionInput = descriptionController.text.trim();
      final locationInput = locationController.text.trim();
      final eventTypeNormalized =
          (eventTypeInput.isEmpty ? 'GENERAL' : eventTypeInput);
      final eventTypeCapped = eventTypeNormalized.length > 30
          ? eventTypeNormalized.substring(0, 30)
          : eventTypeNormalized;
      final payload = {
        'title': titleController.text.trim(),
        if (descriptionInput.isNotEmpty) 'description': descriptionInput,
        'eventType': eventTypeCapped,
        'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        if (locationInput.isNotEmpty) 'location': locationInput,
        'isPublished': isPublished,
      };
      if (existing == null) {
        await _adminService.createEvent(payload);
        AppToast.show('Event created.');
      } else {
        await _adminService.updateEvent(id: existing.id, payload: payload);
        AppToast.show('Event updated.');
      }
      await loadEvents();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> deleteEvent(AdminEventRecord item) async {
    if (!await _confirm('Delete ${item.title}?')) return;
    try {
      await _adminService.deleteEvent(item.id);
      AppToast.show('Event deleted.');
      await loadEvents();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> registerForEvent(AdminEventRecord item) async {
    if (studentOptions.isEmpty) {
      AppToast.show('No active students available.');
      return;
    }
    String studentId = studentOptions.first['id']!;
    final emailController = TextEditingController();
    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Register for ${item.title}'),
            content: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: studentId,
                    decoration: const InputDecoration(labelText: 'Student'),
                    items: studentOptions
                        .map(
                          (option) => DropdownMenuItem<String>(
                            value: option['id'],
                            child: Text(option['label'] ?? ''),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => studentId = value ?? ''),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Register'),
              ),
            ],
          );
        },
      ),
    );
    if (ok != true) return;
    try {
      await _adminService.registerForEvent(
        id: item.id,
        payload: {
          'studentId': studentId,
          'email': emailController.text.trim().isEmpty
              ? null
              : emailController.text.trim(),
        },
      );
      AppToast.show('Event registration created.');
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> addEventGallery(AdminEventRecord item) async {
    final urlController = TextEditingController();
    final captionController = TextEditingController();
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Add Gallery Image | ${item.title}'),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: urlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: captionController,
                decoration: const InputDecoration(labelText: 'Caption'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (ok != true || urlController.text.trim().isEmpty) return;
    try {
      await _adminService.addEventGalleryImage(
        id: item.id,
        payload: {
          'url': urlController.text.trim(),
          'caption': captionController.text.trim().isEmpty
              ? null
              : captionController.text.trim(),
        },
      );
      AppToast.show('Gallery image added.');
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> openEventDetails(AdminEventRecord item) async {
    try {
      final data = await _adminService.getEventById(item.id);
      final registrations = data['registrations'] as List? ?? const [];
      final gallery = data['gallery'] as List? ?? const [];
      await Get.dialog<void>(
        AlertDialog(
          title: Text(item.title),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Type: ${item.eventType}'),
                  if (item.location.isNotEmpty)
                    Text('Location: ${item.location}'),
                  Text('Start: ${_opsDateText(item.startDate)}'),
                  if (item.endDate != null)
                    Text('End: ${_opsDateText(item.endDate)}'),
                  const SizedBox(height: 12),
                  Text('Registrations: ${registrations.length}'),
                  ...registrations
                      .take(5)
                      .whereType<Map>()
                      .map(
                        (entry) => Text(
                          '- ${entry['email'] ?? entry['studentId'] ?? entry['userId'] ?? 'Registrant'}',
                        ),
                      ),
                  const SizedBox(height: 12),
                  Text('Gallery: ${gallery.length}'),
                  ...gallery
                      .take(5)
                      .whereType<Map>()
                      .map(
                        (entry) => Text(
                          '- ${entry['caption'] ?? entry['url'] ?? 'Image'}',
                        ),
                      ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Close')),
            OutlinedButton(
              onPressed: () {
                Get.back();
                registerForEvent(item);
              },
              child: const Text('Register'),
            ),
            FilledButton(
              onPressed: () {
                Get.back();
                addEventGallery(item);
              },
              child: const Text('Add Gallery'),
            ),
          ],
        ),
      );
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<bool> _confirm(String message) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> openTransportRouteDialog({
    AdminTransportRouteRecord? existing,
  }) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final codeController = TextEditingController(
      text: existing?.routeCode ?? '',
    );
    bool isActive = existing?.isActive ?? true;

    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(existing == null ? 'Add Route' : 'Edit Route'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Route name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: 'Route code'),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: isActive,
                  onChanged: (value) => setState(() => isActive = value),
                  title: const Text('Active'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: Text(existing == null ? 'Add' : 'Save'),
              ),
            ],
          );
        },
      ),
    );
    if (ok != true || nameController.text.trim().isEmpty) return;
    try {
      final payload = {
        'name': nameController.text.trim(),
        'routeCode': codeController.text.trim(),
        'isActive': isActive,
      };
      if (existing == null) {
        await _adminService.createTransportRoute(payload);
        AppToast.show('Route created.');
      } else {
        await _adminService.updateTransportRoute(
          id: existing.id,
          payload: payload,
        );
        AppToast.show('Route updated.');
      }
      await loadTransportRoutes();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> deleteTransportRoute(AdminTransportRouteRecord item) async {
    if (!await _confirm('Delete route ${item.name}?')) return;
    try {
      await _adminService.deleteTransportRoute(item.id);
      AppToast.show('Route deleted.');
      await loadTransportRoutes();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> openTransportDriverDialog({
    AdminTransportDriverRecord? existing,
  }) async {
    final nameController = TextEditingController(
      text: existing?.fullName ?? '',
    );
    final phoneController = TextEditingController(text: existing?.phone ?? '');
    final licenseController = TextEditingController(
      text: existing?.licenseNo ?? '',
    );
    String? selectedRouteId = existing?.routeId;
    if (selectedRouteId != null && selectedRouteId.isEmpty) {
      selectedRouteId = null;
    }
    bool isActive = existing?.isActive ?? true;

    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(existing == null ? 'Add Driver' : 'Edit Driver'),
            content: SizedBox(
              width: 440,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Full name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Phone'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: licenseController,
                      decoration: const InputDecoration(
                        labelText: 'License no',
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRouteId,
                      decoration: const InputDecoration(
                        labelText: 'Assigned route',
                      ),
                      items: transportRoutes
                          .map(
                            (r) => DropdownMenuItem<String>(
                              value: r.id,
                              child: Text(r.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => selectedRouteId = v),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: isActive,
                      onChanged: (value) => setState(() => isActive = value),
                      title: const Text('Active'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: Text(existing == null ? 'Add' : 'Save'),
              ),
            ],
          );
        },
      ),
    );
    if (ok != true || nameController.text.trim().isEmpty) return;
    try {
      final payload = {
        'fullName': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'licenseNo': licenseController.text.trim(),
        'routeId': selectedRouteId,
        'isActive': isActive,
      };
      if (existing == null) {
        await _adminService.createTransportDriver(payload);
        AppToast.show('Driver created.');
      } else {
        await _adminService.updateTransportDriver(
          id: existing.id,
          payload: payload,
        );
        AppToast.show('Driver updated.');
      }
      await loadTransportDrivers();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> openInventoryItemDialog({
    AdminInventoryItemRecord? existing,
  }) async {
    final skuController = TextEditingController(text: existing?.sku ?? '');
    final nameController = TextEditingController(text: existing?.name ?? '');
    final categoryController = TextEditingController(
      text: existing?.category ?? '',
    );
    final unitController = TextEditingController(text: existing?.unit ?? 'pcs');
    final thresholdController = TextEditingController(
      text: existing?.lowStockThreshold.toString() ?? '5',
    );
    bool isActive = existing?.isActive ?? true;

    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(existing == null ? 'Add Item' : 'Edit Item'),
            content: SizedBox(
              width: 440,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: skuController,
                      decoration: const InputDecoration(labelText: 'SKU'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Item name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: unitController,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: thresholdController,
                            decoration: const InputDecoration(
                              labelText: 'Low threshold',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: isActive,
                      onChanged: (value) => setState(() => isActive = value),
                      title: const Text('Active'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: Text(existing == null ? 'Add' : 'Save'),
              ),
            ],
          );
        },
      ),
    );
    if (ok != true || nameController.text.trim().isEmpty) return;
    try {
      final payload = {
        'sku': skuController.text.trim(),
        'name': nameController.text.trim(),
        'category': categoryController.text.trim(),
        'unit': unitController.text.trim(),
        'lowStockThreshold': int.tryParse(thresholdController.text) ?? 5,
        'isActive': isActive,
      };
      if (existing == null) {
        await _adminService.createInventoryItem(payload);
        AppToast.show('Item created.');
      } else {
        await _adminService.updateInventoryItem(
          id: existing.id,
          payload: payload,
        );
        AppToast.show('Item updated.');
      }
      await loadInventoryItems();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> deleteInventoryItem(AdminInventoryItemRecord item) async {
    if (!await _confirm('Delete inventory item ${item.name}?')) return;
    try {
      await _adminService.deleteInventoryItem(item.id);
      AppToast.show('Item deleted.');
      await loadInventoryItems();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> openInventoryTransactionDialog() async {
    String? selectedItemId;
    final typeController = TextEditingController(text: 'IN');
    final qtyController = TextEditingController();
    final noteController = TextEditingController();

    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Inventory Transaction'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedItemId,
                  decoration: const InputDecoration(labelText: 'Item'),
                  items: inventoryItems
                      .map(
                        (i) => DropdownMenuItem<String>(
                          value: i.id,
                          child: Text('${i.name} (${i.sku})'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => selectedItemId = v),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: typeController.text,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: 'IN', child: Text('Stock In')),
                    DropdownMenuItem(value: 'OUT', child: Text('Stock Out')),
                  ],
                  onChanged: (v) => setState(() => typeController.text = v!),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: qtyController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(labelText: 'Note'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Record'),
              ),
            ],
          );
        },
      ),
    );
    if (ok != true || selectedItemId == null || qtyController.text.isEmpty) {
      return;
    }
    try {
      await _adminService.createInventoryTransaction({
        'itemId': selectedItemId,
        'type': typeController.text,
        'qty': int.tryParse(qtyController.text) ?? 0,
        'note': noteController.text.trim(),
      });
      AppToast.show('Transaction recorded.');
      await Future.wait([loadInventoryItems(), loadInventoryTransactions()]);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  int _opsTab(int value) {
    if (value < 0) return 0;
    if (value > 3) return 3;
    return value;
  }
}

DateTime? _opsDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

DateTime? _opsInputDate(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text);
}

String _opsDateText(DateTime? value) {
  if (value == null) return '-';
  return value.toIso8601String().substring(0, 10);
}
