import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/core/widgets/custom_app_bar.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_inventory_controller.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/utils/safe_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffInventoryHubView extends GetView<StaffInventoryController> {
  const StaffInventoryHubView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: CustomAppBar(
        title: 'Inventory & Lab Management',
        actions: [
          IconButton(
            onPressed: controller.refreshData,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.assets.isEmpty && controller.inventoryItems.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildKPIRow(isDark),
              const SizedBox(height: 32),
              _buildSectionLabel('Manage', isDark),
              const SizedBox(height: 16),
              _buildNavGrid(isDark, context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildKPIRow(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? AppColors.textDark : AppColors.textLight)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _kpiCard('Total Equipment', '${controller.totalAssets.value}', Icons.science_rounded, const Color(0xFF5C7CFA), isDark)),
          const SizedBox(width: 12),
          Expanded(child: _kpiCard('Low Stock Alerts', '${controller.lowStockCount.value}', Icons.warning_amber_rounded, const Color(0xFFFF922B), isDark)),
          const SizedBox(width: 12),
          Expanded(child: _kpiCard('Pending POs', '${controller.pendingPOCount.value}', Icons.shopping_bag_rounded, const Color(0xFF40C057), isDark)),
        ]),
      ],
    );
  }

  Widget _kpiCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 28)),
        const SizedBox(height: 12),
        Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: isDark ? AppColors.textDark : AppColors.textLight)),
        const SizedBox(height: 4),
        Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
      ]),
    );
  }

  Widget _buildSectionLabel(String label, bool isDark) {
    return Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? AppColors.textDark : AppColors.textLight));
  }

  Widget _buildNavGrid(bool isDark, BuildContext context) {
    final cards = [
      _NavItem('Lab Equipment', 'Track and manage lab assets & equipment', Icons.science_rounded, const Color(0xFF5C7CFA), AppRoutes.STAFF_INVENTORY_EQUIPMENT),
      _NavItem('Inventory Tracking', 'Monitor stock levels and movements', Icons.inventory_2_rounded, const Color(0xFFFF922B), AppRoutes.STAFF_INVENTORY_TRACKING),
      _NavItem('Purchase Orders', 'Raise POs and manage vendors', Icons.shopping_bag_rounded, const Color(0xFF40C057), AppRoutes.STAFF_INVENTORY_PURCHASE_ORDERS),
    ];
    return Column(
      children: cards.map((item) => _navCard(item, isDark)).toList(),
    );
  }

  Widget _navCard(_NavItem item, bool isDark) {
    return GestureDetector(
      onTap: () => SafeNavigation.toNamed(item.route),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: item.color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(item.icon, color: item.color, size: 32)),
          const SizedBox(width: 20),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? AppColors.textDark : AppColors.textLight)),
            const SizedBox(height: 4),
            Text(item.subtitle, style: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          ])),
          Icon(Icons.chevron_right_rounded, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
        ]),
      ),
    );
  }
}

class _NavItem {
  final String title, subtitle, route;
  final IconData icon;
  final Color color;
  const _NavItem(this.title, this.subtitle, this.icon, this.color, this.route);
}
