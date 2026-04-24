import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/core/widgets/custom_app_bar.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_inventory_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffInventoryTrackingView extends GetView<StaffInventoryController> {
  const StaffInventoryTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: const CustomAppBar(title: 'Inventory Tracking'),
      body: Obx(() {
        if (controller.isLoading.value && controller.inventoryItems.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return DefaultTabController(
          length: 2,
          child: Column(children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: TabBar(
                isScrollable: false,
                indicator: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                indicatorPadding: const EdgeInsets.all(6),
                dividerColor: Colors.transparent,
                labelColor: AppColors.primary,
                unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                tabs: const [Tab(text: 'Stock Items'), Tab(text: 'Transactions')],
              ),
            ),
            Expanded(child: TabBarView(children: [
              _buildItemsTab(isDark),
              _buildTransactionsTab(isDark),
            ])),
          ]),
        );
      }),
    );
  }

  Widget _buildItemsTab(bool isDark) {
    return RefreshIndicator(
      onRefresh: controller.refreshData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Obx(() {
              final lowStock = controller.inventoryItems.where((i) => i.isLowStock).length;
              return lowStock > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                      const SizedBox(width: 6),
                      Text('$lowStock low stock', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13)),
                    ]),
                  )
                : const SizedBox.shrink();
            }),
            Row(children: [
              OutlinedButton.icon(
                onPressed: controller.createStockMove,
                icon: const Icon(Icons.sync_alt_rounded, size: 18),
                label: const Text('Stock Move'),
                style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () => controller.openInventoryItemDialog(),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Item'),
                style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
            ]),
          ]),
          const SizedBox(height: 16),
          if (controller.inventoryItems.isEmpty)
            _empty(isDark, Icons.inventory_2_rounded, 'No stock items', 'Add inventory items to track quantities.')
          else
            ...controller.inventoryItems.map((item) => _itemCard(item, isDark)),
        ],
      ),
    );
  }

  Widget _itemCard(InventoryItemRecord item, bool isDark) {
    final progress = item.lowStockThreshold > 0 ? (item.qty / (item.lowStockThreshold * 4)).clamp(0.0, 1.0) : 1.0;
    final barColor = item.isLowStock ? Colors.orange : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: item.isLowStock ? Colors.orange.withValues(alpha: 0.5) : (isDark ? AppColors.borderDark : AppColors.borderLight)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? AppColors.textDark : AppColors.textLight)),
            const SizedBox(height: 2),
            Text('SKU: ${item.sku}  ·  ${item.category}', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          ])),
          if (item.isLowStock)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: const Text('Low Stock', style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: LinearProgressIndicator(value: progress, color: barColor, backgroundColor: barColor.withValues(alpha: 0.1), minHeight: 8, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 12),
          Text('${item.qty} ${item.unit}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? AppColors.textDark : AppColors.textLight)),
        ]),
        const SizedBox(height: 4),
        Text('Threshold: ${item.lowStockThreshold} ${item.unit}', style: TextStyle(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
        const Divider(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          TextButton.icon(onPressed: () => controller.openInventoryItemDialog(existing: item), icon: const Icon(Icons.edit_rounded, size: 16), label: const Text('Edit'), style: TextButton.styleFrom(foregroundColor: Colors.blueAccent)),
          TextButton.icon(onPressed: () => controller.deleteInventoryItem(item), icon: const Icon(Icons.delete_outline_rounded, size: 16), label: const Text('Delete'), style: TextButton.styleFrom(foregroundColor: Colors.redAccent)),
        ]),
      ]),
    );
  }

  Widget _buildTransactionsTab(bool isDark) {
    if (controller.inventoryTransactions.isEmpty) {
      return _empty(isDark, Icons.swap_vert_rounded, 'No transactions', 'Stock movements will appear here.');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.inventoryTransactions.length,
      itemBuilder: (ctx, i) {
        final tx = controller.inventoryTransactions[i];
        final isIn = tx.type.toUpperCase() == 'IN';
        String date = '';
        if (tx.createdAt != null) {
          final d = tx.createdAt!;
          final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
          final h = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
          final ampm = d.hour >= 12 ? 'PM' : 'AM';
          date = '${months[d.month - 1]} ${d.day}, ${d.year} - ${h.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')} $ampm';
        }
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: (isIn ? Colors.green : Colors.red).withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(isIn ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: isIn ? Colors.green : Colors.red, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tx.itemName.isEmpty ? 'Unknown Item' : tx.itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              if (tx.note.isNotEmpty) ...[const SizedBox(height: 2), Text(tx.note, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight))],
              if (date.isNotEmpty) ...[const SizedBox(height: 2), Text(date, style: TextStyle(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight))],
            ])),
            Text('${isIn ? '+' : '-'}${tx.qty}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isIn ? Colors.green : Colors.red)),
          ]),
        );
      },
    );
  }

  Widget _empty(bool isDark, IconData icon, String title, String msg) {
    return Center(child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 64, color: AppColors.primary.withValues(alpha: 0.35)),
        const SizedBox(height: 16),
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? AppColors.textDark : AppColors.textLight)),
        const SizedBox(height: 8),
        Text(msg, textAlign: TextAlign.center, style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
      ]),
    ));
  }
}
