import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/librarian/controllers/librarian_library_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LibrarianFineManagementView extends GetView<LibrarianLibraryController> {
  const LibrarianFineManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Fine Calculation'),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshLibrary,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FilledButton.icon(
              onPressed: controller.openFineRuleForm,
              icon: const Icon(Icons.rule_rounded),
              label: const Text('Configure Late Fine Rule'),
            ),
            const SizedBox(height: 14),
            Obx(() {
              final rule = controller.resources.lateFineRule.value;
              return _card(
                title: 'Current Rule',
                subtitle:
                    '${rule.type == 'fixed' ? 'Fixed' : 'Per-day'} | Amount: ${rule.amount.toStringAsFixed(2)} | Grace days: ${rule.graceDays}',
                isDark: isDark,
              );
            }),
            const SizedBox(height: 12),
            Obx(() {
              final overdue = controller.resources.libraryBorrows
                  .where(
                    (e) =>
                        e.status != 'RETURNED' &&
                        (e.dueDate?.isBefore(DateTime.now()) ?? false),
                  )
                  .toList();
              if (overdue.isEmpty) {
                return _card(
                  title: 'No Overdues',
                  subtitle: 'Fine entries appear once books cross due date.',
                  isDark: isDark,
                );
              }
              final rule = controller.resources.lateFineRule.value;
              return Column(
                children: overdue.map((item) {
                  final overdueDays = DateTime.now().difference(item.dueDate!).inDays;
                  final chargeDays = overdueDays > rule.graceDays
                      ? overdueDays - rule.graceDays
                      : 0;
                  final fine = rule.type == 'fixed'
                      ? rule.amount
                      : (chargeDays * rule.amount);
                  return _card(
                    title: item.bookTitle.isEmpty
                        ? 'Borrow Record'
                        : item.bookTitle,
                    subtitle:
                        'Borrower: ${item.borrowerRefId} | Overdue: $overdueDays days | Fine: ${fine.toStringAsFixed(2)}',
                    isDark: isDark,
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _card({
    required String title,
    required String subtitle,
    required bool isDark,
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
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
