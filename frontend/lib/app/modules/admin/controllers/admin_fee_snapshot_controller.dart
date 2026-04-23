import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';

class FeeCategory {
  FeeCategory(this.name, this.due, this.collected, this.colorValue);
  final String name;
  final double due;
  final double collected;
  final int colorValue;
}

class FeeStructureItem {
  FeeStructureItem({
    required this.id,
    required this.name,
    required this.className,
    required this.amount,
    required this.category,
  });

  final String id;
  final String name;
  final String className;
  final double amount;
  final String category;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'className': className,
    'amount': amount,
    'category': category,
  };

  Map<String, dynamic> toApiPayload() => {
    'name': name,
    'className': className,
    'amount': amount,
    'category': category,
  };

  factory FeeStructureItem.fromJson(Map<String, dynamic> json) {
    final classMap = json['class'] is Map
        ? Map<String, dynamic>.from(json['class'] as Map)
        : const <String, dynamic>{};
    final className = _feeFirstText(json, const [
      'className',
      'classLabel',
      'grade',
    ]);
    return FeeStructureItem(
      id: _feeFirstText(json, const ['id', '_id', 'structureId']),
      name: _feeFirstText(json, const ['name', 'title', 'feeName', 'label']),
      className: className.isNotEmpty
          ? className
          : _feeFirstText(classMap, const ['name', 'title', 'label']),
      amount: _feeAsDouble(
        json['amount'] ?? json['feeAmount'] ?? json['totalAmount'],
      ),
      category: _feeFirstText(json, const ['category', 'feeType', 'type']),
    );
  }
}

class InstallmentPlan {
  InstallmentPlan({
    required this.id,
    required this.title,
    required this.className,
    required this.totalAmount,
    required this.installments,
  });

  final String id;
  final String title;
  final String className;
  final double totalAmount;
  final int installments;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'className': className,
    'totalAmount': totalAmount,
    'installments': installments,
  };

  factory InstallmentPlan.fromJson(Map<String, dynamic> json) =>
      InstallmentPlan(
        id: _feeFirstText(json, const ['id', '_id']),
        title: _feeFirstText(json, const ['title', 'name']),
        className: _feeFirstText(json, const ['className', 'classLabel']),
        totalAmount: _feeAsDouble(json['totalAmount'] ?? json['amount']),
        installments: _feeAsInt(json['installments'] ?? json['count'], 1),
      );
}

class FeeCategoryConfig {
  FeeCategoryConfig({
    required this.id,
    required this.name,
    required this.description,
  });

  final String id;
  final String name;
  final String description;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
  };

  factory FeeCategoryConfig.fromJson(Map<String, dynamic> json) =>
      FeeCategoryConfig(
        id: _feeFirstText(json, const ['id', '_id']),
        name: _feeFirstText(json, const ['name', 'title', 'category']),
        description: _feeFirstText(json, const ['description', 'notes']),
      );
}

class FeeReceiptItem {
  FeeReceiptItem({
    required this.receiptNo,
    required this.studentName,
    required this.amount,
    required this.mode,
    required this.date,
  });

  final String receiptNo;
  final String studentName;
  final double amount;
  final String mode;
  final String date;
}

class ReminderLogItem {
  ReminderLogItem({
    required this.title,
    required this.createdAt,
    required this.status,
  });

  final String title;
  final String createdAt;
  final String status;
}

double _feeAsDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int _feeAsInt(dynamic value, int fallback) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

String _feeFirstText(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty && text != 'null') return text;
  }
  return '';
}

List<dynamic> _feeItems(Map<String, dynamic> data, List<String> keys) {
  for (final key in keys) {
    final value = data[key];
    if (value is List) return value;
    if (value is Map) {
      final nested = _feeItems(Map<String, dynamic>.from(value), keys);
      if (nested.isNotEmpty) return nested;
    }
  }
  return const <dynamic>[];
}

class AdminFeeSnapshotController extends GetxController {
  AdminFeeSnapshotController(this._adminService);

  final AdminService _adminService;

  final isLoading = false.obs;
  final isSaving = false.obs;
  final totalDues = 0.0.obs;
  final collected = 0.0.obs;
  final pending = 0.0.obs;
  final overallPercent = 0.0.obs;
  final weekVsLastWeekPct = 0.0.obs;
  final categories = <FeeCategory>[].obs;
  final feesSummarySchemaVersion = RxnString();

  final structures = <FeeStructureItem>[].obs;
  final installmentPlans = <InstallmentPlan>[].obs;
  final categoryConfigs = <FeeCategoryConfig>[].obs;
  final receipts = <FeeReceiptItem>[].obs;
  final reminderLogs = <ReminderLogItem>[].obs;

  final gatewayProvider = ''.obs;
  final gatewayActive = false.obs;
  final gatewayMerchantId = ''.obs;
  final lateFeeType = 'percent'.obs;
  final lateFeeValue = 0.0.obs;
  final lateFeeGraceDays = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadFeeSnapshot();
  }

  Future<void> loadFeeSnapshot() async {
    isLoading.value = true;
    try {
      final data = await _adminService.getFeeSnapshot();
      final weekCollected =
          (data['thisWeekCollected'] as num?)?.toDouble() ?? 0;
      final weekPending = (data['pendingAmount'] as num?)?.toDouble() ?? 0;
      totalDues.value = weekCollected + weekPending;
      collected.value = (data['todayCollected'] as num?)?.toDouble() ?? 0;
      pending.value = weekPending;
      weekVsLastWeekPct.value =
          (data['vsLastWeekPct'] as num?)?.toDouble() ?? 0;
      overallPercent.value = totalDues.value > 0
          ? (collected.value / totalDues.value) * 100
          : 0;

      await Future.wait([
        _loadCategoriesFromSummary(),
        _loadFeeReceipts(),
        _loadReminderLogs(),
      ]);
      await _loadFeeManagementSettings();
      await _loadFeeStructures();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadCategoriesFromSummary() async {
    try {
      final summary = await _adminService.getFeesSummary();
      feesSummarySchemaVersion.value = summary['schemaVersion']?.toString();
      categories.assignAll(_parseCategoriesFromSummary(summary));
    } catch (_) {
      categories.clear();
    }
  }

  Future<void> _loadFeeManagementSettings() async {
    final settings = await _adminService.getSchoolSettings();
    final feeConfig = settings['feeManagement'];
    if (feeConfig is! Map) return;
    final map = Map<String, dynamic>.from(feeConfig);
    structures.assignAll(
      (map['structures'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map((e) => FeeStructureItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
    installmentPlans.assignAll(
      (map['installments'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map((e) => InstallmentPlan.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
    categoryConfigs.assignAll(
      (map['categories'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map((e) => FeeCategoryConfig.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
    final gateway = map['gateway'];
    if (gateway is Map) {
      final g = Map<String, dynamic>.from(gateway);
      gatewayProvider.value = (g['provider'] ?? '').toString();
      gatewayActive.value = g['active'] == true;
      gatewayMerchantId.value = (g['merchantId'] ?? '').toString();
    }
    final lateFee = map['lateFee'];
    if (lateFee is Map) {
      final lf = Map<String, dynamic>.from(lateFee);
      lateFeeType.value = (lf['type'] ?? 'percent').toString();
      lateFeeValue.value = (lf['value'] as num?)?.toDouble() ?? 0;
      lateFeeGraceDays.value = (lf['graceDays'] as num?)?.toInt() ?? 0;
    }
  }

  Future<void> _loadFeeStructures() async {
    try {
      final data = await _adminService.getFeeStructures(page: 1, limit: 100);
      final items = _feeItems(data, const [
        'items',
        'records',
        'rows',
        'structures',
        'feeStructures',
        'data',
      ]);
      structures.assignAll(
        items
            .whereType<Map>()
            .map((e) => FeeStructureItem.fromJson(Map<String, dynamic>.from(e)))
            .where((item) => item.id.isNotEmpty)
            .toList(),
      );
    } catch (_) {
      // Keep legacy settings-backed structures visible if the dedicated
      // fee-structure API is unavailable for the signed-in account.
    }
  }

  Future<void> _loadFeeReceipts() async {
    List<dynamic> items;
    try {
      final data = await _adminService.getPayments(page: 1, limit: 50);
      items = _feeItems(data, const [
        'items',
        'records',
        'rows',
        'payments',
        'data',
      ]);
    } catch (_) {
      final now = DateTime.now();
      final from = DateTime(now.year, now.month, 1).toIso8601String();
      final to = now.toIso8601String();
      final data = await _adminService.getFeesReport(
        dateFrom: from,
        dateTo: to,
      );
      final collections = (data['collections'] is Map)
          ? Map<String, dynamic>.from(data['collections'] as Map)
          : <String, dynamic>{};
      items = _feeItems(collections, const [
        'items',
        'records',
        'rows',
        'payments',
      ]);
    }
    receipts.assignAll(
      items.whereType<Map>().map((raw) {
        final row = Map<String, dynamic>.from(raw);
        final studentMap = row['student'] is Map
            ? Map<String, dynamic>.from(row['student'] as Map)
            : const <String, dynamic>{};
        final directStudent = _feeFirstText(row, const ['studentName', 'name']);
        final nestedStudent = [
          _feeFirstText(studentMap, const ['firstName', 'fullName', 'name']),
          _feeFirstText(studentMap, const ['lastName']),
        ].where((part) => part.isNotEmpty).join(' ').trim();
        final student = directStudent.isNotEmpty
            ? directStudent
            : nestedStudent;
        return FeeReceiptItem(
          receiptNo:
              (row['receiptNo'] ?? row['receiptNumber'] ?? row['id'] ?? 'N/A')
                  .toString(),
          studentName: student.isEmpty ? 'Student' : student,
          amount: _feeAsDouble(
            row['amount'] ?? row['paidAmount'] ?? row['collectionAmount'],
          ),
          mode: (row['paymentMode'] ?? row['mode'] ?? 'Unknown').toString(),
          date: (row['date'] ?? row['paidAt'] ?? row['createdAt'] ?? '')
              .toString(),
        );
      }).toList(),
    );
  }

  Future<void> _loadReminderLogs() async {
    final data = await _adminService.getAnnouncements(page: 1, limit: 20);
    final items = (data['items'] as List<dynamic>? ?? const <dynamic>[]);
    reminderLogs.assignAll(
      items.whereType<Map>().map((raw) {
        final row = Map<String, dynamic>.from(raw);
        return ReminderLogItem(
          title: (row['title'] ?? '').toString(),
          createdAt: (row['createdAt'] ?? '').toString(),
          status: (row['status'] ?? '').toString(),
        );
      }).toList(),
    );
  }

  Future<void> saveStructure(FeeStructureItem item) async {
    if (item.name.trim().isEmpty || item.amount <= 0) {
      AppToast.show('Structure name and valid amount are required.');
      return;
    }
    isSaving.value = true;
    try {
      final exists = structures.any((e) => e.id == item.id);
      if (exists) {
        await _adminService.updateFeeStructure(
          id: item.id,
          payload: item.toApiPayload(),
        );
      } else {
        await _adminService.createFeeStructure(item.toApiPayload());
      }
      await _loadFeeStructures();
      AppToast.show('Fee structure saved.');
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteStructure(String id) async {
    if (id.trim().isEmpty) return;
    isSaving.value = true;
    try {
      await _adminService.deleteFeeStructure(id);
      await _loadFeeStructures();
      AppToast.show('Fee structure removed.');
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> saveInstallmentPlan(InstallmentPlan item) async {
    final next = [...installmentPlans.where((e) => e.id != item.id), item];
    await _saveFeeManagementSettings(
      installmentsData: next.map((e) => e.toJson()).toList(),
    );
    installmentPlans.assignAll(next);
    AppToast.show('Installment plan saved.');
  }

  Future<void> deleteInstallmentPlan(String id) async {
    final next = installmentPlans.where((e) => e.id != id).toList();
    await _saveFeeManagementSettings(
      installmentsData: next.map((e) => e.toJson()).toList(),
    );
    installmentPlans.assignAll(next);
    AppToast.show('Installment plan removed.');
  }

  Future<void> saveCategoryConfig(FeeCategoryConfig item) async {
    final next = [...categoryConfigs.where((e) => e.id != item.id), item];
    await _saveFeeManagementSettings(
      categoriesData: next.map((e) => e.toJson()).toList(),
    );
    categoryConfigs.assignAll(next);
    AppToast.show('Fee category saved.');
  }

  Future<void> deleteCategoryConfig(String id) async {
    final next = categoryConfigs.where((e) => e.id != id).toList();
    await _saveFeeManagementSettings(
      categoriesData: next.map((e) => e.toJson()).toList(),
    );
    categoryConfigs.assignAll(next);
    AppToast.show('Fee category removed.');
  }

  Future<void> saveGatewayConfig({
    required String provider,
    required String merchantId,
    required bool active,
  }) async {
    gatewayProvider.value = provider;
    gatewayMerchantId.value = merchantId;
    gatewayActive.value = active;
    await _saveFeeManagementSettings(
      gatewayData: {
        'provider': provider,
        'merchantId': merchantId,
        'active': active,
      },
    );
    AppToast.show('Payment gateway settings updated.');
  }

  Future<void> saveLateFeeConfig({
    required String type,
    required double value,
    required int graceDays,
  }) async {
    lateFeeType.value = type;
    lateFeeValue.value = value;
    lateFeeGraceDays.value = graceDays;
    await _saveFeeManagementSettings(
      lateFeeData: {'type': type, 'value': value, 'graceDays': graceDays},
    );
    AppToast.show('Late fee settings updated.');
  }

  Future<void> sendFeeReminder({
    required String title,
    required String content,
  }) async {
    isSaving.value = true;
    try {
      final created = await _adminService.createAnnouncement(
        title: title,
        content: content,
        audience: 'PARENTS',
        status: 'DRAFT',
      );
      final announcement = created['announcement'] is Map
          ? Map<String, dynamic>.from(created['announcement'] as Map)
          : const <String, dynamic>{};
      final directId = _feeFirstText(created, const ['id']);
      final id = directId.isNotEmpty
          ? directId
          : _feeFirstText(announcement, const ['id']);
      if (id.isNotEmpty) {
        await _adminService.sendAnnouncement(id);
      }
      await _loadReminderLogs();
      AppToast.show('Fee reminder sent.');
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> openFeeReports() async {
    await Get.toNamed('/admin-reports', arguments: {'tabIndex': 2});
  }

  Future<void> _saveFeeManagementSettings({
    List<Map<String, dynamic>>? structuresData,
    List<Map<String, dynamic>>? installmentsData,
    List<Map<String, dynamic>>? categoriesData,
    Map<String, dynamic>? gatewayData,
    Map<String, dynamic>? lateFeeData,
  }) async {
    final existingSettings = await _adminService.getSchoolSettings();
    final feeManagement = existingSettings['feeManagement'];
    final current = feeManagement is Map<String, dynamic>
        ? Map<String, dynamic>.from(feeManagement)
        : <String, dynamic>{};
    if (structuresData != null) current['structures'] = structuresData;
    if (installmentsData != null) current['installments'] = installmentsData;
    if (categoriesData != null) current['categories'] = categoriesData;
    if (gatewayData != null) current['gateway'] = gatewayData;
    if (lateFeeData != null) current['lateFee'] = lateFeeData;
    await _adminService.patchSchoolSettings({'feeManagement': current});
  }

  List<FeeCategory> _parseCategoriesFromSummary(Map<String, dynamic> summary) {
    final raw = summary['categories'];
    if (raw is! List) return [];
    const colors = <int>[
      0xFF137FEC,
      0xFFFFC107,
      0xFF9C27B0,
      0xFF009688,
      0xFFFF5722,
    ];
    final out = <FeeCategory>[];
    var i = 0;
    for (final item in raw) {
      if (item is! Map) continue;
      final m = Map<String, dynamic>.from(item);
      final name = (m['name'] ?? m['title'] ?? m['label'] ?? 'Fee').toString();
      final due = _asDouble(m['amountDue']);
      final coll = _asDouble(m['amountPaid']);
      if (due <= 0 && coll <= 0) continue;
      out.add(
        FeeCategory(
          name,
          due > 0 ? due : coll,
          coll,
          colors[i % colors.length],
        ),
      );
      i++;
    }
    return out;
  }

  double _asDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }

  // Backward compatibility with older view code.
  void onViewDetails() {
    loadFeeSnapshot();
  }

  void onSendReminders() {
    loadFeeSnapshot();
  }
}
