import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/librarian/controllers/librarian_library_controller.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LibrarianLibraryHubView extends GetView<LibrarianLibraryController> {
  const LibrarianLibraryHubView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Librarian Portal'),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        actions: [
          IconButton(
            onPressed: controller.refreshLibrary,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshLibrary,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _headerCard(isDark),
            const SizedBox(height: 14),
            Obx(
              () => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _metricChip(
                    'Books',
                    '${controller.resources.libraryBooks.length}',
                    isDark,
                  ),
                  _metricChip(
                    'Issues',
                    '${controller.resources.libraryBorrows.where((e) => e.status != 'RETURNED').length}',
                    isDark,
                  ),
                  _metricChip(
                    'Cards',
                    '${controller.resources.libraryCards.length}',
                    isDark,
                  ),
                  _metricChip(
                    'Overdues',
                    '${controller.resources.libraryBorrows.where((e) => e.status != 'RETURNED' && (e.dueDate?.isBefore(DateTime.now()) ?? false)).length}',
                    isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _navTile(
              title: 'Book Catalog',
              subtitle: 'Manage books and categories.',
              icon: Icons.menu_book_rounded,
              onTap: () => Get.toNamed(AppRoutes.LIBRARIAN_BOOK_CATALOG),
              isDark: isDark,
            ),
            _navTile(
              title: 'Book Issue',
              subtitle: 'Issue books to student/staff borrowers.',
              icon: Icons.assignment_turned_in_rounded,
              onTap: () => Get.toNamed(AppRoutes.LIBRARIAN_BOOK_ISSUE),
              isDark: isDark,
            ),
            _navTile(
              title: 'Book Return',
              subtitle: 'Return issued books and close circulation.',
              icon: Icons.assignment_returned_rounded,
              onTap: () => Get.toNamed(AppRoutes.LIBRARIAN_BOOK_RETURN),
              isDark: isDark,
            ),
            _navTile(
              title: 'Fine Calculation',
              subtitle: 'Configure fine rules and view overdue fines.',
              icon: Icons.price_check_rounded,
              onTap: () => Get.toNamed(AppRoutes.LIBRARIAN_FINE_MANAGEMENT),
              isDark: isDark,
            ),
            _navTile(
              title: 'Library Membership',
              subtitle: 'Issue and manage student library cards.',
              icon: Icons.badge_rounded,
              onTap: () => Get.toNamed(AppRoutes.LIBRARIAN_MEMBERSHIP),
              isDark: isDark,
            ),
            _navTile(
              title: 'Admin Library Desk',
              subtitle: 'Open admin library resources view (shared data).',
              icon: Icons.admin_panel_settings_rounded,
              onTap: () => Get.toNamed(
                AppRoutes.ADMIN_RESOURCES,
                arguments: {'scope': 'library', 'initialTab': 0},
              ),
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Library Management',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'End-to-end librarian flow for catalog, circulation, fines, and membership.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _metricChip(String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: isDark ? AppColors.textDark : AppColors.textLight,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _navTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
