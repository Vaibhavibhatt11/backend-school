import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_resources_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminResourcesView extends GetView<AdminResourcesController> {
  const AdminResourcesView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = (Get.arguments as Map?)?.cast<String, dynamic>() ?? const {};
    final initialTab = _initialTab(args);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      initialIndex: initialTab,
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('Resources'),
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          bottom: TabBar(
            onTap: (value) => controller.changeTab(value),
            tabs: const [
              Tab(text: 'Library'),
              Tab(text: 'Inventory'),
            ],
          ),
          actions: [
            IconButton(
              onPressed: controller.refreshCurrentTab,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _LibraryTab(controller: controller),
            _InventoryTab(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _LibraryTab extends StatelessWidget {
  const _LibraryTab({required this.controller});

  final AdminResourcesController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value &&
          controller.libraryBooks.isEmpty &&
          controller.libraryBorrows.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.errorMessage.value.isNotEmpty &&
          controller.libraryBooks.isEmpty &&
          controller.libraryBorrows.isEmpty) {
        return _ResourcesError(
          message: controller.errorMessage.value,
          onRetry: controller.refreshCurrentTab,
        );
      }
      return RefreshIndicator(
        onRefresh: controller.refreshCurrentTab,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ResourcesChip(
                  label: 'Books',
                  value: '${controller.libraryBooks.length}',
                ),
                _ResourcesChip(
                  label: 'Borrows',
                  value: '${controller.libraryBorrows.length}',
                ),
                FilledButton.icon(
                  onPressed: () => controller.openBookDialog(),
                  icon: const Icon(Icons.library_add_rounded),
                  label: const Text('Add Book'),
                ),
                OutlinedButton.icon(
                  onPressed: controller.issueBook,
                  icon: const Icon(Icons.assignment_returned_rounded),
                  label: const Text('Issue Book'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const _ResourcesTitle(title: 'Books'),
            const SizedBox(height: 12),
            if (controller.libraryBooks.isEmpty)
              const _ResourcesEmpty(
                icon: Icons.local_library_rounded,
                title: 'No books found',
                message:
                    'Library books will appear here with live copy counts.',
              )
            else
              ...controller.libraryBooks.map(
                (item) => _BookCard(item: item, controller: controller),
              ),
            const SizedBox(height: 20),
            const _ResourcesTitle(title: 'Borrow Activity'),
            const SizedBox(height: 12),
            if (controller.libraryBorrows.isEmpty)
              const _ResourcesEmpty(
                icon: Icons.menu_book_rounded,
                title: 'No borrow records',
                message: 'Issued and returned books will appear here.',
              )
            else
              ...controller.libraryBorrows.map(
                (item) => _BorrowCard(item: item, controller: controller),
              ),
          ],
        ),
      );
    });
  }
}

class _InventoryTab extends StatelessWidget {
  const _InventoryTab({required this.controller});

  final AdminResourcesController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value &&
          controller.inventoryItems.isEmpty &&
          controller.inventoryTransactions.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.errorMessage.value.isNotEmpty &&
          controller.inventoryItems.isEmpty &&
          controller.inventoryTransactions.isEmpty) {
        return _ResourcesError(
          message: controller.errorMessage.value,
          onRetry: controller.refreshCurrentTab,
        );
      }
      return RefreshIndicator(
        onRefresh: controller.refreshCurrentTab,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ResourcesChip(
                  label: 'Items',
                  value: '${controller.inventoryItems.length}',
                ),
                _ResourcesChip(
                  label: 'Transactions',
                  value: '${controller.inventoryTransactions.length}',
                ),
                FilledButton.icon(
                  onPressed: () => controller.openInventoryItemDialog(),
                  icon: const Icon(Icons.inventory_2_rounded),
                  label: const Text('Add Item'),
                ),
                OutlinedButton.icon(
                  onPressed: controller.createInventoryTransaction,
                  icon: const Icon(Icons.sync_alt_rounded),
                  label: const Text('Stock Move'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const _ResourcesTitle(title: 'Inventory Items'),
            const SizedBox(height: 12),
            if (controller.inventoryItems.isEmpty)
              const _ResourcesEmpty(
                icon: Icons.inventory_rounded,
                title: 'No inventory items',
                message: 'Stock items and equipment will appear here.',
              )
            else
              ...controller.inventoryItems.map(
                (item) => _InventoryCard(item: item, controller: controller),
              ),
            const SizedBox(height: 20),
            const _ResourcesTitle(title: 'Stock Transactions'),
            const SizedBox(height: 12),
            if (controller.inventoryTransactions.isEmpty)
              const _ResourcesEmpty(
                icon: Icons.swap_vert_rounded,
                title: 'No transactions found',
                message: 'Stock movement history will appear here.',
              )
            else
              ...controller.inventoryTransactions.map(
                (item) => _TransactionCard(item: item),
              ),
          ],
        ),
      );
    });
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({required this.item, required this.controller});

  final AdminLibraryBookRecord item;
  final AdminResourcesController controller;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      title: item.title,
      subtitle: item.author,
      actions: [
        OutlinedButton(
          onPressed: () => controller.openBookDialog(existing: item),
          child: const Text('Edit'),
        ),
        FilledButton.tonal(
          onPressed: () => controller.deleteBook(item),
          child: const Text('Delete'),
        ),
      ],
      children: [
        _MetaText(label: 'ISBN', value: item.isbn.isEmpty ? '-' : item.isbn),
        _MetaText(
          label: 'Copies',
          value: '${item.availableCopies}/${item.totalCopies}',
        ),
        _MetaText(
          label: 'Category',
          value: item.category.isEmpty ? '-' : item.category,
        ),
        _MetaText(
          label: 'Status',
          value: item.isActive ? 'ACTIVE' : 'INACTIVE',
        ),
      ],
    );
  }
}

class _BorrowCard extends StatelessWidget {
  const _BorrowCard({required this.item, required this.controller});

  final AdminLibraryBorrowRecord item;
  final AdminResourcesController controller;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      title: item.bookTitle.isEmpty ? 'Borrow Record' : item.bookTitle,
      subtitle: item.borrowerType,
      actions: [
        if (item.status != 'RETURNED')
          OutlinedButton(
            onPressed: () => controller.returnBorrow(item),
            child: const Text('Return'),
          ),
      ],
      children: [
        _MetaText(label: 'Borrower', value: item.borrowerRefId),
        _MetaText(label: 'Status', value: item.status),
        _MetaText(label: 'Due', value: _dateText(item.dueDate)),
        if (item.returnedAt != null)
          _MetaText(label: 'Returned', value: _dateText(item.returnedAt)),
      ],
    );
  }
}

class _InventoryCard extends StatelessWidget {
  const _InventoryCard({required this.item, required this.controller});

  final AdminInventoryItemRecord item;
  final AdminResourcesController controller;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      title: item.name,
      subtitle: item.sku,
      actions: [
        OutlinedButton(
          onPressed: () => controller.openInventoryItemDialog(existing: item),
          child: const Text('Edit'),
        ),
        FilledButton.tonal(
          onPressed: () => controller.deleteInventoryItem(item),
          child: const Text('Delete'),
        ),
      ],
      children: [
        _MetaText(label: 'Qty', value: '${item.qty} ${item.unit}'),
        _MetaText(
          label: 'Threshold',
          value: '${item.lowStockThreshold} ${item.unit}',
        ),
        _MetaText(
          label: 'Category',
          value: item.category.isEmpty ? '-' : item.category,
        ),
        _MetaText(label: 'Status', value: item.isLowStock ? 'LOW STOCK' : 'OK'),
      ],
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.item});

  final AdminInventoryTransactionRecord item;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      title: item.itemName.isEmpty ? 'Transaction' : item.itemName,
      subtitle: '${item.type} | ${item.qty}',
      actions: const [],
      children: [
        _MetaText(label: 'Type', value: item.type),
        _MetaText(label: 'Quantity', value: '${item.qty}'),
        _MetaText(
          label: 'Created',
          value: item.createdAt == null ? '-' : _dateText(item.createdAt),
        ),
        if (item.note.isNotEmpty) _MetaText(label: 'Note', value: item.note),
      ],
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({
    required this.title,
    required this.subtitle,
    required this.children,
    required this.actions,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
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
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
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
          const SizedBox(height: 12),
          Wrap(spacing: 12, runSpacing: 8, children: children),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(spacing: 8, runSpacing: 8, children: actions),
          ],
        ],
      ),
    );
  }
}

class _ResourcesTitle extends StatelessWidget {
  const _ResourcesTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }
}

class _ResourcesChip extends StatelessWidget {
  const _ResourcesChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textDark : AppColors.textLight,
        ),
      ),
    );
  }
}

class _ResourcesEmpty extends StatelessWidget {
  const _ResourcesEmpty({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 36,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
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

class _ResourcesError extends StatelessWidget {
  const _ResourcesError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => onRetry(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}

String _dateText(DateTime? value) {
  if (value == null) return '-';
  return value.toIso8601String().substring(0, 10);
}

int _initialTab(Map<String, dynamic> args) {
  final value = (args['initialTab'] as num?)?.toInt() ?? 0;
  if (value < 0) return 0;
  if (value > 1) return 1;
  return value;
}
