import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/hostel_warden/controllers/hostel_warden_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HostelWardenComplaintsView extends GetView<HostelWardenController> {
  const HostelWardenComplaintsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Hostel Complaints'),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FilledButton.icon(
              onPressed: () => controller.operations.openHostelComplaintDialog(),
              icon: const Icon(Icons.report_problem_rounded),
              label: const Text('Add Complaint'),
            ),
            const SizedBox(height: 14),
            Obx(() {
              final complaints = controller.operations.hostelComplaints;
              if (complaints.isEmpty) {
                return _card(
                  isDark: isDark,
                  title: 'No complaints',
                  subtitle: 'Create complaints and manage resolution status.',
                );
              }
              return Column(
                children: complaints
                    .map(
                      (item) => _card(
                        isDark: isDark,
                        title: item.studentLabel,
                        subtitle:
                            '${item.category} | ${item.status}\n${item.description}',
                        actions: [
                          OutlinedButton(
                            onPressed: () => controller.operations
                                .openHostelComplaintDialog(existing: item),
                            child: const Text('Edit'),
                          ),
                          OutlinedButton(
                            onPressed: () => controller.operations
                                .setHostelComplaintStatus(item, 'IN_PROGRESS'),
                            child: const Text('In Progress'),
                          ),
                          OutlinedButton(
                            onPressed: () => controller.operations
                                .setHostelComplaintStatus(item, 'RESOLVED'),
                            child: const Text('Resolve'),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _card({
    required bool isDark,
    required String title,
    required String subtitle,
    List<Widget> actions = const [],
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
          const SizedBox(height: 6),
          Text(subtitle),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: actions),
          ],
        ],
      ),
    );
  }
}
