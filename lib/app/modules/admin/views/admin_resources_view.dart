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
    final scope = (args['scope']?.toString() ?? '').toLowerCase();
    final isLibraryOnly = scope == 'library';
    final isInventoryOnly = scope == 'inventory';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tabCount = (isLibraryOnly || isInventoryOnly) ? 1 : 2;
    final mappedInitialIndex = tabCount == 1 ? 0 : initialTab;

    return DefaultTabController(
      length: tabCount,
      initialIndex: mappedInitialIndex,
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('Resources'),
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          bottom: tabCount == 1
              ? null
              : TabBar(
                  onTap: (value) => controller.changeTab(value),
                  tabs: const [
                    Tab(text: 'Library'),
                    Tab(text: 'Inventory'),
                  ],
                ),
        ),
        body: TabBarView(
          children: isLibraryOnly
              ? [_LibraryTab(controller: controller)]
              : isInventoryOnly
                  ? [_InventoryTab(controller: controller)]
                  : [
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
    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.surfaceDark
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.borderDark
                    : AppColors.borderLight,
              ),
            ),
            child: TabBar(
              isScrollable: true,
              indicator: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorPadding: const EdgeInsets.all(6),
              dividerColor: Colors.transparent,
              labelColor: AppColors.primary,
              unselectedLabelColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              tabs: const [
                Tab(text: 'Book Catalog'),
                Tab(text: 'Categories'),
                Tab(text: 'Issue / Return'),
                Tab(text: 'Library Cards'),
                Tab(text: 'Late Fine'),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
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
              return TabBarView(
                children: [
                  _LibraryBooksSubTab(controller: controller),
                  _LibraryCategoriesSubTab(controller: controller),
                  _LibraryIssueReturnSubTab(controller: controller),
                  _LibraryCardsSubTab(controller: controller),
                  _LibraryFineSubTab(controller: controller),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _InventoryTab extends StatelessWidget {
  const _InventoryTab({required this.controller});

  final AdminResourcesController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: TabBar(
              isScrollable: true,
              indicator: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorPadding: const EdgeInsets.all(6),
              dividerColor: Colors.transparent,
              labelColor: AppColors.primary,
              unselectedLabelColor: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              tabs: const [
                Tab(text: 'Asset Tracking'),
                Tab(text: 'Equipment Inventory'),
                Tab(text: 'Purchase Orders'),
                Tab(text: 'Vendor Management'),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
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
              return TabBarView(
                children: [
                  _AssetsSubTab(controller: controller),
                  _EquipmentSubTab(controller: controller),
                  _PurchaseOrdersSubTab(controller: controller),
                  _VendorsSubTab(controller: controller),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _AssetsSubTab extends StatelessWidget {
  const _AssetsSubTab({required this.controller});
  final AdminResourcesController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ResourcesChip(label: 'Assets', value: '${controller.assets.length}'),
            FilledButton.icon(
              onPressed: () => controller.openAssetDialog(),
              icon: const Icon(Icons.precision_manufacturing_rounded),
              label: const Text('Add Asset'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (controller.assets.isEmpty)
          const _ResourcesEmpty(
            icon: Icons.precision_manufacturing_rounded,
            title: 'No assets',
            message: 'Create tracked assets with lifecycle status and ownership.',
          )
        else
          ...controller.assets.map(
            (item) => _CardShell(
              title: item.name,
              subtitle: item.assetCode,
              actions: [
                OutlinedButton(
                  onPressed: () => controller.openAssetDialog(existing: item),
                  child: const Text('Edit'),
                ),
                FilledButton.tonal(
                  onPressed: () => controller.deleteAsset(item),
                  child: const Text('Delete'),
                ),
              ],
              children: [
                _MetaText(label: 'Category', value: item.category.isEmpty ? '-' : item.category),
                _MetaText(label: 'Assigned To', value: item.assignedTo.isEmpty ? '-' : item.assignedTo),
                _MetaText(label: 'Status', value: item.status),
                _MetaText(label: 'Purchase Date', value: item.purchaseDate.isEmpty ? '-' : item.purchaseDate),
              ],
            ),
          ),
      ],
    );
  }
}

class _EquipmentSubTab extends StatelessWidget {
  const _EquipmentSubTab({required this.controller});
  final AdminResourcesController controller;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshCurrentTab,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ResourcesChip(label: 'Items', value: '${controller.inventoryItems.length}'),
              _ResourcesChip(label: 'Transactions', value: '${controller.inventoryTransactions.length}'),
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
          if (controller.inventoryTransactions.isEmpty)
            const _ResourcesEmpty(
              icon: Icons.swap_vert_rounded,
              title: 'No transactions found',
              message: 'Stock movement history will appear here.',
            )
          else
            ...controller.inventoryTransactions.map((item) => _TransactionCard(item: item)),
        ],
      ),
    );
  }
}

class _PurchaseOrdersSubTab extends StatelessWidget {
  const _PurchaseOrdersSubTab({required this.controller});
  final AdminResourcesController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ResourcesChip(
              label: 'Orders',
              value: '${controller.purchaseOrders.length}',
            ),
            FilledButton.icon(
              onPressed: () => controller.openPurchaseOrderDialog(),
              icon: const Icon(Icons.shopping_bag_rounded),
              label: const Text('Create PO'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (controller.purchaseOrders.isEmpty)
          const _ResourcesEmpty(
            icon: Icons.shopping_bag_rounded,
            title: 'No purchase orders',
            message: 'Create and process purchase orders from draft to receipt.',
          )
        else
          ...controller.purchaseOrders.map(
            (item) => _CardShell(
              title: item.poNumber,
              subtitle: item.vendorName,
              actions: [
                OutlinedButton(
                  onPressed: () => controller.openPurchaseOrderDialog(existing: item),
                  child: const Text('Edit'),
                ),
                if (item.status == 'DRAFT')
                  OutlinedButton(
                    onPressed: () => controller.updatePurchaseOrderStatus(item, 'APPROVED'),
                    child: const Text('Approve'),
                  ),
                if (item.status == 'APPROVED')
                  OutlinedButton(
                    onPressed: () => controller.updatePurchaseOrderStatus(item, 'ORDERED'),
                    child: const Text('Order'),
                  ),
                if (item.status == 'ORDERED')
                  FilledButton.tonal(
                    onPressed: () => controller.updatePurchaseOrderStatus(item, 'RECEIVED'),
                    child: const Text('Receive'),
                  ),
              ],
              children: [
                _MetaText(label: 'Items', value: item.itemSummary.isEmpty ? '-' : item.itemSummary),
                _MetaText(label: 'Amount', value: item.totalAmount.toStringAsFixed(2)),
                _MetaText(label: 'Order Date', value: item.orderDate),
                _MetaText(label: 'Expected', value: item.expectedDate),
                _MetaText(label: 'Status', value: item.status),
              ],
            ),
          ),
      ],
    );
  }
}

class _VendorsSubTab extends StatelessWidget {
  const _VendorsSubTab({required this.controller});
  final AdminResourcesController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ResourcesChip(label: 'Vendors', value: '${controller.vendors.length}'),
            FilledButton.icon(
              onPressed: () => controller.openVendorDialog(),
              icon: const Icon(Icons.store_rounded),
              label: const Text('Add Vendor'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (controller.vendors.isEmpty)
          const _ResourcesEmpty(
            icon: Icons.store_rounded,
            title: 'No vendors',
            message: 'Manage supplier contacts and active vendor status.',
          )
        else
          ...controller.vendors.map(
            (item) => _CardShell(
              title: item.name,
              subtitle: item.contactPerson,
              actions: [
                OutlinedButton(
                  onPressed: () => controller.openVendorDialog(existing: item),
                  child: const Text('Edit'),
                ),
                FilledButton.tonal(
                  onPressed: () => controller.deleteVendor(item),
                  child: const Text('Delete'),
                ),
              ],
              children: [
                _MetaText(label: 'Phone', value: item.phone.isEmpty ? '-' : item.phone),
                _MetaText(label: 'Email', value: item.email.isEmpty ? '-' : item.email),
                _MetaText(label: 'Address', value: item.address.isEmpty ? '-' : item.address),
                _MetaText(label: 'Status', value: item.isActive ? 'ACTIVE' : 'INACTIVE'),
              ],
            ),
          ),
      ],
    );
  }
}

class _LibraryBooksSubTab extends StatelessWidget {
  const _LibraryBooksSubTab({required this.controller});

  final AdminResourcesController controller;

  @override
  Widget build(BuildContext context) {
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
              FilledButton.icon(
                onPressed: () => controller.openBookDialog(),
                icon: const Icon(Icons.library_add_rounded),
                label: const Text('Add Book'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (controller.libraryBooks.isEmpty)
            const _ResourcesEmpty(
              icon: Icons.local_library_rounded,
              title: 'No books found',
              message: 'Library books will appear here with live copy counts.',
            )
          else
            ...controller.libraryBooks.map(
              (item) => _BookCard(item: item, controller: controller),
            ),
        ],
      ),
    );
  }
}

class _LibraryCategoriesSubTab extends StatelessWidget {
  const _LibraryCategoriesSubTab({required this.controller});

  final AdminResourcesController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ResourcesChip(
              label: 'Categories',
              value: '${controller.libraryCategories.length}',
            ),
            FilledButton.icon(
              onPressed: () => controller.openLibraryCategoryDialog(),
              icon: const Icon(Icons.category_rounded),
              label: const Text('Add Category'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (controller.libraryCategories.isEmpty)
          const _ResourcesEmpty(
            icon: Icons.category_rounded,
            title: 'No categories',
            message: 'Create categories to organize your library catalog.',
          )
        else
          ...controller.libraryCategories.map(
            (item) => _CardShell(
              title: item.name,
              subtitle: item.description,
              actions: [
                OutlinedButton(
                  onPressed: () =>
                      controller.openLibraryCategoryDialog(existing: item),
                  child: const Text('Edit'),
                ),
                FilledButton.tonal(
                  onPressed: () => controller.deleteLibraryCategory(item),
                  child: const Text('Delete'),
                ),
              ],
              children: const [],
            ),
          ),
      ],
    );
  }
}

class _LibraryIssueReturnSubTab extends StatelessWidget {
  const _LibraryIssueReturnSubTab({required this.controller});

  final AdminResourcesController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ResourcesChip(
              label: 'Borrow Records',
              value: '${controller.libraryBorrows.length}',
            ),
            FilledButton.icon(
              onPressed: controller.issueBook,
              icon: const Icon(Icons.assignment_returned_rounded),
              label: const Text('Issue Book'),
            ),
          ],
        ),
        const SizedBox(height: 16),
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
    );
  }
}

class _LibraryCardsSubTab extends StatelessWidget {
  const _LibraryCardsSubTab({required this.controller});

  final AdminResourcesController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ResourcesChip(
              label: 'Student Cards',
              value: '${controller.libraryCards.length}',
            ),
            FilledButton.icon(
              onPressed: () => controller.openLibraryCardDialog(),
              icon: const Icon(Icons.badge_rounded),
              label: const Text('Issue Card'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (controller.libraryCards.isEmpty)
          const _ResourcesEmpty(
            icon: Icons.badge_rounded,
            title: 'No library cards',
            message: 'Issue student library cards for circulation flow.',
          )
        else
          ...controller.libraryCards.map(
            (item) => _CardShell(
              title: item.studentName,
              subtitle: 'Card: ${item.cardNo}',
              actions: [
                OutlinedButton(
                  onPressed: () => controller.openLibraryCardDialog(existing: item),
                  child: const Text('Edit'),
                ),
                FilledButton.tonal(
                  onPressed: () => controller.deleteLibraryCard(item),
                  child: const Text('Delete'),
                ),
              ],
              children: [
                _MetaText(label: 'Issued On', value: item.issuedOn),
                _MetaText(label: 'Status', value: item.isActive ? 'ACTIVE' : 'INACTIVE'),
              ],
            ),
          ),
      ],
    );
  }
}

class _LibraryFineSubTab extends StatelessWidget {
  const _LibraryFineSubTab({required this.controller});

  final AdminResourcesController controller;

  @override
  Widget build(BuildContext context) {
    final fine = controller.lateFineRule.value;
    final overdue = controller.libraryBorrows
        .where((e) => e.status != 'RETURNED' && (e.dueDate?.isBefore(DateTime.now()) ?? false))
        .toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ResourcesChip(label: 'Overdues', value: '${overdue.length}'),
            FilledButton.icon(
              onPressed: controller.openLateFineRuleDialog,
              icon: const Icon(Icons.rule_rounded),
              label: const Text('Configure Rule'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _CardShell(
          title: 'Late Fine Rule',
          subtitle: fine.type == 'fixed' ? 'Fixed fine' : 'Per day fine',
          actions: const [],
          children: [
            _MetaText(label: 'Amount', value: fine.amount.toStringAsFixed(2)),
            _MetaText(label: 'Grace Days', value: '${fine.graceDays}'),
          ],
        ),
        const SizedBox(height: 8),
        if (overdue.isEmpty)
          const _ResourcesEmpty(
            icon: Icons.price_check_rounded,
            title: 'No overdue borrows',
            message: 'Fine collection entries appear when due date is crossed.',
          )
        else
          ...overdue.map((item) {
            final overdueDays = DateTime.now().difference(item.dueDate!).inDays;
            final chargeDays = overdueDays > fine.graceDays ? overdueDays - fine.graceDays : 0;
            final fineValue = fine.type == 'fixed'
                ? fine.amount
                : chargeDays * fine.amount;
            return _CardShell(
              title: item.bookTitle.isEmpty ? 'Borrow Record' : item.bookTitle,
              subtitle: item.borrowerRefId,
              actions: const [],
              children: [
                _MetaText(label: 'Due', value: _dateText(item.dueDate)),
                _MetaText(label: 'Overdue Days', value: '$overdueDays'),
                _MetaText(label: 'Calculated Fine', value: fineValue.toStringAsFixed(2)),
              ],
            );
          }),
      ],
    );
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
