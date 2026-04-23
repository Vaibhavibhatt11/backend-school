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
      case AdminReportKind.productivity:
        return controller.loadProductivityDetail(force: true);
      case AdminReportKind.progress:
        return controller.loadProgressDetail(force: true);
      case AdminReportKind.all:
        return controller.loadAllDetail(force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
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
          AdminReportKind.productivity => controller.isProductivityDetailLoading.value,
          AdminReportKind.progress => controller.isProgressDetailLoading.value,
          AdminReportKind.all => controller.isAllDetailLoading.value,
        };
        final error = switch (widget.kind) {
          AdminReportKind.attendance => controller.attendanceDetailError.value,
          AdminReportKind.fees => controller.feesDetailError.value,
          _ => '',
        };
        final payload = switch (widget.kind) {
          AdminReportKind.attendance => controller.attendanceDetail.value,
          AdminReportKind.fees => controller.feesDetail.value,
          AdminReportKind.academic => controller.academicDetail.value,
          AdminReportKind.staff => controller.staffDetail.value,
          AdminReportKind.transport => controller.transportDetail.value,
          AdminReportKind.productivity => controller.productivityDetail.value,
          AdminReportKind.progress => controller.progressDetail.value,
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
              _buildReportHeader(payload, isDark),
              if (error.isNotEmpty && payload == null) ...[
                const SizedBox(height: 16),
                _buildErrorCard(error),
              ],
              if (payload != null) ...[
                const SizedBox(height: 20),
                _buildMetricsGrid(payload, isDark),
                const SizedBox(height: 24),
                _buildActionButtons(isDark),
                const SizedBox(height: 24),
                if (!payload.hasContent)
                  _buildEmptyState(payload, isDark)
                else
                  ...payload.sections.map(
                    (section) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _SectionTable(section: section, isDark: isDark),
                    ),
                  ),
                const SizedBox(height: 60),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildReportHeader(AdminReportPayload? payload, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
              ? [AppColors.surfaceDark, AppColors.surfaceDark.withValues(alpha: 0.8)]
              : [Colors.white, Colors.white.withValues(alpha: 0.9)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.analytics_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.kind.title,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      payload?.subtitle ?? '${controller.selectedRange.value} • ${controller.selectedClass.value}',
                      style: TextStyle(color: isDark ? AppColors.textSecondaryDark : Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (payload != null) ...[
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'GENERATED AT',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: Colors.grey[500]),
                ),
                Text(
                  _formatDate(payload.generatedAt),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(AdminReportPayload payload, bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: payload.metrics.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, index) => _MetricCard(metric: payload.metrics[index], isDark: isDark),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            label: 'PDF Report',
            icon: Icons.picture_as_pdf_rounded,
            onTap: () => controller.onPDFExport(widget.kind),
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionButton(
            label: 'Excel Export',
            icon: Icons.table_chart_rounded,
            onTap: () => controller.onExcelExport(widget.kind),
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(error, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AdminReportPayload payload, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        children: [
          Icon(Icons.query_stats_rounded, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            payload.emptyMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
        ],
      ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            metric.label.toUpperCase(),
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey[500], letterSpacing: 0.8),
          ),
          const Spacer(),
          Text(
            metric.value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary),
          ),
          if (metric.helper != null && metric.helper!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              metric.helper!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          ],
        ],
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
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              section.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
          const Divider(),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.primary.withValues(alpha: 0.03)),
              columns: section.columns
                  .map((column) => DataColumn(
                    label: Text(
                      column.toUpperCase(),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                    ),
                  ))
                  .toList(),
              rows: section.rows
                  .map(
                    (row) => DataRow(
                      cells: row
                          .map((value) => DataCell(
                            Text(
                              value.isEmpty ? '-' : value,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ))
                          .toList(),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
