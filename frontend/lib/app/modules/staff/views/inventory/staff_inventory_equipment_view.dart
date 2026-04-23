import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/core/widgets/custom_app_bar.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_inventory_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffInventoryEquipmentView extends GetView<StaffInventoryController> {
  const StaffInventoryEquipmentView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: const CustomAppBar(title: 'Lab Equipment'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.openAssetDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Equipment'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.assets.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
            children: [
              _buildStats(isDark),
              const SizedBox(height: 24),
              if (controller.assets.isEmpty)
                _buildEmpty(isDark, Icons.science_rounded, 'No lab equipment yet', 'Add equipment to start tracking your lab assets.')
              else
                ...controller.assets.map((asset) => _buildAssetCard(asset, isDark)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStats(bool isDark) {
    final total = controller.assets.length;
    final available = controller.assets.where((a) => a.status == 'AVAILABLE').length;
    final inUse = controller.assets.where((a) => a.status == 'IN_USE').length;
    final maintenance = controller.assets.where((a) => a.status == 'MAINTENANCE').length;

    return Row(children: [
      Expanded(child: _statChip('Total', '$total', Colors.blueAccent, isDark)),
      const SizedBox(width: 8),
      Expanded(child: _statChip('Available', '$available', Colors.green, isDark)),
      const SizedBox(width: 8),
      Expanded(child: _statChip('In Use', '$inUse', Colors.orange, isDark)),
      const SizedBox(width: 8),
      Expanded(child: _statChip('Maintenance', '$maintenance', Colors.red, isDark)),
    ]);
  }

  Widget _statChip(String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
      ]),
    );
  }

  Widget _buildAssetCard(AssetRecord asset, bool isDark) {
    Color statusColor;
    switch (asset.status) {
      case 'IN_USE': statusColor = Colors.orange; break;
      case 'MAINTENANCE': statusColor = Colors.red; break;
      case 'RETIRED': statusColor = Colors.grey; break;
      default: statusColor = Colors.green;
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
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.science_rounded, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(asset.name, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isDark ? AppColors.textDark : AppColors.textLight)),
              const SizedBox(height: 2),
              Text(asset.assetCode, style: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(asset.status.replaceAll('_', ' '), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor)),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Wrap(spacing: 20, runSpacing: 8, children: [
            if (asset.category.isNotEmpty) _metaChip(Icons.category_rounded, asset.category, isDark),
            if (asset.assignedTo.isNotEmpty) _metaChip(Icons.location_on_rounded, asset.assignedTo, isDark),
            if (asset.purchaseDate.isNotEmpty) _metaChip(Icons.calendar_today_rounded, asset.purchaseDate, isDark),
          ]),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton.icon(onPressed: () => controller.openAssetDialog(existing: asset), icon: const Icon(Icons.edit_rounded, size: 16), label: const Text('Edit'), style: TextButton.styleFrom(foregroundColor: Colors.blueAccent)),
            TextButton.icon(onPressed: () => controller.deleteAsset(asset), icon: const Icon(Icons.delete_outline_rounded, size: 16), label: const Text('Remove'), style: TextButton.styleFrom(foregroundColor: Colors.redAccent)),
          ]),
        ),
      ]),
    );
  }

  Widget _metaChip(IconData icon, String label, bool isDark) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
    ]);
  }

  Widget _buildEmpty(bool isDark, IconData icon, String title, String msg) {
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
