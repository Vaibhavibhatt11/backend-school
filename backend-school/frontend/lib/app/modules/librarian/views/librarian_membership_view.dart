import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/librarian/controllers/librarian_library_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LibrarianMembershipView extends GetView<LibrarianLibraryController> {
  const LibrarianMembershipView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Library Membership'),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshLibrary,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FilledButton.icon(
              onPressed: controller.openLibraryCardForm,
              icon: const Icon(Icons.badge_rounded),
              label: const Text('Issue Membership Card'),
            ),
            const SizedBox(height: 14),
            Obx(() {
              final cards = controller.resources.libraryCards;
              if (cards.isEmpty) {
                return _card(
                  title: 'No Membership Cards',
                  subtitle:
                      'Issue library cards to activate membership for students.',
                  isDark: isDark,
                );
              }
              return Column(
                children: cards
                    .map(
                      (item) => _card(
                        title: item.studentName,
                        subtitle:
                            'Card: ${item.cardNo} | Issued: ${item.issuedOn} | ${item.isActive ? 'ACTIVE' : 'INACTIVE'}',
                        isDark: isDark,
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
