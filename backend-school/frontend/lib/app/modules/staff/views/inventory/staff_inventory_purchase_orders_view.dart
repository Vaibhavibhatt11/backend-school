import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/core/widgets/custom_app_bar.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_inventory_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffInventoryPurchaseOrdersView extends GetView<StaffInventoryController> {
  const StaffInventoryPurchaseOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: const CustomAppBar(title: 'Purchase Orders'),
      body: Obx(() {
        if (controller.isLoading.value && controller.purchaseOrders.isEmpty) {
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
                tabs: const [Tab(text: 'Purchase Orders'), Tab(text: 'Vendors')],
              ),
            ),
            Expanded(child: TabBarView(children: [
              _buildPOTab(isDark),
              _buildVendorsTab(isDark),
            ])),
          ]),
        );
      }),
    );
  }

  Widget _buildPOTab(bool isDark) {
    return RefreshIndicator(
      onRefresh: controller.refreshData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${controller.purchaseOrders.length} Orders', style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? AppColors.textDark : AppColors.textLight)),
            FilledButton.icon(
              onPressed: () => controller.openPurchaseOrderDialog(),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Create PO'),
              style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            ),
          ]),
          const SizedBox(height: 16),
          if (controller.purchaseOrders.isEmpty)
            _empty(isDark, Icons.shopping_bag_rounded, 'No purchase orders', 'Create a purchase order to request new equipment or supplies.')
          else
            ...controller.purchaseOrders.map((po) => _buildPOCard(po, isDark)),
        ],
      ),
    );
  }

  Widget _buildPOCard(PurchaseOrderRecord po, bool isDark) {
    Color statusColor;
    IconData statusIcon;
    switch (po.status) {
      case 'APPROVED': statusColor = Colors.blue; statusIcon = Icons.check_circle_outline_rounded; break;
      case 'ORDERED': statusColor = Colors.orange; statusIcon = Icons.local_shipping_rounded; break;
      case 'RECEIVED': statusColor = Colors.green; statusIcon = Icons.inventory_rounded; break;
      case 'CANCELLED': statusColor = Colors.red; statusIcon = Icons.cancel_outlined; break;
      default: statusColor = Colors.grey; statusIcon = Icons.description_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(statusIcon, color: statusColor, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(po.poNumber, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? AppColors.textDark : AppColors.textLight)),
              const SizedBox(height: 2),
              Text(po.vendorName.isEmpty ? 'No vendor' : po.vendorName, style: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(po.status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor)),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (po.itemSummary.isNotEmpty)
              Text(po.itemSummary, style: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.attach_money_rounded, size: 16, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              const SizedBox(width: 4),
              Text('₹${po.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 20),
              if (po.orderDate.isNotEmpty) ...[
                Icon(Icons.calendar_today_rounded, size: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                const SizedBox(width: 4),
                Text(po.orderDate, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
              ],
              if (po.expectedDate.isNotEmpty) ...[
                const SizedBox(width: 12),
                Icon(Icons.event_rounded, size: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                const SizedBox(width: 4),
                Text('Due: ${po.expectedDate}', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
              ],
            ]),
          ]),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Wrap(spacing: 6, children: [
            TextButton.icon(
              onPressed: () => controller.openPurchaseOrderDialog(existing: po),
              icon: const Icon(Icons.edit_rounded, size: 15),
              label: const Text('Edit'),
              style: TextButton.styleFrom(foregroundColor: Colors.blueAccent, textStyle: const TextStyle(fontSize: 13)),
            ),
            if (po.status == 'DRAFT')
              TextButton.icon(
                onPressed: () => controller.updatePOStatus(po, 'APPROVED'),
                icon: const Icon(Icons.check_rounded, size: 15),
                label: const Text('Approve'),
                style: TextButton.styleFrom(foregroundColor: Colors.blue, textStyle: const TextStyle(fontSize: 13)),
              ),
            if (po.status == 'APPROVED')
              TextButton.icon(
                onPressed: () => controller.updatePOStatus(po, 'ORDERED'),
                icon: const Icon(Icons.local_shipping_rounded, size: 15),
                label: const Text('Mark Ordered'),
                style: TextButton.styleFrom(foregroundColor: Colors.orange, textStyle: const TextStyle(fontSize: 13)),
              ),
            if (po.status == 'ORDERED')
              TextButton.icon(
                onPressed: () => controller.updatePOStatus(po, 'RECEIVED'),
                icon: const Icon(Icons.inventory_rounded, size: 15),
                label: const Text('Mark Received'),
                style: TextButton.styleFrom(foregroundColor: Colors.green, textStyle: const TextStyle(fontSize: 13)),
              ),
            TextButton.icon(
              onPressed: () => controller.deletePurchaseOrder(po),
              icon: const Icon(Icons.delete_outline_rounded, size: 15),
              label: const Text('Delete'),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent, textStyle: const TextStyle(fontSize: 13)),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildVendorsTab(bool isDark) {
    return RefreshIndicator(
      onRefresh: controller.refreshData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (controller.vendors.isEmpty)
            _empty(isDark, Icons.store_rounded, 'No vendors', 'Vendors linked to purchase orders will appear here.')
          else
            ...controller.vendors.map((v) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.store_rounded, color: AppColors.primary, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(v.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? AppColors.textDark : AppColors.textLight)),
                  if (v.contactPerson.isNotEmpty) Text(v.contactPerson, style: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                  if (v.phone.isNotEmpty || v.email.isNotEmpty)
                    Text('${v.phone}  ${v.email}', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (v.isActive ? Colors.green : Colors.grey).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(v.isActive ? 'Active' : 'Inactive', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: v.isActive ? Colors.green : Colors.grey)),
                ),
              ]),
            )),
        ],
      ),
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
