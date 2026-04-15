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
    required this.isActive,
  });

  final String id;
  final String fullName;
  final String phone;
  final String licenseNo;
  final String routeId;
  final bool isActive;

  factory AdminTransportDriverRecord.fromJson(Map<String, dynamic> json) {
    return AdminTransportDriverRecord(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      licenseNo: json['licenseNo']?.toString() ?? '',
      routeId: json['routeId']?.toString() ?? '',
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

  factory AdminTransportAllocationRecord.fromJson(Map<String, dynamic> json) {
    final student =
        json['student'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final route =
        json['route'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final studentLabel =
        '${student['firstName']?.toString() ?? ''} ${student['lastName']?.toString() ?? ''} (${student['admissionNo']?.toString() ?? ''})'
            .trim();
    final routeLabel =
        '${route['name']?.toString() ?? ''} (${route['routeCode']?.toString() ?? ''})'
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
    required this.studentLabel,
    required this.roomLabel,
    required this.fromDate,
    required this.toDate,
  });

  final String id;
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
  });

  final String id;
  final String studentId;
  final String status;
  final String remark;

  factory AdminHostelAttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AdminHostelAttendanceRecord(
      id: json['id']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      remark: json['remark']?.toString() ?? '',
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
  });

  final String id;
  final String visitorName;
  final String studentId;
  final String purpose;
  final String idProof;
  final DateTime? inTime;

  factory AdminHostelVisitorRecord.fromJson(Map<String, dynamic> json) {
    return AdminHostelVisitorRecord(
      id: json['id']?.toString() ?? '',
      visitorName: json['visitorName']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? '',
      purpose: json['purpose']?.toString() ?? '',
      idProof: json['idProof']?.toString() ?? '',
      inTime: _opsDate(json['inTime']),
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
  final events = <AdminEventRecord>[].obs;
  final studentOptions = <Map<String, String>>[].obs;

  bool _transportLoaded = false;
  bool _hostelLoaded = false;
  bool _eventsLoaded = false;

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
        if (force || !_transportLoaded) {
          await Future.wait([
            loadTransportRoutes(),
            loadTransportDrivers(),
            loadTransportAllocations(),
          ]);
          _transportLoaded = true;
        }
      } else if (currentTab.value == 1) {
        if (force || !_hostelLoaded) {
          await Future.wait([
            loadHostelRooms(),
            loadHostelAllocations(),
            loadHostelAttendance(),
            loadHostelVisitors(),
          ]);
          _hostelLoaded = true;
        }
      } else {
        if (force || !_eventsLoaded) {
          await loadEvents();
          _eventsLoaded = true;
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
    final data = await _adminService.getHostelAttendance();
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
                      value: routeId,
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
                      value: studentId,
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
                      value: routeId,
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

  Future<void> openHostelAllocationDialog() async {
    if (studentOptions.isEmpty || hostelRooms.isEmpty) {
      AppToast.show('Add students and rooms first.');
      return;
    }
    String studentId = studentOptions.first['id']!;
    String roomId = hostelRooms.first.id;
    final fromDateController = TextEditingController();
    final toDateController = TextEditingController();

    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Allocate Hostel Room'),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: studentId,
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
                      value: roomId,
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
                child: const Text('Create'),
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
      AppToast.show('Hostel allocation created.');
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
                      value: studentId,
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
                      value: status,
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
                      value: studentId.isEmpty ? null : studentId,
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
      final payload = {
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        'eventType': typeController.text.trim().isEmpty
            ? 'GENERAL'
            : typeController.text.trim(),
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'location': locationController.text.trim().isEmpty
            ? null
            : locationController.text.trim(),
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
                    value: studentId,
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

  int _opsTab(int value) {
    if (value < 0) return 0;
    if (value > 2) return 2;
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
