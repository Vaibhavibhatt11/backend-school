import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/widgets/app_user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../navbar/parent_bottom_nav_bar.dart';
import '../controllers/attendance_controller.dart';

class AttendanceTrackerView extends GetView<AttendanceController> {
  final bool embedded;

  const AttendanceTrackerView({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Attendance Tracker',
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Get.toNamed(AppRoutes.PARENT_NOTIFICATIONS),
          ),
        ],
      ),
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Obx(
                          () => AppUserAvatar(
                            radius: 30,
                            photoUrl: controller.studentPhotoUrl.value.isEmpty
                                ? null
                                : controller.studentPhotoUrl.value,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(() => Text(
                                    controller.studentName.value,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                              Obx(() => Text(
                                    controller.studentClass.value,
                                    style: TextStyle(
                                      color: isDark ? AppColors.textSecondaryDark : Colors.grey[600],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(icon: const Icon(Icons.chevron_left), onPressed: controller.previousMonth),
                            IconButton(icon: const Icon(Icons.chevron_right), onPressed: controller.nextMonth),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const TabBar(
                    isScrollable: true,
                    tabs: [
                      Tab(text: 'Daily Record'),
                      Tab(text: 'Monthly Report'),
                      Tab(text: 'Late Entry'),
                      Tab(text: 'Leave Applications'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(controller.errorMessage.value, textAlign: TextAlign.center),
                    ),
                  );
                }
                return TabBarView(
                  children: [
                    _dailyRecordTab(isDark),
                    _monthlyReportTab(isDark),
                    _lateEntryTab(isDark),
                    _leaveTab(isDark),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: embedded
          ? null
          : const ParentBottomNavBar(currentIndex: 1),
    );
  }

  Widget _dailyRecordTab(bool isDark) {
    return Obx(() => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.dailyRecords.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final item = controller.dailyRecords[i];
            final status = (item['status'] ?? '').toString();
            final statusColor = status == 'present'
                ? Colors.green
                : status == 'late'
                    ? Colors.orange
                    : status == 'absent'
                        ? Colors.red
                        : Colors.grey;
            return Container(
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
                        Text((item['date'] ?? '-').toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('In: ${(item['checkIn'] ?? '-').toString()}  Out: ${(item['checkOut'] ?? '-').toString()}'),
                        if ((item['teacher'] ?? '').toString().isNotEmpty)
                          Text('Teacher: ${(item['teacher'] ?? '').toString()}'),
                        if ((item['room'] ?? '').toString().isNotEmpty)
                          Text('Classroom: ${(item['room'] ?? '').toString()}'),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            );
          },
        ));
  }

  Widget _monthlyReportTab(bool isDark) {
    return Obx(() {
      final report = controller.monthlyReport;
      final percent = (report['attendancePercent'] is num) ? (report['attendancePercent'] as num).toDouble() : 0.0;
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            report['month']?.toString() ?? controller.month.value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _metric('Present', '${report['present'] ?? 0}', Colors.green)),
                    Expanded(child: _metric('Absent', '${report['absent'] ?? 0}', Colors.red)),
                    Expanded(child: _metric('Late', '${report['late'] ?? 0}', Colors.orange)),
                  ],
                ),
                const SizedBox(height: 14),
                LinearProgressIndicator(
                  value: (percent / 100).clamp(0.0, 1.0),
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('Attendance: ${percent.toStringAsFixed(1)}%'),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _lateEntryTab(bool isDark) {
    return Obx(() {
      if (controller.lateEntryRecords.isEmpty) {
        return const Center(child: Text('No late entry records for this month.'));
      }
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: controller.lateEntryRecords.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final item = controller.lateEntryRecords[i];
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule, color: Colors.orange),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${(item['date'] ?? '-').toString()}  •  In: ${(item['checkIn'] ?? '-').toString()}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _leaveTab(bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openLeaveDialog,
              icon: const Icon(Icons.add),
              label: const Text('Apply Leave'),
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.leaveApplications.isEmpty) {
              return const Center(child: Text('No leave applications yet.'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: controller.leaveApplications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final item = controller.leaveApplications[i];
                final status = (item['status'] ?? 'pending').toString();
                final color = status == 'approved'
                    ? Colors.green
                    : status == 'rejected'
                        ? Colors.red
                        : Colors.orange;
                return Container(
                  padding: const EdgeInsets.all(12),
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
                          Expanded(
                            child: Text(
                              '${item['fromDate']} to ${item['toDate']}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(status.toUpperCase(), style: TextStyle(color: color)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text((item['reason'] ?? '').toString()),
                      const SizedBox(height: 4),
                      Text('Applied on: ${(item['appliedOn'] ?? '-').toString()}', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _metric(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }

  Future<void> _openLeaveDialog() async {
    final reasonCtrl = TextEditingController();
    DateTime fromDate = DateTime.now();
    DateTime toDate = DateTime.now();
    await Get.dialog(
      StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Apply Leave'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('From Date'),
                subtitle: Text(fromDate.toIso8601String().split('T').first),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: fromDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (d != null) setState(() => fromDate = d);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('To Date'),
                subtitle: Text(toDate.toIso8601String().split('T').first),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: toDate,
                    firstDate: fromDate,
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (d != null) setState(() => toDate = d);
                },
              ),
              TextField(
                controller: reasonCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final reason = reasonCtrl.text.trim();
                if (reason.isEmpty) return;
                await controller.applyLeave(
                  fromDate: fromDate,
                  toDate: toDate,
                  reason: reason,
                );
                Get.back();
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
