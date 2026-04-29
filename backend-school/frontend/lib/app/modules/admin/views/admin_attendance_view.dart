import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_attendance_controller.dart';
import 'package:erp_frontend/common/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminAttendanceView extends GetView<AdminAttendanceController> {
  const AdminAttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('Attendance Management'),
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              Padding(
              padding: EdgeInsets.fromLTRB(
                Responsive.clamp(context, 16, min: 12, max: 24),
                Responsive.clamp(context, 16, min: 12, max: 24),
                Responsive.clamp(context, 16, min: 12, max: 24),
                Responsive.clamp(context, 12, min: 8, max: 18),
              ),
                child: _AttendanceHeaderCard(controller: controller),
              ),
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: Responsive.clamp(context, 16, min: 12, max: 24),
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicator: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorPadding: const EdgeInsets.all(6),
                  dividerColor: Colors.transparent,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Students'),
                    Tab(text: 'Teachers'),
                    Tab(text: 'Bulk'),
                    Tab(text: 'Integration'),
                  ],
                ),
              ),
              SizedBox(height: Responsive.clamp(context, 10, min: 8, max: 14)),
              Expanded(
                child: TabBarView(
                  children: [
                    _OverviewTab(controller: controller),
                    _RecordsTab(controller: controller, isStudent: true),
                    _RecordsTab(controller: controller, isStudent: false),
                    _BulkTab(controller: controller),
                    _IntegrationTab(controller: controller),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _AttendanceHeaderCard extends StatelessWidget {
  const _AttendanceHeaderCard({required this.controller});

  final AdminAttendanceController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.clamp(context, 16, min: 12, max: 24)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(
          Responsive.clamp(context, 18, min: 14, max: 26),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(Responsive.clamp(context, 12, min: 8, max: 18)),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(
                Responsive.clamp(context, 12, min: 8, max: 18),
              ),
            ),
            child: const Icon(Icons.fact_check_rounded, color: Colors.white),
          ),
          SizedBox(width: Responsive.clamp(context, 14, min: 10, max: 20)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attendance Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Responsive.sp(context, 19),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: Responsive.clamp(context, 4, min: 2, max: 6)),
                Obx(
                  () => Text(
                    'Date ${controller.selectedDateIso.value} • '
                    '${controller.studentPercent.value}% students • '
                    '${controller.teacherPercent.value}% teachers',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.controller});

  final AdminAttendanceController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RefreshIndicator(
      onRefresh: controller.loadInitialData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          _DateFilterCard(controller: controller),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Student Attendance',
                  percent: controller.studentPercent.value,
                  value: '${controller.studentPresent.value}/${controller.studentTotal.value}',
                  icon: Icons.groups_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  title: 'Teacher Attendance',
                  percent: controller.teacherPercent.value,
                  value: '${controller.teacherPresent.value}/${controller.teacherTotal.value}',
                  icon: Icons.person_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _SectionTitle(title: 'Weekly Trend'),
          const SizedBox(height: 10),
          if (controller.trendRows.isEmpty)
            const _EmptyState(text: 'No trend data available.')
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                children: controller.trendRows
                    .map(
                      (row) => _TrendRow(
                        dayLabel: row.dayLabel,
                        pct: row.presentPct,
                        absent: row.absentCount,
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

class _RecordsTab extends StatelessWidget {
  const _RecordsTab({required this.controller, required this.isStudent});

  final AdminAttendanceController controller;
  final bool isStudent;

  @override
  Widget build(BuildContext context) {
    final records = isStudent ? controller.studentRecords : controller.teacherRecords;
    return RefreshIndicator(
      onRefresh: controller.refreshRecords,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          _DateFilterCard(controller: controller),
          const SizedBox(height: 10),
          if (isStudent)
            _ClassFilterDropdown(
              value: controller.selectedClassFilter.value,
              options: controller.classOptions,
              onChanged: controller.selectClassFilter,
            ),
          if (isStudent) const SizedBox(height: 12),
          _SectionTitle(title: isStudent ? 'Student Logs' : 'Teacher Logs'),
          const SizedBox(height: 10),
          if (records.isEmpty)
            const _EmptyState(text: 'No attendance records found for selected date.')
          else
            ...records.map((item) => _RecordTile(item: item)),
        ],
      ),
    );
  }
}

class _BulkTab extends StatelessWidget {
  const _BulkTab({required this.controller});

  final AdminAttendanceController controller;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshBulkTargets,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          _DateFilterCard(controller: controller),
          const SizedBox(height: 10),
          Obx(
            () => Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.surfaceDark
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.borderDark
                      : AppColors.borderLight,
                ),
              ),
              child: SegmentedButton<AttendanceAudience>(
                segments: const [
                  ButtonSegment(
                    value: AttendanceAudience.student,
                    label: Text('Students'),
                    icon: Icon(Icons.groups_rounded),
                  ),
                  ButtonSegment(
                    value: AttendanceAudience.teacher,
                    label: Text('Teachers'),
                    icon: Icon(Icons.person_rounded),
                  ),
                ],
                selected: {controller.selectedBulkAudience.value},
                onSelectionChanged: (value) {
                  controller.setBulkAudience(value.first);
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Obx(() {
            if (controller.selectedBulkAudience.value == AttendanceAudience.student) {
              return _ClassFilterDropdown(
                value: controller.selectedBulkClass.value,
                options: controller.classOptions,
                onChanged: controller.selectBulkClass,
              );
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QuickMarkChip(label: 'Mark All Present', onTap: () => controller.markAllBulkTargets('P')),
              _QuickMarkChip(label: 'Mark All Absent', onTap: () => controller.markAllBulkTargets('A')),
              _QuickMarkChip(label: 'Mark All Late', onTap: () => controller.markAllBulkTargets('L')),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.bulkTargets.isEmpty) {
              return const _EmptyState(text: 'No records available for bulk marking.');
            }
            return Column(
              children: controller.bulkTargets
                  .map((target) => _BulkTargetTile(controller: controller, target: target))
                  .toList(),
            );
          }),
          const SizedBox(height: 16),
          Obx(
            () => FilledButton.icon(
              onPressed: controller.isSubmittingBulk.value ? null : controller.submitBulkAttendance,
              icon: controller.isSubmittingBulk.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.done_all_rounded),
              label: const Text('Submit Bulk Attendance'),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntegrationTab extends StatelessWidget {
  const _IntegrationTab({required this.controller});

  final AdminAttendanceController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionTitle(title: 'Biometric & Face Integration'),
        const SizedBox(height: 10),
        _IntegrationSwitchTile(
          title: 'Biometric Device Integration',
          subtitle: 'Enable fingerprint/biometric attendance input.',
          value: controller.biometricEnabled.value,
          onChanged: controller.setBiometricEnabled,
        ),
        const SizedBox(height: 10),
        _IntegrationSwitchTile(
          title: 'Face Recognition Integration',
          subtitle: 'Enable face based attendance capture.',
          value: controller.faceEnabled.value,
          onChanged: controller.setFaceEnabled,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Last Sync',
                style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                controller.lastIntegrationSync.value.isEmpty
                    ? 'Not synced yet'
                    : controller.lastIntegrationSync.value,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
              ),
              const SizedBox(height: 12),
              Obx(
                () => FilledButton.icon(
                  onPressed: controller.isSyncingIntegration.value ? null : controller.syncIntegrationsNow,
                  icon: controller.isSyncingIntegration.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.sync_rounded),
                  label: const Text('Sync Integrations'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateFilterCard extends StatelessWidget {
  const _DateFilterCard({required this.controller});

  final AdminAttendanceController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              controller.selectedDateIso.value,
              style: TextStyle(
                color: isDark ? AppColors.textDark : AppColors.textLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.tryParse(controller.selectedDateIso.value) ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                await controller.pickDate(picked);
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}

class _ClassFilterDropdown extends StatelessWidget {
  const _ClassFilterDropdown({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String value;
  final List<String> options;
  final Future<void> Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: DropdownButton<String>(
        value: options.contains(value) ? value : options.first,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        items: options.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: (v) {
          if (v != null) {
            onChanged(v);
          }
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.percent,
    required this.value,
    required this.icon,
  });

  final String title;
  final int percent;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '$percent%',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 24,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ),
        ),
      ],
    );
  }
}

class _TrendRow extends StatelessWidget {
  const _TrendRow({required this.dayLabel, required this.pct, required this.absent});

  final String dayLabel;
  final int pct;
  final int absent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 58, child: Text(dayLabel)),
          Expanded(
            child: LinearProgressIndicator(
              value: pct / 100,
              color: AppColors.primary,
              backgroundColor: Colors.grey.shade200,
            ),
          ),
          const SizedBox(width: 8),
          Text('$pct%'),
          const SizedBox(width: 8),
          Text('A:$absent', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.item});

  final AttendanceRecordItem item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                if (item.label.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(item.label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ],
            ),
          ),
          _StatusBadge(status: item.status),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'P':
        color = Colors.green;
        break;
      case 'A':
        color = Colors.red;
        break;
      case 'L':
        color = Colors.orange;
        break;
      case 'LV':
        color = Colors.blueGrey;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status.isEmpty ? 'NA' : status, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
    );
  }
}

class _QuickMarkChip extends StatelessWidget {
  const _QuickMarkChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(label: Text(label), onPressed: onTap);
  }
}

class _BulkTargetTile extends StatelessWidget {
  const _BulkTargetTile({required this.controller, required this.target});

  final AdminAttendanceController controller;
  final BulkAttendanceTarget target;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(target.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                if (target.label.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(target.label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ],
            ),
          ),
          Obx(
            () => DropdownButton<String>(
              value: ['', 'P', 'A', 'L', 'LV'].contains(target.status.value) ? target.status.value : '',
              items: const [
                DropdownMenuItem(value: '', child: Text('Select')),
                DropdownMenuItem(value: 'P', child: Text('Present')),
                DropdownMenuItem(value: 'A', child: Text('Absent')),
                DropdownMenuItem(value: 'L', child: Text('Late')),
                DropdownMenuItem(value: 'LV', child: Text('Leave')),
              ],
              onChanged: (value) {
                controller.setBulkStatus(target, value ?? '');
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _IntegrationSwitchTile extends StatelessWidget {
  const _IntegrationSwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final Future<void> Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Switch(value: value, onChanged: (v) => onChanged(v)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}
