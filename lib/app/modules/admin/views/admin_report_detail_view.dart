import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_reports_controller.dart';
import 'package:erp_frontend/app/modules/admin/models/admin_report_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminReportDetailView extends StatefulWidget {
  const AdminReportDetailView({
    super.key,
    required this.kind,
  });

  final AdminReportKind kind;

  @override
  State<AdminReportDetailView> createState() => _AdminReportDetailViewState();
}

class _AdminReportDetailViewState extends State<AdminReportDetailView> {
  late final AdminReportsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AdminReportsController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  Future<void> _refresh() {
    switch (widget.kind) {
      case AdminReportKind.attendance:
        return controller.loadAttendanceDetail(force: true);
      case AdminReportKind.fees:
        return controller.loadFeesDetail(force: true);
      case AdminReportKind.academic:
        return controller.loadAcademicDetail(force: true);
      case AdminReportKind.staff:
        return controller.loadStaffDetail(force: true);
      case AdminReportKind.transport:
        return controller.loadTransportDetail(force: true);
      case AdminReportKind.all:
        return controller.loadAllDetail(force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.kind.title),
        actions: [
          IconButton(
            tooltip: 'PDF Export',
            onPressed: () => controller.onPDFExport(widget.kind),
            icon: const Icon(Icons.picture_as_pdf_outlined),
          ),
          IconButton(
            tooltip: 'Excel Export',
            onPressed: () => controller.onExcelExport(widget.kind),
            icon: const Icon(Icons.table_view_outlined),
          ),
        ],
      ),
      body: Obx(() {
        final loading = switch (widget.kind) {
          AdminReportKind.attendance => controller.isAttendanceDetailLoading.value,
          AdminReportKind.fees => controller.isFeesDetailLoading.value,
          AdminReportKind.academic => controller.isAcademicDetailLoading.value,
          AdminReportKind.staff => controller.isStaffDetailLoading.value,
          AdminReportKind.transport => controller.isTransportDetailLoading.value,
          AdminReportKind.all => controller.isAllDetailLoading.value,
        };
        final error = switch (widget.kind) {
          AdminReportKind.attendance => controller.attendanceDetailError.value,
          AdminReportKind.fees => controller.feesDetailError.value,
          AdminReportKind.academic => '',
          AdminReportKind.staff => '',
          AdminReportKind.transport => '',
          AdminReportKind.all => '',
        };
        final payload = switch (widget.kind) {
          AdminReportKind.attendance => controller.attendanceDetail.value,
          AdminReportKind.fees => controller.feesDetail.value,
          AdminReportKind.academic => controller.academicDetail.value,
          AdminReportKind.staff => controller.staffDetail.value,
          AdminReportKind.transport => controller.transportDetail.value,
          AdminReportKind.all => controller.allDetail.value,
        };

        if (loading && payload == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.kind.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      payload?.subtitle ?? '${controller.selectedRange.value} • ${controller.selectedClass.value}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    if (payload != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Generated ${_formatDate(payload.generatedAt)}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              ),
              if (error.isNotEmpty && payload == null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Text(
                    error,
                    style: TextStyle(color: Colors.red.shade800),
                  ),
                ),
              ],
              if (payload != null) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: payload.metrics
                      .map(
                        (metric) => _MetricCard(metric: metric, isDark: isDark),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => controller.onPDFExport(widget.kind),
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        label: const Text('PDF Export'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => controller.onExcelExport(widget.kind),
                        icon: const Icon(Icons.table_view_outlined),
                        label: const Text('Excel Export'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (!payload.hasContent)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(payload.emptyMessage),
                  ),
                ...payload.sections.map(
                  (section) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _SectionTable(section: section, isDark: isDark),
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.year}-$month-$day $hour:$minute';
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.metric,
    required this.isDark,
  });

  final AdminReportMetric metric;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 164,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              metric.label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Text(
              metric.value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (metric.helper != null && metric.helper!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                metric.helper!,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTable extends StatelessWidget {
  const _SectionTable({
    required this.section,
    required this.isDark,
  });

  final AdminReportSection section;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: section.columns
                  .map((column) => DataColumn(label: Text(column)))
                  .toList(),
              rows: section.rows
                  .map(
                    (row) => DataRow(
                      cells: row
                          .map((value) => DataCell(Text(value.isEmpty ? '-' : value)))
                          .toList(),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
