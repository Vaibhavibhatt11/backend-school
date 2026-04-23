import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/hostel_warden/controllers/hostel_warden_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HostelWardenVisitorsView extends GetView<HostelWardenController> {
  const HostelWardenVisitorsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Visitor Logs'),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FilledButton.icon(
              onPressed: controller.operations.openVisitorDialog,
              icon: const Icon(Icons.how_to_reg_rounded),
              label: const Text('Add Visitor'),
            ),
            const SizedBox(height: 14),
            Obx(
              () => Column(
                children: controller.operations.hostelVisitors
                    .map(
                      (item) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.visitorName,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            if (item.studentId.isNotEmpty)
                              Text('Student: ${item.studentId}'),
                            if (item.purpose.isNotEmpty) Text('Purpose: ${item.purpose}'),
                            if ((controller
                                            .operations
                                            .hostelVisitorCheckoutById[item.id] ??
                                        '')
                                    .isEmpty &&
                                item.outTime == null)
                              OutlinedButton(
                                onPressed: () =>
                                    controller.operations.markVisitorCheckout(item),
                                child: const Text('Checkout'),
                              ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
