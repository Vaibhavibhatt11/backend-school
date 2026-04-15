import 'dart:convert';
import 'dart:io';

import 'package:erp_frontend/app/modules/admin/models/admin_report_models.dart';
import 'package:erp_frontend/app/modules/admin/views/admin_report_detail_view.dart';
import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final attendanceDetailError = ''.obs;
  final feesDetailError = ''.obs;
  final isAttendanceDetailLoading = false.obs;
  final isFeesDetailLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadReports();
  }

  Future<void> loadReports() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await Future.wait([
        _loadClasses(),
        _refreshAttendanceData(),
        _refreshFeesData(),
      ]);
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
    final pct = total > 0 ? (((built.present + built.late) / total) * 100).round() : 0;
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

  void onViewDetailedLog() {
    Get.to(() => const AdminReportDetailView(kind: AdminReportKind.attendance));
  }

  void onCollectionAnalysis() {
    Get.to(() => const AdminReportDetailView(kind: AdminReportKind.fees));
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
    final fileName = '${payload.kind.fileStem}-${_timestampFilePart(payload.generatedAt)}.pdf';
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
    final fileName = '${payload.kind.fileStem}-${_timestampFilePart(payload.generatedAt)}.xls';
    await _saveExport(
      bytes: utf8.encode(workbook),
      fileName: fileName,
      mimeType: 'application/vnd.ms-excel',
      textPayload: workbook,
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
      }
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
      return null;
    }
  }

  ({
    AdminReportPayload payload,
    int present,
    int late,
    int absent,
  }) _buildAttendancePayload(Map<String, dynamic> data) {
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

    final attendanceRecords = _firstMapList(
      data,
      const [
        ['records'],
        ['attendance'],
        ['items'],
        ['rows'],
        ['logs'],
      ],
    );

    if (present == 0 && late == 0 && absent == 0 && attendanceRecords.isNotEmpty) {
      for (final row in attendanceRecords) {
        final status = _firstText(
          row,
          const ['status', 'attendanceStatus', 'state'],
        ).toUpperCase();
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
      AdminReportMetric(
        label: 'Present',
        value: '$present',
      ),
      AdminReportMetric(
        label: 'Late',
        value: '$late',
      ),
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
          columns: [
            'Group',
            ...orderedStatuses.map(_humanize),
            'Total',
          ],
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
              _firstText(
                row,
                const ['date', 'attendanceDate', 'createdAt', 'updatedAt'],
              ),
            ),
          ),
        ),
        _ReportColumnSpec(
          'Name',
          (row) => _extractPersonName(row),
        ),
        _ReportColumnSpec(
          'ID',
          (row) => _firstText(
            row,
            const ['admissionNo', 'employeeCode', 'studentId', 'staffId', 'id'],
          ),
        ),
        _ReportColumnSpec(
          'Class',
          (row) => _extractClassLabel(row),
        ),
        _ReportColumnSpec(
          'Status',
          (row) => _firstText(
            row,
            const ['status', 'attendanceStatus', 'state'],
          ),
        ),
        _ReportColumnSpec(
          'In Time',
          (row) => _firstText(
            row,
            const ['inTime', 'checkInAt', 'checkInTime'],
          ),
        ),
        _ReportColumnSpec(
          'Out Time',
          (row) => _firstText(
            row,
            const ['outTime', 'checkOutAt', 'checkOutTime'],
          ),
        ),
        _ReportColumnSpec(
          'Remark',
          (row) => _firstText(
            row,
            const ['remark', 'notes', 'reason'],
          ),
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

  ({
    AdminReportPayload payload,
    double outstanding,
    double collectionTotal,
  }) _buildFeesPayload(Map<String, dynamic> data) {
    final generatedAt = DateTime.now();
    final subtitle = _reportSubtitle();
    final invoices = _asMap(data['invoices']) ?? const <String, dynamic>{};
    final collections = _asMap(data['collections']) ?? const <String, dynamic>{};
    final totalDue = _readDoubleAny(
      invoices,
      const ['totalDue', 'amountDue', 'grandTotal', 'totalAmount'],
    );
    final totalPaid = _readDoubleAny(
      invoices,
      const ['totalPaid', 'amountPaid', 'collectedAmount', 'paidAmount'],
    );
    final rawOutstanding = _readDoubleAny(
      invoices,
      const ['outstanding', 'balanceDue', 'pendingAmount'],
    );
    final outstanding = rawOutstanding > 0
        ? rawOutstanding
        : (totalDue > totalPaid ? totalDue - totalPaid : 0.0);
    final collectionAmount = _readDoubleAny(
      collections,
      const ['total', 'totalCollected', 'amount', 'totalAmount'],
    );

    final metrics = <AdminReportMetric>[
      AdminReportMetric(
        label: 'Outstanding',
        value: _currency(outstanding),
      ),
      AdminReportMetric(
        label: 'Collected',
        value: _currency(collectionAmount > 0 ? collectionAmount : totalPaid),
      ),
      AdminReportMetric(
        label: 'Billed',
        value: _currency(totalDue),
      ),
      AdminReportMetric(
        label: 'Filters',
        value: selectedClass.value,
        helper: selectedRange.value,
      ),
    ];

    final sections = <AdminReportSection>[];

    final invoiceRows = _firstMapList(
      data,
      const [
        ['invoiceItems'],
        ['invoices', 'items'],
        ['invoices', 'records'],
        ['invoices', 'rows'],
      ],
    );
    final invoiceSection = _buildSectionFromRecords(
      title: 'Invoice Details',
      records: invoiceRows,
      specs: [
        _ReportColumnSpec(
          'Invoice',
          (row) => _firstText(
            row,
            const ['invoiceNo', 'invoiceNumber', 'referenceNo', 'id'],
          ),
        ),
        _ReportColumnSpec(
          'Student',
          (row) => _extractPersonName(row),
        ),
        _ReportColumnSpec(
          'Class',
          (row) => _extractClassLabel(row),
        ),
        _ReportColumnSpec(
          'Due',
          (row) => _currency(
            _readDoubleAny(
              row,
              const ['totalDue', 'amountDue', 'due', 'amount'],
            ),
          ),
        ),
        _ReportColumnSpec(
          'Paid',
          (row) => _currency(
            _readDoubleAny(
              row,
              const ['totalPaid', 'amountPaid', 'paid', 'collectedAmount'],
            ),
          ),
        ),
        _ReportColumnSpec(
          'Balance',
          (row) => _currency(
            _readDoubleAny(
              row,
              const ['balance', 'balanceDue', 'outstanding', 'pendingAmount'],
            ),
          ),
        ),
        _ReportColumnSpec(
          'Status',
          (row) => _firstText(
            row,
            const ['status', 'invoiceStatus'],
          ),
        ),
        _ReportColumnSpec(
          'Due Date',
          (row) => _formatDateTime(
            _parseDate(
              _firstText(
                row,
                const ['dueDate', 'date', 'createdAt'],
              ),
            ),
          ),
        ),
      ],
    );
    if (invoiceSection != null) {
      sections.add(invoiceSection);
    }

    final collectionRows = _firstMapList(
      data,
      const [
        ['collectionItems'],
        ['collections', 'items'],
        ['collections', 'records'],
        ['collections', 'rows'],
        ['payments'],
        ['receipts'],
      ],
    );
    final collectionSection = _buildSectionFromRecords(
      title: 'Collection Details',
      records: collectionRows,
      specs: [
        _ReportColumnSpec(
          'Receipt',
          (row) => _firstText(
            row,
            const ['receiptNo', 'receiptNumber', 'referenceNo', 'id'],
          ),
        ),
        _ReportColumnSpec(
          'Student',
          (row) => _extractPersonName(row),
        ),
        _ReportColumnSpec(
          'Mode',
          (row) => _firstText(
            row,
            const ['paymentMode', 'mode', 'method'],
          ),
        ),
        _ReportColumnSpec(
          'Amount',
          (row) => _currency(
            _readDoubleAny(
              row,
              const ['amount', 'paidAmount', 'collectionAmount'],
            ),
          ),
        ),
        _ReportColumnSpec(
          'Date',
          (row) => _formatDateTime(
            _parseDate(
              _firstText(
                row,
                const ['date', 'paidAt', 'createdAt'],
              ),
            ),
          ),
        ),
        _ReportColumnSpec(
          'Remark',
          (row) => _firstText(
            row,
            const ['remark', 'notes'],
          ),
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
          (spec) => records.any(
            (row) => spec.value(row).trim().isNotEmpty,
          ),
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
    String? textPayload,
  }) async {
    try {
      if (kIsWeb) {
        final uri = textPayload != null
            ? Uri.dataFromString(textPayload, mimeType: mimeType, encoding: utf8)
            : Uri.dataFromBytes(bytes, mimeType: mimeType);
        final launched = await launchUrl(uri);
        if (!launched) {
          throw Exception('Unable to start download.');
        }
        AppToast.show(successLabel);
        return;
      }

      final dir = await _resolveExportDirectory();
      final exportDir = Directory('${dir.path}${Platform.pathSeparator}School App Exports');
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
        AppToast.show('$successLabel. Saved to ${file.path}');
        return;
      }
      AppToast.show('$successLabel. Saved to ${file.path}');
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  String _buildExcelWorkbook(AdminReportPayload payload) {
    final rows = <String>[
      '<Row><Cell ss:MergeAcross="3"><Data ss:Type="String">${_xmlEscape(payload.title)}</Data></Cell></Row>',
      '<Row><Cell><Data ss:Type="String">Filters</Data></Cell><Cell ss:MergeAcross="2"><Data ss:Type="String">${_xmlEscape(payload.subtitle)}</Data></Cell></Row>',
      '<Row><Cell><Data ss:Type="String">Generated At</Data></Cell><Cell ss:MergeAcross="2"><Data ss:Type="String">${_xmlEscape(_formatDateTime(payload.generatedAt))}</Data></Cell></Row>',
      '<Row/>',
      '<Row><Cell><Data ss:Type="String">Metrics</Data></Cell></Row>',
      '<Row><Cell><Data ss:Type="String">Label</Data></Cell><Cell><Data ss:Type="String">Value</Data></Cell><Cell><Data ss:Type="String">Helper</Data></Cell></Row>',
      ...payload.metrics.map(
        (metric) => '<Row>'
            '<Cell><Data ss:Type="String">${_xmlEscape(metric.label)}</Data></Cell>'
            '<Cell><Data ss:Type="String">${_xmlEscape(metric.value)}</Data></Cell>'
            '<Cell><Data ss:Type="String">${_xmlEscape(metric.helper ?? '')}</Data></Cell>'
            '</Row>',
      ),
    ];

    for (final section in payload.sections) {
      rows.add('<Row/>');
      rows.add(
        '<Row><Cell ss:MergeAcross="${section.columns.length > 1 ? section.columns.length - 1 : 0}"><Data ss:Type="String">${_xmlEscape(section.title)}</Data></Cell></Row>',
      );
      rows.add(
        '<Row>${section.columns.map((column) => '<Cell><Data ss:Type="String">${_xmlEscape(column)}</Data></Cell>').join()}</Row>',
      );
      rows.addAll(
        section.rows.map(
          (row) => '<Row>${row.map((value) => '<Cell><Data ss:Type="String">${_xmlEscape(value)}</Data></Cell>').join()}</Row>',
        ),
      );
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
    final lines = <String>[
      payload.subtitle,
      'Generated: ${_formatDateTime(payload.generatedAt)}',
      '',
      'Metrics',
      ...payload.metrics.map(
        (metric) => '- ${metric.label}: ${metric.value}${metric.helper == null ? '' : ' (${metric.helper})'}',
      ),
      '',
    ];

    for (final section in payload.sections) {
      lines.add(section.title);
      lines.add(section.columns.join(' | '));
      for (final row in section.rows) {
        lines.add(row.join(' | '));
      }
      lines.add('');
    }

    return _SimplePdfBuilder.build(
      title: payload.title,
      lines: lines,
    );
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
    final direct = _firstText(
      row,
      const ['studentName', 'staffName', 'fullName', 'name', 'title'],
    );
    if (direct.isNotEmpty) return direct;

    for (final key in const ['student', 'staff', 'user']) {
      final nested = _asMap(row[key]);
      if (nested == null) continue;
      final first = _firstText(nested, const ['firstName', 'fullName', 'name']);
      final last = _firstText(nested, const ['lastName']);
      final full = [first, last].where((part) => part.isNotEmpty).join(' ').trim();
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
        .map((part) => '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}')
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
  static List<int> build({
    required String title,
    required List<String> lines,
  }) {
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

    objects[1] = '<< /Type /Pages /Count ${pages.length} /Kids [${kids.join(' ')}] >>';

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
