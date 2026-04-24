import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/core/widgets/custom_app_bar.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_attendance_leave_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffAttendanceLeaveView extends GetView<StaffAttendanceLeaveController> {
  const StaffAttendanceLeaveView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: const CustomAppBar(title: 'Attendance & Leave Management'),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _tabStrip(isDark),
            const SizedBox(height: 12),
            _activeBody(isDark),
          ],
        ),
      ),
    );
  }

  Widget _tabStrip(bool isDark) {
    const tabs = [
      'Staff Attendance',
      'Leave Apply',
      'Leave Approval',
      'Attendance Reports',
      'Late Tracking',
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (index) {
            final selected = controller.activeTab.value == index;
            return GestureDetector(
              onTap: () => controller.setTab(index),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected ? AppColors.primary : null,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _activeBody(bool isDark) {
    switch (controller.activeTab.value) {
      case 0:
        return _attendanceTab(isDark);
      case 1:
        return _leaveApplyTab(isDark);
      case 2:
        return _leaveApprovalTab(isDark);
      case 3:
        return _reportsTab(isDark);
      default:
        return _lateTrackingTab(isDark);
    }
  }

  Widget _panel(bool isDark, String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _attendanceTab(bool isDark) {
    return _panel(
      isDark,
      'Staff Attendance',
      Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _showMarkAttendanceDialog,
              icon: const Icon(Icons.how_to_reg_rounded),
              label: const Text('Mark Today Attendance'),
            ),
          ),
          const SizedBox(height: 10),
          if (controller.attendanceRecords.isEmpty)
            const Text('No attendance records')
          else
            ...controller.attendanceRecords.map(
              (row) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.primary,
                ),
                title: Text('${row['date']} - ${row['checkIn']}'),
                subtitle: Text('Status: ${row['status']}'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _leaveApplyTab(bool isDark) {
    return _panel(
      isDark,
      'Leave Application',
      Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: _showLeaveApplyDialog,
              icon: const Icon(Icons.note_add_rounded),
              label: const Text('Apply Leave'),
            ),
          ),
          const SizedBox(height: 10),
          if (controller.leaveApplications.isEmpty)
            const Text('No leave applications')
          else
            ...controller.leaveApplications.map(
              (row) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    '${row['type']} leave (${row['fromDate']} to ${row['toDate']})',
                  ),
                  subtitle: Text('${row['reason']} - ${row['status']}'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _leaveApprovalTab(bool isDark) {
    return _panel(
      isDark,
      'Leave Approval',
      Column(
        children: controller.approvalQueue.map((row) {
          final id = row['id'] ?? '';
          final isPending = row['status'] == 'PENDING';
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                '${row['type']} - ${row['fromDate']} to ${row['toDate']}',
              ),
              subtitle: Text('Status: ${row['status']}'),
              trailing: Wrap(
                spacing: 6,
                children: [
                  OutlinedButton(
                    onPressed: isPending && id.isNotEmpty
                        ? () => controller.decideLeave(id, 'APPROVED')
                        : null,
                    child: const Text('Approve'),
                  ),
                  OutlinedButton(
                    onPressed: isPending && id.isNotEmpty
                        ? () => controller.decideLeave(id, 'REJECTED')
                        : null,
                    child: const Text('Reject'),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _reportsTab(bool isDark) {
    final metrics = controller.reportMetrics();
    return _panel(
      isDark,
      'Attendance Reports',
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _metricCard('Total Entries', '${metrics['total'] ?? 0}', isDark),
          _metricCard('Present', '${metrics['present'] ?? 0}', isDark),
          _metricCard('Late Arrivals', '${metrics['late'] ?? 0}', isDark),
          _metricCard(
            'Leave Approved',
            '${metrics['leaveApproved'] ?? 0}',
            isDark,
          ),
          _metricCard(
            'Leave Pending',
            '${metrics['leavePending'] ?? 0}',
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String label, String value, bool isDark) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
          ),
        ],
      ),
    );
  }

  Widget _lateTrackingTab(bool isDark) {
    return _panel(
      isDark,
      'Late Arrival Tracking',
      Column(
        children: [
          if (controller.lateArrivals.isEmpty)
            const Text('No late entries')
          else
            ...controller.lateArrivals.map((row) {
              final id = row['id'] ?? '';
              final open = row['status'] == 'OPEN';
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.watch_later_outlined,
                  color: AppColors.primary,
                ),
                title: Text('${row['date']} - Check-in ${row['checkIn']}'),
                subtitle: Text(
                  'Late: ${row['minutesLate']} mins - ${row['status']}',
                ),
                trailing: FilledButton.tonal(
                  onPressed: open && id.isNotEmpty
                      ? () => controller.closeLateEntry(id)
                      : null,
                  child: const Text('Resolve'),
                ),
              );
            }),
        ],
      ),
    );
  }

  Future<void> _showMarkAttendanceDialog() async {
    String status = 'PRESENT';
    final checkIn = TextEditingController(text: '08:45');
    final date = TextEditingController(
      text: DateTime.now().toIso8601String().split('T').first,
    );
    await Get.dialog(
      AlertDialog(
        title: const Text('Mark Attendance'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: date,
                decoration: const InputDecoration(
                  labelText: 'Date (YYYY-MM-DD)',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: checkIn,
                decoration: const InputDecoration(
                  labelText: 'Check-in (HH:MM)',
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const ['PRESENT', 'LATE', 'ABSENT']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => status = value ?? 'PRESENT'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              controller.markAttendance(
                date: date.text.trim(),
                checkIn: checkIn.text.trim(),
                status: status,
              );
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showLeaveApplyDialog() async {
    String type = 'Casual';
    final fromDate = TextEditingController(
      text: DateTime.now().toIso8601String().split('T').first,
    );
    final toDate = TextEditingController(
      text: DateTime.now().toIso8601String().split('T').first,
    );
    final reason = TextEditingController();
    await Get.dialog(
      AlertDialog(
        title: const Text('Leave Application'),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'Leave Type'),
                  items: const ['Casual', 'Sick', 'Emergency']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => type = value ?? 'Casual'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: fromDate,
                  decoration: const InputDecoration(labelText: 'From Date'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: toDate,
                  decoration: const InputDecoration(labelText: 'To Date'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: reason,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Reason'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              controller.submitLeave(
                type: type,
                fromDate: fromDate.text.trim(),
                toDate: toDate.text.trim(),
                reason: reason.text.trim(),
              );
              Get.back();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
