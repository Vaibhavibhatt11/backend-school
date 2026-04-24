import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/librarian/controllers/librarian_library_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LibrarianBookCatalogView extends GetView<LibrarianLibraryController> {
  const LibrarianBookCatalogView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Book Catalog'),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshLibrary,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: controller.openBookForm,
                  icon: const Icon(Icons.library_add_rounded),
                  label: const Text('Add Book'),
                ),
                OutlinedButton.icon(
                  onPressed: controller.openCategoryForm,
                  icon: const Icon(Icons.category_rounded),
                  label: const Text('Manage Categories'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _sectionTitle('Books', isDark),
            const SizedBox(height: 8),
            Obx(() {
              final books = controller.resources.libraryBooks;
              if (books.isEmpty) {
                return _empty(
                  'No books in catalog.',
                  Icons.local_library_rounded,
                  isDark,
                );
              }
              return Column(
                children: books
                    .map(
                      (item) => _card(
                        title: item.title,
                        subtitle:
                            '${item.author} | ${item.availableCopies}/${item.totalCopies} available',
                        trailing: item.isActive ? 'ACTIVE' : 'INACTIVE',
                        isDark: isDark,
                      ),
                    )
                    .toList(),
              );
            }),
            const SizedBox(height: 14),
            _sectionTitle('Categories', isDark),
            const SizedBox(height: 8),
            Obx(() {
              final categories = controller.resources.libraryCategories;
              if (categories.isEmpty) {
                return _empty(
                  'No categories configured.',
                  Icons.category_outlined,
                  isDark,
                );
              }
              return Column(
                children: categories
                    .map(
                      (item) => _card(
                        title: item.name,
                        subtitle: item.description,
                        trailing: 'CATEGORY',
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

  Widget _sectionTitle(String title, bool isDark) => Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: isDark ? AppColors.textDark : AppColors.textLight,
        ),
      );

  Widget _card({
    required String title,
    required String subtitle,
    required String trailing,
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
      child: Row(
        children: [
          Expanded(
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
                const SizedBox(height: 4),
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
          ),
          const SizedBox(width: 10),
          Text(
            trailing,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty(String label, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}
