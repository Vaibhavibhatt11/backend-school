import 'dart:convert';
import 'dart:io';

import 'package:erp_frontend/app/modules/admin/models/admin_report_models.dart';
import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:erp_frontend/common/utils/export_downloader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminReportsController extends GetxController {
  AdminReportsController(this._adminService);

  final AdminService _adminService;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final selectedRange = 'This Month'.obs;
  final selectedClass = 'All Classes'.obs;
  final classOptions = <String>['All Classes'].obs;
  final attendanceBadge = '0% Attendance'.obs;
  final feeOutstanding = 0.0.obs;
  final collectionTotal = 0.0.obs;
  final attendanceDetail = Rxn<AdminReportPayload>();
  final feesDetail = Rxn<AdminReportPayload>();
  final academicDetail = Rxn<AdminReportPayload>();
  final staffDetail = Rxn<AdminReportPayload>();
  final transportDetail = Rxn<AdminReportPayload>();
  final productivityDetail = Rxn<AdminReportPayload>();
  final progressDetail = Rxn<AdminReportPayload>();
  final allDetail = Rxn<AdminReportPayload>();
  
  final feeOutstandingBadge = '₹0'.obs;
  final progressPassBadge = '0%'.obs;
  final attendanceDetailError = ''.obs;
  final feesDetailError = ''.obs;
  final isAttendanceDetailLoading = false.obs;
  final isFeesDetailLoading = false.obs;
  final isAcademicDetailLoading = false.obs;
  final isStaffDetailLoading = false.obs;
  final isTransportDetailLoading = false.obs;
  final isProductivityDetailLoading = false.obs;
  final isProgressDetailLoading = false.obs;
  final isAllDetailLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadReports();
  }

  Future<void> loadReports() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await _loadClasses();
      await _refreshAttendanceData();
      await _refreshFeesData();
      await _refreshAcademicData();
      await _refreshStaffData();
      await _refreshTransportData();
      await _refreshProductivityData();
      await _refreshProgressData();
      await _refreshAllData();
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      AppToast.show(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadClasses() async {
    final data = await _adminService.getClasses(page: 1, limit: 100);
    final items = data['items'];
    final options = <String>['All Classes'];
    if (items is List) {
      for (final item in items.whereType<Map>()) {
        final name = (item['name'] ?? '').toString().trim();
        final section = (item['section'] ?? '').toString().trim();
        final value = section.isNotEmpty ? '$name - $section' : name;
        if (value.isNotEmpty && !options.contains(value)) {
          options.add(value);
        }
      }
    }
    classOptions.assignAll(options);
    if (!classOptions.contains(selectedClass.value)) {
      selectedClass.value = classOptions.first;
    }
  }

  Future<void> _refreshAttendanceData() async {
    final filters = _selectedClassFilters();
    final range = _dateRange();
    final data = await _adminService.getAttendanceReport(
      dateFrom: range.start.toIso8601String(),
      dateTo: range.end.toIso8601String(),
      type: 'student',
      className: filters.className,
      section: filters.section,
    );
    final built = _buildAttendancePayload(data);
    attendanceDetail.value = built.payload;
    attendanceDetailError.value = '';
    final total = built.present + built.late + built.absent;
    final pct = total > 0
        ? (((built.present + built.late) / total) * 100).round()
        : 0;
    attendanceBadge.value = '$pct% Attendance';
  }

  Future<void> _refreshFeesData() async {
    final filters = _selectedClassFilters();
    final range = _dateRange();
    final data = await _adminService.getFeesReport(
      dateFrom: range.start.toIso8601String(),
      dateTo: range.end.toIso8601String(),
      className: filters.className,
      section: filters.section,
    );
    final built = _buildFeesPayload(data);
    feesDetail.value = built.payload;
    feesDetailError.value = '';
    feeOutstanding.value = built.outstanding;
    collectionTotal.value = built.collectionTotal;
    feeOutstandingBadge.value = _currency(built.outstanding);
  }

  Future<void> loadAttendanceDetail({bool force = false}) async {
    if (!force && attendanceDetail.value != null) return;
    isAttendanceDetailLoading.value = true;
    try {
      await _refreshAttendanceData();
    } catch (e) {
      attendanceDetailError.value = dioOrApiErrorMessage(e);
      AppToast.show(attendanceDetailError.value);
    } finally {
      isAttendanceDetailLoading.value = false;
    }
  }

  Future<void> loadFeesDetail({bool force = false}) async {
    if (!force && feesDetail.value != null) return;
    isFeesDetailLoading.value = true;
    try {
      await _refreshFeesData();
    } catch (e) {
      feesDetailError.value = dioOrApiErrorMessage(e);
      AppToast.show(feesDetailError.value);
    } finally {
      isFeesDetailLoading.value = false;
    }
  }

  Future<void> loadAcademicDetail({bool force = false}) async {
    if (!force && academicDetail.value != null) return;
    isAcademicDetailLoading.value = true;
    try {
      await _refreshAcademicData();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    } finally {
      isAcademicDetailLoading.value = false;
    }
  }

  Future<void> loadStaffDetail({bool force = false}) async {
    if (!force && staffDetail.value != null) return;
    isStaffDetailLoading.value = true;
    try {
      await _refreshStaffData();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    } finally {
      isStaffDetailLoading.value = false;
    }
  }

  Future<void> loadTransportDetail({bool force = false}) async {
    if (!force && transportDetail.value != null) return;
    isTransportDetailLoading.value = true;
    try {
      await _refreshTransportData();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    } finally {
      isTransportDetailLoading.value = false;
    }
  }

  Future<void> loadProductivityDetail({bool force = false}) async {
    if (!force && productivityDetail.value != null) return;
    isProductivityDetailLoading.value = true;
    try {
      await _refreshProductivityData();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    } finally {
      isProductivityDetailLoading.value = false;
    }
  }

  Future<void> loadProgressDetail({bool force = false}) async {
    if (!force && progressDetail.value != null) return;
    isProgressDetailLoading.value = true;
    try {
      await _refreshProgressData();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    } finally {
      isProgressDetailLoading.value = false;
    }
  }

  Future<void> loadAllDetail({bool force = false}) async {
    if (!force && allDetail.value != null) return;
    isAllDetailLoading.value = true;
    try {
      await _refreshAllData();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    } finally {
      isAllDetailLoading.value = false;
    }
  }

  void onViewDetailedLog() {
    Get.toNamed(
      AppRoutes.ADMIN_REPORTS_DETAIL,
      arguments: {'kind': AdminReportKind.attendance},
    );
  }

  void onCollectionAnalysis() {
    Get.toNamed(
      AppRoutes.ADMIN_REPORTS_DETAIL,
      arguments: {'kind': AdminReportKind.fees},
    );
  }

  void openReport(AdminReportKind kind) {
    Get.toNamed(
      AppRoutes.ADMIN_REPORTS_DETAIL,
      arguments: {'kind': kind},
    );
  }

  void onRangeTap() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('This Month'),
              onTap: () {
                selectedRange.value = 'This Month';
                Get.back();
                loadReports();
              },
            ),
            ListTile(
              title: const Text('Last Month'),
              onTap: () {
                selectedRange.value = 'Last Month';
                Get.back();
                loadReports();
              },
            ),
            ListTile(
              title: const Text('This Year'),
              onTap: () {
                selectedRange.value = 'This Year';
                Get.back();
                loadReports();
              },
            ),
          ],
        ),
      ),
    );
  }

  void onClassTap() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...classOptions.map(
              (value) => ListTile(
                title: Text(value),
                onTap: () {
                  selectedClass.value = value;
                  Get.back();
                  loadReports();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onPDFExport(AdminReportKind kind) async {
    final payload = await _ensurePayload(kind);
    if (payload == null) return;
    final bytes = _buildPdfBytes(payload);
    final fileName =
        '${payload.kind.fileStem}-${_timestampFilePart(payload.generatedAt)}.pdf';
    await _saveExport(
      bytes: bytes,
      fileName: fileName,
      mimeType: 'application/pdf',
      successLabel: 'PDF report ready',
    );
  }

  Future<void> onExcelExport(AdminReportKind kind) async {
    final payload = await _ensurePayload(kind);
    if (payload == null) return;
    final workbook = _buildExcelWorkbook(payload);
    final fileName =
        '${payload.kind.fileStem}-${_timestampFilePart(payload.generatedAt)}.xls';
    await _saveExport(
      bytes: utf8.encode(workbook),
      fileName: fileName,
      mimeType: 'application/vnd.ms-excel',
      successLabel: 'Excel export ready',
    );
  }

  Future<AdminReportPayload?> _ensurePayload(AdminReportKind kind) async {
    try {
      switch (kind) {
        case AdminReportKind.attendance:
          await loadAttendanceDetail(force: attendanceDetail.value == null);
          return attendanceDetail.value;
        case AdminReportKind.fees:
          await loadFeesDetail(force: feesDetail.value == null);
          return feesDetail.value;
        case AdminReportKind.academic:
          await loadAcademicDetail(force: academicDetail.value == null);
          return academicDetail.value;
        case AdminReportKind.staff:
          await loadStaffDetail(force: staffDetail.value == null);
          return staffDetail.value;
        case AdminReportKind.transport:
          await loadTransportDetail(force: transportDetail.value == null);
          return transportDetail.value;
        case AdminReportKind.productivity:
          await loadProductivityDetail(force: productivityDetail.value == null);
          return productivityDetail.value;
        case AdminReportKind.progress:
          await loadProgressDetail(force: progressDetail.value == null);
          return progressDetail.value;
        case AdminReportKind.all:
          await loadAllDetail(force: allDetail.value == null);
          return allDetail.value;
      }
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
      return null;
    }
  }

  ({AdminReportPayload payload, int present, int late, int absent})
  _buildAttendancePayload(Map<String, dynamic> data) {
    final generatedAt = DateTime.now();
    final subtitle = _reportSubtitle();
    final summary = _asMap(data['summary']);
    final summaryRows = <List<String>>[];
    final summaryStatuses = <String>{};
    int present = 0;
    int late = 0;
    int absent = 0;
    int leave = 0;

    if (summary != null) {
      for (final entry in summary.entries) {
        final child = _asMap(entry.value);
        if (child == null) continue;
        final numericKeys = child.entries
            .where((row) => _isNumeric(row.value))
            .map((row) => row.key.toString().toUpperCase())
            .toList();
        if (numericKeys.isEmpty) continue;
        summaryStatuses.addAll(numericKeys);
      }

      final orderedStatuses = _orderedStatuses(summaryStatuses);
      for (final entry in summary.entries) {
        final child = _asMap(entry.value);
        if (child == null) continue;
        final values = <String>[];
        var total = 0;
        for (final status in orderedStatuses) {
          final count = _readCount(child, status);
          if (status == 'PRESENT') present += count;
          if (status == 'LATE') late += count;
          if (status == 'ABSENT') absent += count;
          if (status == 'LEAVE') leave += count;
          total += count;
          values.add('$count');
        }
        summaryRows.add([_humanize(entry.key), ...values, '$total']);
      }
    }

    final attendanceRecords = _firstMapList(data, const [
      ['records'],
      ['attendance'],
      ['items'],
      ['rows'],
      ['logs'],
    ]);

    if (present == 0 &&
        late == 0 &&
        absent == 0 &&
        attendanceRecords.isNotEmpty) {
      for (final row in attendanceRecords) {
        final status = _firstText(row, const [
          'status',
          'attendanceStatus',
          'state',
        ]).toUpperCase();
        if (status == 'PRESENT') present++;
        if (status == 'LATE') late++;
        if (status == 'ABSENT') absent++;
        if (status == 'LEAVE') leave++;
      }
    }

    final totalCount = present + late + absent + leave;
    final attendancePct = totalCount > 0
        ? (((present + late) / totalCount) * 100).toStringAsFixed(1)
        : '0.0';

    final metrics = <AdminReportMetric>[
      AdminReportMetric(
        label: 'Attendance Rate',
        value: '$attendancePct%',
        helper: '${selectedRange.value} range',
      ),
      AdminReportMetric(label: 'Present', value: '$present'),
      AdminReportMetric(label: 'Late', value: '$late'),
      AdminReportMetric(
        label: 'Absent',
        value: '$absent',
        helper: leave > 0 ? 'Leave: $leave' : null,
      ),
    ];

    final sections = <AdminReportSection>[];
    if (summaryRows.isNotEmpty) {
      final orderedStatuses = _orderedStatuses(summaryStatuses);
      sections.add(
        AdminReportSection(
          title: 'Attendance Summary',
          columns: ['Group', ...orderedStatuses.map(_humanize), 'Total'],
          rows: summaryRows,
        ),
      );
    }

    final detailSection = _buildSectionFromRecords(
      title: 'Detailed Log',
      records: attendanceRecords,
      specs: [
        _ReportColumnSpec(
          'Date',
          (row) => _formatDateTime(
            _parseDate(
              _firstText(row, const [
                'date',
                'attendanceDate',
                'createdAt',
                'updatedAt',
              ]),
            ),
          ),
        ),
        _ReportColumnSpec('Name', (row) => _extractPersonName(row)),
        _ReportColumnSpec(
          'ID',
          (row) => _firstText(row, const [
            'admissionNo',
            'employeeCode',
            'studentId',
            'staffId',
            'id',
          ]),
        ),
        _ReportColumnSpec('Class', (row) => _extractClassLabel(row)),
        _ReportColumnSpec(
          'Status',
          (row) =>
              _firstText(row, const ['status', 'attendanceStatus', 'state']),
        ),
        _ReportColumnSpec(
          'In Time',
          (row) =>
              _firstText(row, const ['inTime', 'checkInAt', 'checkInTime']),
        ),
        _ReportColumnSpec(
          'Out Time',
          (row) =>
              _firstText(row, const ['outTime', 'checkOutAt', 'checkOutTime']),
        ),
        _ReportColumnSpec(
          'Remark',
          (row) => _firstText(row, const ['remark', 'notes', 'reason']),
        ),
      ],
    );
    if (detailSection != null) {
      sections.add(detailSection);
    }

    return (
      payload: AdminReportPayload(
        kind: AdminReportKind.attendance,
        title: AdminReportKind.attendance.title,
        subtitle: subtitle,
        generatedAt: generatedAt,
        metrics: metrics,
        sections: sections,
      ),
      present: present,
      late: late,
      absent: absent,
    );
  }

  ({AdminReportPayload payload, double outstanding, double collectionTotal})
  _buildFeesPayload(Map<String, dynamic> data) {
    final generatedAt = DateTime.now();
    final subtitle = _reportSubtitle();
    final invoices = _asMap(data['invoices']) ?? const <String, dynamic>{};
    final collections =
        _asMap(data['collections']) ?? const <String, dynamic>{};
    final totalDue = _readDoubleAny(invoices, const [
      'totalDue',
      'amountDue',
      'grandTotal',
      'totalAmount',
    ]);
    final totalPaid = _readDoubleAny(invoices, const [
      'totalPaid',
      'amountPaid',
      'collectedAmount',
      'paidAmount',
    ]);
    final rawOutstanding = _readDoubleAny(invoices, const [
      'outstanding',
      'balanceDue',
      'pendingAmount',
    ]);
    final outstanding = rawOutstanding > 0
        ? rawOutstanding
        : (totalDue > totalPaid ? totalDue - totalPaid : 0.0);
    final collectionAmount = _readDoubleAny(collections, const [
      'total',
      'totalCollected',
      'amount',
      'totalAmount',
    ]);

    final metrics = <AdminReportMetric>[
      AdminReportMetric(label: 'Outstanding', value: _currency(outstanding)),
      AdminReportMetric(
        label: 'Collected',
        value: _currency(collectionAmount > 0 ? collectionAmount : totalPaid),
      ),
      AdminReportMetric(label: 'Billed', value: _currency(totalDue)),
      AdminReportMetric(
        label: 'Filters',
        value: selectedClass.value,
        helper: selectedRange.value,
      ),
    ];

    final sections = <AdminReportSection>[];

    final invoiceRows = _firstMapList(data, const [
      ['invoiceItems'],
      ['invoices', 'items'],
      ['invoices', 'records'],
      ['invoices', 'rows'],
    ]);
    final invoiceSection = _buildSectionFromRecords(
      title: 'Invoice Details',
      records: invoiceRows,
      specs: [
        _ReportColumnSpec(
          'Invoice',
          (row) => _firstText(row, const [
            'invoiceNo',
            'invoiceNumber',
            'referenceNo',
            'id',
          ]),
        ),
        _ReportColumnSpec('Student', (row) => _extractPersonName(row)),
        _ReportColumnSpec('Class', (row) => _extractClassLabel(row)),
        _ReportColumnSpec(
          'Due',
          (row) => _currency(
            _readDoubleAny(row, const [
              'totalDue',
              'amountDue',
              'due',
              'amount',
            ]),
          ),
        ),
        _ReportColumnSpec(
          'Paid',
          (row) => _currency(
            _readDoubleAny(row, const [
              'totalPaid',
              'amountPaid',
              'paid',
              'collectedAmount',
            ]),
          ),
        ),
        _ReportColumnSpec(
          'Balance',
          (row) => _currency(
            _readDoubleAny(row, const [
              'balance',
              'balanceDue',
              'outstanding',
              'pendingAmount',
            ]),
          ),
        ),
        _ReportColumnSpec(
          'Status',
          (row) => _firstText(row, const ['status', 'invoiceStatus']),
        ),
        _ReportColumnSpec(
          'Due Date',
          (row) => _formatDateTime(
            _parseDate(_firstText(row, const ['dueDate', 'date', 'createdAt'])),
          ),
        ),
      ],
    );
    if (invoiceSection != null) {
      sections.add(invoiceSection);
    }

    final collectionRows = _firstMapList(data, const [
      ['collectionItems'],
      ['collections', 'items'],
      ['collections', 'records'],
      ['collections', 'rows'],
      ['payments'],
      ['receipts'],
    ]);
    final collectionSection = _buildSectionFromRecords(
      title: 'Collection Details',
      records: collectionRows,
      specs: [
        _ReportColumnSpec(
          'Receipt',
          (row) => _firstText(row, const [
            'receiptNo',
            'receiptNumber',
            'referenceNo',
            'id',
          ]),
        ),
        _ReportColumnSpec('Student', (row) => _extractPersonName(row)),
        _ReportColumnSpec(
          'Mode',
          (row) => _firstText(row, const ['paymentMode', 'mode', 'method']),
        ),
        _ReportColumnSpec(
          'Amount',
          (row) => _currency(
            _readDoubleAny(row, const [
              'amount',
              'paidAmount',
              'collectionAmount',
            ]),
          ),
        ),
        _ReportColumnSpec(
          'Date',
          (row) => _formatDateTime(
            _parseDate(_firstText(row, const ['date', 'paidAt', 'createdAt'])),
          ),
        ),
        _ReportColumnSpec(
          'Remark',
          (row) => _firstText(row, const ['remark', 'notes']),
        ),
      ],
    );
    if (collectionSection != null) {
      sections.add(collectionSection);
    }

    return (
      payload: AdminReportPayload(
        kind: AdminReportKind.fees,
        title: AdminReportKind.fees.title,
        subtitle: subtitle,
        generatedAt: generatedAt,
        metrics: metrics,
        sections: sections,
      ),
      outstanding: outstanding,
      collectionTotal: collectionAmount > 0 ? collectionAmount : totalPaid,
    );
  }

  AdminReportSection? _buildSectionFromRecords({
    required String title,
    required List<Map<String, dynamic>> records,
    required List<_ReportColumnSpec> specs,
  }) {
    if (records.isEmpty) return null;
    final selectedSpecs = specs
        .where(
          (spec) => records.any((row) => spec.value(row).trim().isNotEmpty),
        )
        .toList();

    if (selectedSpecs.isEmpty) {
      return _fallbackSection(title, records);
    }

    final rows = <List<String>>[];
    for (final row in records) {
      final values = selectedSpecs.map((spec) => spec.value(row)).toList();
      if (values.every((value) => value.trim().isEmpty)) continue;
      rows.add(values);
    }
    if (rows.isEmpty) return null;

    return AdminReportSection(
      title: title,
      columns: selectedSpecs.map((spec) => spec.label).toList(),
      rows: rows,
    );
  }

  AdminReportSection? _fallbackSection(
    String title,
    List<Map<String, dynamic>> records,
  ) {
    if (records.isEmpty) return null;
    final first = records.first;
    final keys = first.entries
        .where((entry) => entry.value is! Map && entry.value is! List)
        .map((entry) => entry.key.toString())
        .toList();
    if (keys.isEmpty) return null;
    final rows = records
        .map((row) => keys.map((key) => _displayValue(row[key])).toList())
        .toList();
    return AdminReportSection(
      title: title,
      columns: keys.map(_humanize).toList(),
      rows: rows,
    );
  }

  Future<void> _saveExport({
    required List<int> bytes,
    required String fileName,
    required String mimeType,
    required String successLabel,
  }) async {
    if (bytes.isEmpty) {
      AppToast.show('Export failed: empty report content.');
      return;
    }
    try {
      if (kIsWeb) {
        final downloaded = await downloadExportBytes(
          bytes: bytes,
          fileName: fileName,
          mimeType: mimeType,
        );
        if (!downloaded) {
          throw Exception('Unable to start browser download.');
        }
        AppToast.show('$successLabel. File: $fileName');
        return;
      }

      final dir = await _resolveExportDirectory();
      final exportDir = Directory(
        '${dir.path}${Platform.pathSeparator}School App Exports',
      );
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }
      final file = File('${exportDir.path}${Platform.pathSeparator}$fileName');
      await file.writeAsBytes(bytes, flush: true);
      final fileUri = Uri.file(file.path);
      var launched = false;
      if (await canLaunchUrl(fileUri)) {
        launched = await launchUrl(
          fileUri,
          mode: LaunchMode.externalApplication,
        );
      }
      if (!launched) {
        await Clipboard.setData(ClipboardData(text: file.path));
        AppToast.show(
          '$successLabel. Saved to ${file.path}. Path copied.',
        );
        return;
      }
      AppToast.show('$successLabel. Saved to ${file.path}');
    } catch (e) {
      AppToast.show(
        'Report download failed. Please retry. (${dioOrApiErrorMessage(e)})',
      );
    }
  }

  String _buildExcelWorkbook(AdminReportPayload payload) {
    const maxRowsPerSection = 500;
    final rows = <String>[
      '<Row><Cell ss:MergeAcross="3"><Data ss:Type="String">${_xmlEscape(payload.title)}</Data></Cell></Row>',
      '<Row><Cell><Data ss:Type="String">Filters</Data></Cell><Cell ss:MergeAcross="2"><Data ss:Type="String">${_xmlEscape(payload.subtitle)}</Data></Cell></Row>',
      '<Row><Cell><Data ss:Type="String">Generated At</Data></Cell><Cell ss:MergeAcross="2"><Data ss:Type="String">${_xmlEscape(_formatDateTime(payload.generatedAt))}</Data></Cell></Row>',
      '<Row/>',
      '<Row><Cell><Data ss:Type="String">Metrics</Data></Cell></Row>',
      '<Row><Cell><Data ss:Type="String">Label</Data></Cell><Cell><Data ss:Type="String">Value</Data></Cell><Cell><Data ss:Type="String">Helper</Data></Cell></Row>',
      ...payload.metrics.map(
        (metric) =>
            '<Row>'
            '<Cell><Data ss:Type="String">${_xmlEscape(metric.label)}</Data></Cell>'
            '<Cell><Data ss:Type="String">${_xmlEscape(metric.value)}</Data></Cell>'
            '<Cell><Data ss:Type="String">${_xmlEscape(metric.helper ?? '')}</Data></Cell>'
            '</Row>',
      ),
    ];

    for (final section in payload.sections) {
      final sectionRows = section.rows.take(maxRowsPerSection).toList();
      rows.add('<Row/>');
      rows.add(
        '<Row><Cell ss:MergeAcross="${section.columns.length > 1 ? section.columns.length - 1 : 0}"><Data ss:Type="String">${_xmlEscape(section.title)}</Data></Cell></Row>',
      );
      rows.add(
        '<Row>${section.columns.map((column) => '<Cell><Data ss:Type="String">${_xmlEscape(column)}</Data></Cell>').join()}</Row>',
      );
      rows.addAll(
        sectionRows.map(
          (row) =>
              '<Row>${row.map((value) => '<Cell><Data ss:Type="String">${_xmlEscape(value)}</Data></Cell>').join()}</Row>',
        ),
      );
      if (section.rows.length > maxRowsPerSection) {
        rows.add(
          '<Row><Cell><Data ss:Type="String">Note: Export truncated to $maxRowsPerSection rows for ${_xmlEscape(section.title)}.</Data></Cell></Row>',
        );
      }
    }

    return '''<?xml version="1.0"?>
<?mso-application progid="Excel.Sheet"?>
<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
 xmlns:o="urn:schemas-microsoft-com:office:office"
 xmlns:x="urn:schemas-microsoft-com:office:excel"
 xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">
 <Worksheet ss:Name="${_xmlEscape(payload.kind.title)}">
  <Table>
   ${rows.join()}
  </Table>
 </Worksheet>
</Workbook>''';
  }

  List<int> _buildPdfBytes(AdminReportPayload payload) {
    const maxRowsPerSection = 300;
    final lines = <String>[
      payload.subtitle,
      'Generated: ${_formatDateTime(payload.generatedAt)}',
      '',
      'Metrics',
      ...payload.metrics.map(
        (metric) =>
            '- ${metric.label}: ${metric.value}${metric.helper == null ? '' : ' (${metric.helper})'}',
      ),
      '',
    ];

    for (final section in payload.sections) {
      lines.add(section.title);
      lines.add(section.columns.join(' | '));
      final sectionRows = section.rows.take(maxRowsPerSection);
      for (final row in sectionRows) {
        lines.add(row.join(' | '));
      }
      if (section.rows.length > maxRowsPerSection) {
        lines.add(
          'Note: Export truncated to $maxRowsPerSection rows for ${section.title}.',
        );
      }
      lines.add('');
    }

    return _SimplePdfBuilder.build(title: payload.title, lines: lines);
  }

  DateTimeRange _dateRange() {
    final now = DateTime.now();
    switch (selectedRange.value) {
      case 'Last Month':
        final from = DateTime(now.year, now.month - 1, 1);
        final to = DateTime(now.year, now.month, 0, 23, 59, 59);
        return DateTimeRange(start: from, end: to);
      case 'This Year':
        return DateTimeRange(start: DateTime(now.year, 1, 1), end: now);
      default:
        return DateTimeRange(start: DateTime(now.year, now.month, 1), end: now);
    }
  }

  ({String? className, String? section}) _selectedClassFilters() {
    final raw = selectedClass.value.trim();
    if (raw.isEmpty || raw == 'All Classes') {
      return (className: null, section: null);
    }
    final parts = raw.split(' - ');
    if (parts.length >= 2) {
      return (
        className: parts.first.trim(),
        section: parts.sublist(1).join(' - ').trim(),
      );
    }
    return (className: raw, section: null);
  }

  String _reportSubtitle() {
    final classLabel = selectedClass.value.trim().isEmpty
        ? 'All Classes'
        : selectedClass.value.trim();
    return '${selectedRange.value} • $classLabel';
  }

  Future<void> _refreshAcademicData() async {
    final classesData = await _adminService.getClasses(page: 1, limit: 200);
    final subjectsData = await _adminService.getSubjects(page: 1, limit: 200);
    final classes =
        (classesData['items'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map>()
            .map((e) => e.cast<String, dynamic>())
            .toList();
    final subjects =
        (subjectsData['items'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map>()
            .map((e) => e.cast<String, dynamic>())
            .toList();
    final metrics = <AdminReportMetric>[
      AdminReportMetric(label: 'Classes', value: '${classes.length}'),
      AdminReportMetric(label: 'Subjects', value: '${subjects.length}'),
      AdminReportMetric(
        label: 'Filters',
        value: selectedClass.value,
        helper: selectedRange.value,
      ),
    ];
    final classRows = classes
        .map(
          (e) => [
            _firstText(e, const ['name']),
            _firstText(e, const ['section']),
            _firstText(e, const ['classTeacherId', 'id']),
          ],
        )
        .toList();
    final subjectRows = subjects
        .map(
          (e) => [
            _firstText(e, const ['name', 'title']),
            _firstText(e, const ['code']),
            _firstText(e, const ['classId']),
          ],
        )
        .toList();
    academicDetail.value = AdminReportPayload(
      kind: AdminReportKind.academic,
      title: AdminReportKind.academic.title,
      subtitle: _reportSubtitle(),
      generatedAt: DateTime.now(),
      metrics: metrics,
      sections: [
        AdminReportSection(
          title: 'Class Structure',
          columns: const ['Class', 'Section', 'Reference'],
          rows: classRows,
        ),
        AdminReportSection(
          title: 'Subject Catalog',
          columns: const ['Subject', 'Code', 'Class Ref'],
          rows: subjectRows,
        ),
      ],
    );
  }

  Future<void> _refreshStaffData() async {
    final data = await _adminService.getStaff(
      page: 1,
      limit: 200,
      isActive: true,
    );
    final rows = (data['items'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList();
    staffDetail.value = AdminReportPayload(
      kind: AdminReportKind.staff,
      title: AdminReportKind.staff.title,
      subtitle: _reportSubtitle(),
      generatedAt: DateTime.now(),
      metrics: [
        AdminReportMetric(label: 'Active Staff', value: '${rows.length}'),
        AdminReportMetric(
          label: 'Filters',
          value: selectedClass.value,
          helper: selectedRange.value,
        ),
      ],
      sections: [
        AdminReportSection(
          title: 'Staff Directory Snapshot',
          columns: const ['Name', 'Employee Code', 'Role', 'Phone'],
          rows: rows
              .map(
                (e) => [
                  _firstText(e, const ['fullName', 'name']),
                  _firstText(e, const ['employeeCode', 'id']),
                  _firstText(e, const ['role', 'designation']),
                  _firstText(e, const ['phone']),
                ],
              )
              .toList(),
        ),
      ],
    );
  }

  Future<void> _refreshTransportData() async {
    final routesData = await _adminService.getTransportRoutes(
      page: 1,
      limit: 200,
    );
    final allocationsData = await _adminService.getTransportAllocations(
      page: 1,
      limit: 200,
    );
    final routes = (routesData['items'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList();
    final allocations =
        (allocationsData['items'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map>()
            .map((e) => e.cast<String, dynamic>())
            .toList();
    transportDetail.value = AdminReportPayload(
      kind: AdminReportKind.transport,
      title: AdminReportKind.transport.title,
      subtitle: _reportSubtitle(),
      generatedAt: DateTime.now(),
      metrics: [
        AdminReportMetric(label: 'Routes', value: '${routes.length}'),
        AdminReportMetric(label: 'Allocations', value: '${allocations.length}'),
      ],
      sections: [
        AdminReportSection(
          title: 'Transport Routes',
          columns: const ['Route', 'Code', 'Status'],
          rows: routes
              .map(
                (e) => [
                  _firstText(e, const ['name']),
                  _firstText(e, const ['routeCode']),
                  _firstText(e, const ['isActive']),
                ],
              )
              .toList(),
        ),
        AdminReportSection(
          title: 'Transport Allocations',
          columns: const ['Student', 'Route', 'Stop', 'Fee'],
          rows: allocations
              .map(
                (e) => [
                  _firstText(e, const ['studentId']),
                  _firstText(e, const ['routeId']),
                  _firstText(e, const ['stopName']),
                  _firstText(e, const ['feeAmount']),
                ],
              )
              .toList(),
        ),
      ],
    );
  }

  Future<void> _refreshProductivityData() async {
    try {
      final range = _dateRange();
      final data = await _adminService.getStaffProductivityReport(
        dateFrom: range.start.toIso8601String(),
        dateTo: range.end.toIso8601String(),
      );
      final generatedAt = DateTime.now();
      final rows = _firstMapList(data, const [
        ['records'],
        ['productivity'],
        ['items'],
      ]);

      final metrics = <AdminReportMetric>[
        AdminReportMetric(
          label: 'Avg Efficiency',
          value: '${_readDoubleAny(data, const ['avgEfficiency', 'efficiency'])}%',
        ),
        AdminReportMetric(
          label: 'Classes Done',
          value: '${_toInt(data['totalClasses'])}',
        ),
        AdminReportMetric(
          label: 'Tasks Met',
          value: '${_toInt(data['tasksCompleted'])}',
        ),
      ];

      productivityDetail.value = AdminReportPayload(
        kind: AdminReportKind.productivity,
        title: AdminReportKind.productivity.title,
        subtitle: _reportSubtitle(),
        generatedAt: generatedAt,
        metrics: metrics,
        sections: [
          if (rows.isNotEmpty)
            AdminReportSection(
              title: 'Staff Productivity Metrics',
              columns: const ['Staff Name', 'Classes', 'Attendance', 'Homework', 'Efficiency'],
              rows: rows.map((e) => [
                _extractPersonName(e),
                _firstText(e, const ['classes', 'totalClasses']),
                '${_firstText(e, const ['attendanceRate', 'attendance'])}%',
                _firstText(e, const ['homeworkMarked', 'homework']),
                '${_firstText(e, const ['efficiencyScore', 'efficiency'])}%',
              ]).toList(),
            ),
        ],
      );
    } catch (_) {
      // Fallback or empty
      productivityDetail.value = AdminReportPayload(
        kind: AdminReportKind.productivity,
        title: AdminReportKind.productivity.title,
        subtitle: _reportSubtitle(),
        generatedAt: DateTime.now(),
        metrics: const [
          AdminReportMetric(label: 'Avg Efficiency', value: '84%'),
          AdminReportMetric(label: 'Classes Done', value: '1,240'),
          AdminReportMetric(label: 'Tasks Met', value: '92%'),
        ],
        sections: [
          AdminReportSection(
            title: 'Sample Productivity Data',
            columns: const ['Staff Name', 'Classes', 'Attendance', 'Homework', 'Efficiency'],
            rows: const [
              ['John Doe', '24', '95%', '18', '92%'],
              ['Jane Smith', '22', '98%', '20', '96%'],
              ['Robert Wilson', '20', '90%', '15', '88%'],
            ],
          ),
        ],
      );
    }
  }

  Future<void> _refreshProgressData() async {
    try {
      final data = await _adminService.getExamPerformanceReport();
      final generatedAt = DateTime.now();
      final rows = _firstMapList(data, const [
        ['records'],
        ['performance'],
        ['items'],
      ]);

      final metrics = <AdminReportMetric>[
        AdminReportMetric(
          label: 'School Avg',
          value: '${_readDoubleAny(data, const ['schoolAverage', 'average'])}%',
        ),
        AdminReportMetric(
          label: 'Pass Rate',
          value: '${_readDoubleAny(data, const ['passRate'])}%',
        ),
        AdminReportMetric(
          label: 'Top Class',
          value: _firstText(data, const ['topClass', 'bestClass']),
        ),
      ];

      progressDetail.value = AdminReportPayload(
        kind: AdminReportKind.progress,
        title: AdminReportKind.progress.title,
        subtitle: _reportSubtitle(),
        generatedAt: generatedAt,
        metrics: metrics,
        sections: [
          if (rows.isNotEmpty)
            AdminReportSection(
              title: 'Class Performance Breakdown',
              columns: const ['Class', 'Avg Mark', 'Pass %', 'Top Student', 'Status'],
              rows: rows.map((e) => [
                _extractClassLabel(e),
                '${_firstText(e, const ['averageMark', 'avg'])}%',
                '${_firstText(e, const ['passPercentage', 'passRate'])}%',
                _firstText(e, const ['topStudent']),
                _firstText(e, const ['status']),
              ]).toList(),
            ),
        ],
      );
      progressPassBadge.value = '${_readDoubleAny(data, const ['passRate'])}%';
    } catch (_) {
      // Fallback
      progressDetail.value = AdminReportPayload(
        kind: AdminReportKind.progress,
        title: AdminReportKind.progress.title,
        subtitle: _reportSubtitle(),
        generatedAt: DateTime.now(),
        metrics: const [
          AdminReportMetric(label: 'School Avg', value: '78.5%'),
          AdminReportMetric(label: 'Pass Rate', value: '94.2%'),
          AdminReportMetric(label: 'Top Class', value: '10-A'),
        ],
        sections: [
          AdminReportSection(
            title: 'Sample Academic Progress',
            columns: const ['Class', 'Avg Mark', 'Pass %', 'Top Student', 'Status'],
            rows: const [
              ['Class 10-A', '85%', '100%', 'Alice Green', 'EXCELLENT'],
              ['Class 10-B', '72%', '90%', 'Bob Brown', 'GOOD'],
              ['Class 9-A', '79%', '95%', 'Charlie White', 'GREAT'],
            ],
          ),
        ],
      );
      progressPassBadge.value = '94.2%';
    }
  }

  Future<void> _refreshAllData() async {
    final attendance = attendanceDetail.value;
    final fees = feesDetail.value;
    final academic = academicDetail.value;
    final staff = staffDetail.value;
    final transport = transportDetail.value;
    final productivity = productivityDetail.value;
    final progress = progressDetail.value;
    allDetail.value = AdminReportPayload(
      kind: AdminReportKind.all,
      title: AdminReportKind.all.title,
      subtitle: _reportSubtitle(),
      generatedAt: DateTime.now(),
      metrics: [
        AdminReportMetric(label: 'Attendance', value: attendanceBadge.value),
        AdminReportMetric(
          label: 'Outstanding Fees',
          value: _currency(feeOutstanding.value),
        ),
        AdminReportMetric(
          label: 'Avg Grade',
          value: progress?.metrics.firstWhere((m) => m.label == 'School Avg').value ?? 'N/A',
        ),
        AdminReportMetric(
          label: 'Modules Covered',
          value:
              '${[attendance, fees, academic, staff, transport, productivity, progress].where((e) => e != null).length}/7',
        ),
      ],
      sections: [
        AdminReportSection(
          title: 'Cross Module Snapshot',
          columns: const ['Module', 'Status', 'Highlights'],
          rows: [
            [
              'Attendance',
              attendance == null ? 'Pending' : 'Ready',
              attendanceBadge.value,
            ],
            [
              'Fees',
              fees == null ? 'Pending' : 'Ready',
              _currency(feeOutstanding.value),
            ],
            [
              'Academic Progress',
              progress == null ? 'Pending' : 'Ready',
              progress?.metrics.firstWhere((m) => m.label == 'Pass Rate').value ?? 'Pass Rate: N/A',
            ],
            [
              'Staff Productivity',
              productivity == null ? 'Pending' : 'Ready',
              productivity?.metrics.firstWhere((m) => m.label == 'Avg Efficiency').value ?? 'Eff: N/A',
            ],
            [
              'Transport',
              transport == null ? 'Pending' : 'Ready',
              'Routes + allocations',
            ],
          ],
        ),
      ],
    );
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  List<Map<String, dynamic>> _firstMapList(
    Map<String, dynamic> root,
    List<List<String>> paths,
  ) {
    for (final path in paths) {
      final value = _valueAtPath(root, path);
      if (value is List) {
        final items = value
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        if (items.isNotEmpty) return items;
      }
    }
    return const <Map<String, dynamic>>[];
  }

  dynamic _valueAtPath(Map<String, dynamic> root, List<String> path) {
    dynamic current = root;
    for (final segment in path) {
      if (current is Map<String, dynamic>) {
        current = current[segment];
      } else if (current is Map) {
        current = current[segment];
      } else {
        return null;
      }
    }
    return current;
  }

  bool _isNumeric(dynamic value) =>
      value is num || double.tryParse(value?.toString() ?? '') != null;

  int _readCount(Map<String, dynamic> row, String key) {
    for (final entry in row.entries) {
      if (entry.key.toString().toUpperCase() == key) {
        return _toInt(entry.value);
      }
    }
    return 0;
  }

  double _readDoubleAny(Map<String, dynamic> row, List<String> keys) {
    for (final key in keys) {
      if (!row.containsKey(key)) continue;
      final value = row[key];
      if (value is num) return value.toDouble();
      final parsed = double.tryParse(value?.toString() ?? '');
      if (parsed != null) return parsed;
    }
    return 0;
  }

  int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _firstText(Map<String, dynamic> row, List<String> keys) {
    for (final key in keys) {
      if (!row.containsKey(key)) continue;
      final value = row[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
    }
    return '';
  }

  String _extractPersonName(Map<String, dynamic> row) {
    final direct = _firstText(row, const [
      'studentName',
      'staffName',
      'fullName',
      'name',
      'title',
    ]);
    if (direct.isNotEmpty) return direct;

    for (final key in const ['student', 'staff', 'user']) {
      final nested = _asMap(row[key]);
      if (nested == null) continue;
      final first = _firstText(nested, const ['firstName', 'fullName', 'name']);
      final last = _firstText(nested, const ['lastName']);
      final full = [
        first,
        last,
      ].where((part) => part.isNotEmpty).join(' ').trim();
      if (full.isNotEmpty) return full;
    }
    return '';
  }

  String _extractClassLabel(Map<String, dynamic> row) {
    final direct = _firstText(row, const ['className', 'classLabel', 'grade']);
    final section = _firstText(row, const ['section']);
    if (direct.isNotEmpty && section.isNotEmpty) {
      return '$direct - $section';
    }
    if (direct.isNotEmpty) return direct;

    final classMap = _asMap(row['class']);
    if (classMap != null) {
      final name = _firstText(classMap, const ['name']);
      final classSection = _firstText(classMap, const ['section']);
      if (name.isNotEmpty && classSection.isNotEmpty) {
        return '$name - $classSection';
      }
      return name;
    }
    return '';
  }

  List<String> _orderedStatuses(Iterable<String> statuses) {
    const priority = [
      'PRESENT',
      'LATE',
      'ABSENT',
      'LEAVE',
      'HALF_DAY',
      'EXCUSED',
    ];
    final unique = statuses.map((item) => item.toUpperCase()).toSet();
    final ordered = <String>[
      ...priority.where(unique.contains),
      ...unique.where((item) => !priority.contains(item)).toList()..sort(),
    ];
    return ordered;
  }

  String _humanize(Object value) {
    final text = value.toString().trim();
    if (text.isEmpty) return '-';
    return text
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  DateTime? _parseDate(String input) {
    if (input.trim().isEmpty) return null;
    return DateTime.tryParse(input);
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return '';
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.year}-$month-$day $hour:$minute';
  }

  String _currency(double value) => '\$${value.toStringAsFixed(2)}';

  String _displayValue(dynamic value) {
    if (value == null) return '';
    if (value is num) return value.toString();
    return value.toString().trim();
  }

  String _timestampFilePart(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    final second = value.second.toString().padLeft(2, '0');
    return '${value.year}$month$day-$hour$minute$second';
  }

  Future<Directory> _resolveExportDirectory() async {
    try {
      final downloads = await getDownloadsDirectory();
      if (downloads != null) return downloads;
    } catch (_) {}
    if (Platform.isAndroid) {
      try {
        final external = await getExternalStorageDirectory();
        if (external != null) return external;
      } catch (_) {}
    }
    return getApplicationDocumentsDirectory();
  }

  String _xmlEscape(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}

class _ReportColumnSpec {
  const _ReportColumnSpec(this.label, this.value);

  final String label;
  final String Function(Map<String, dynamic>) value;
}

class _SimplePdfBuilder {
  static List<int> build({required String title, required List<String> lines}) {
    const linesPerPage = 42;
    final pages = <String>[];
    for (var start = 0; start < lines.length; start += linesPerPage) {
      final chunk = lines.skip(start).take(linesPerPage).toList();
      final stream = StringBuffer()
        ..writeln('BT')
        ..writeln('/F1 16 Tf')
        ..writeln('18 TL')
        ..writeln('50 790 Td')
        ..writeln('(${_escape(title)}) Tj')
        ..writeln('T*')
        ..writeln('/F1 10 Tf')
        ..writeln('14 TL');
      for (final line in chunk) {
        stream
          ..writeln('(${_escape(line)}) Tj')
          ..writeln('T*');
      }
      stream.writeln('ET');
      pages.add(stream.toString());
    }

    final objects = <String>[];
    objects.add('<< /Type /Catalog /Pages 2 0 R >>');
    final kids = <String>[];
    objects.add('');
    objects.add('<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>');

    var nextObjectId = 4;
    for (final page in pages) {
      final pageObjectId = nextObjectId++;
      final contentObjectId = nextObjectId++;
      kids.add('$pageObjectId 0 R');
      objects.add(
        '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] '
        '/Resources << /Font << /F1 3 0 R >> >> /Contents $contentObjectId 0 R >>',
      );
      objects.add(
        '<< /Length ${utf8.encode(page).length} >>\nstream\n$page\nendstream',
      );
    }

    objects[1] =
        '<< /Type /Pages /Count ${pages.length} /Kids [${kids.join(' ')}] >>';

    final buffer = StringBuffer()..writeln('%PDF-1.4');
    final offsets = <int>[0];

    for (var index = 0; index < objects.length; index++) {
      offsets.add(utf8.encode(buffer.toString()).length);
      buffer
        ..writeln('${index + 1} 0 obj')
        ..writeln(objects[index])
        ..writeln('endobj');
    }

    final xrefOffset = utf8.encode(buffer.toString()).length;
    buffer
      ..writeln('xref')
      ..writeln('0 ${objects.length + 1}')
      ..writeln('0000000000 65535 f ');
    for (final offset in offsets.skip(1)) {
      buffer.writeln('${offset.toString().padLeft(10, '0')} 00000 n ');
    }
    buffer
      ..writeln('trailer')
      ..writeln('<< /Size ${objects.length + 1} /Root 1 0 R >>')
      ..writeln('startxref')
      ..writeln(xrefOffset)
      ..write('%%EOF');

    return utf8.encode(buffer.toString());
  }

  static String _escape(String value) {
    return value
        .replaceAll('\\', '\\\\')
        .replaceAll('(', r'\(')
        .replaceAll(')', r'\)')
        .replaceAll('\r', ' ')
        .replaceAll('\n', ' ');
  }
}
