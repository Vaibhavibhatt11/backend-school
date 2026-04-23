import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/librarian/controllers/librarian_library_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LibrarianIssueReturnView extends GetView<LibrarianLibraryController> {
  const LibrarianIssueReturnView({super.key, required this.returnOnly});

  final bool returnOnly;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = returnOnly ? 'Book Return' : 'Book Issue';
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshLibrary,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!returnOnly)
              FilledButton.icon(
                onPressed: controller.openIssueFlow,
                icon: const Icon(Icons.assignment_turned_in_rounded),
                label: const Text('Issue Book'),
              ),
            if (!returnOnly) const SizedBox(height: 14),
            Obx(() {
              final allBorrows = controller.resources.libraryBorrows;
              final records = returnOnly
                  ? allBorrows.where((e) => e.status != 'RETURNED').toList()
                  : allBorrows;
              if (records.isEmpty) {
                return _emptyCard(
                  returnOnly
                      ? 'No active issued books.'
                      : 'No issue/return records yet.',
                  isDark,
                );
              }
              return Column(
                children: records
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
                              item.bookTitle.isEmpty
                                  ? 'Borrow Record'
                                  : item.bookTitle,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.textDark
                                    : AppColors.textLight,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${item.borrowerType} | ${item.borrowerRefId}',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                            Text(
                              'Status: ${item.status} | Due: ${_date(item.dueDate)}',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                            if (item.status != 'RETURNED') ...[
                              const SizedBox(height: 10),
                              OutlinedButton.icon(
                                onPressed: () =>
                                    controller.resources.returnBorrow(item),
                                icon: const Icon(
                                  Icons.assignment_returned_rounded,
                                ),
                                label: const Text('Return Book'),
                              ),
                            ],
                          ],
                        ),
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

  Widget _emptyCard(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Text(text),
    );
  }

  String _date(DateTime? value) {
    if (value == null) return '-';
    return value.toIso8601String().substring(0, 10);
  }
}
