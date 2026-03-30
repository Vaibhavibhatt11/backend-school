import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';

class FeeCategory {
  final String name;
  final double due;
  final double collected;
  final Color color;
  FeeCategory(this.name, this.due, this.collected, this.color);
}

class AdminFeeSnapshotController extends GetxController {
  AdminFeeSnapshotController(this._adminService);

  final AdminService _adminService;
  final isLoading = false.obs;
  final totalDues = 0.0.obs;
  final collected = 0.0.obs;
  final pending = 0.0.obs;
  final overallPercent = 0.0.obs;
  final weekVsLastWeekPct = 0.0.obs;
  final categories = <FeeCategory>[].obs;
  /// From `GET /school/fees/summary` (`docs/.../get-school-fees-summary.response.schema.json`).
  final feesSummarySchemaVersion = RxnString();

  static const List<Color> _categoryColors = [
    Color(0xFF137FEC),
    Colors.amber,
    Colors.purple,
    Colors.teal,
    Colors.deepOrange,
  ];

  @override
  void onInit() {
    super.onInit();
    loadFeeSnapshot();
  }

  Future<void> loadFeeSnapshot() async {
    isLoading.value = true;
    try {
      final data = await _adminService.getFeeSnapshot();
      final weekCollected = (data['thisWeekCollected'] as num?)?.toDouble() ?? 0;
      final weekPending = (data['pendingAmount'] as num?)?.toDouble() ?? 0;
      totalDues.value = weekCollected + weekPending;
      collected.value = (data['todayCollected'] as num?)?.toDouble() ?? 0;
      pending.value = weekPending;
      weekVsLastWeekPct.value = (data['vsLastWeekPct'] as num?)?.toDouble() ?? 0;
      final total = totalDues.value;
      overallPercent.value = total > 0 ? (collected.value / total) * 100 : 0;

      try {
        final summary = await _adminService.getFeesSummary();
        feesSummarySchemaVersion.value = summary['schemaVersion']?.toString();
        categories.assignAll(_parseCategoriesFromSummary(summary));
      } catch (e) {
        feesSummarySchemaVersion.value = null;
        categories.clear();
        AppToast.show(dioOrApiErrorMessage(e));
      }
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
      categories.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Prefer stable `data.categories` from fees summary schema.
  List<FeeCategory> _parseCategoriesFromSummary(Map<String, dynamic> summary) {
    final raw = summary['categories'];
    if (raw is! List) return [];

    final out = <FeeCategory>[];
    var i = 0;
    for (final item in raw) {
      if (item is! Map) continue;
      final m = Map<String, dynamic>.from(item);
      final name = (m['name'] ?? m['title'] ?? m['label'] ?? 'Fee').toString();
      final due = _asDouble(m['amountDue']);
      final coll = _asDouble(m['amountPaid']);
      if (due <= 0 && coll <= 0) continue;
      final color = _categoryColors[i % _categoryColors.length];
      i++;
      out.add(FeeCategory(name, due > 0 ? due : coll, coll, color));
    }
    return out;
  }

  double _asDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }

  void onViewDetails() {
    loadFeeSnapshot();
  }

  void onSendReminders() {
    loadFeeSnapshot();
  }
}
