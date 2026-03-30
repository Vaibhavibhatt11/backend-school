import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../navbar/parent_bottom_nav_bar.dart';
import '../controllers/fees_controller.dart';

class FeesManagementView extends GetView<FeesController> {
  const FeesManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Fees Management',
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Get.toNamed(AppRoutes.PARENT_NOTIFICATIONS),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => Text(
                '${controller.studentName.value} • ${controller.studentGrade.value}',
                style: TextStyle(
                  color:
                      isDark ? AppColors.textSecondaryDark : Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Tab selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  _buildTab('Pending', 0),
                  _buildTab('Paid', 1),
                  _buildTab('Overdue', 2),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Total outstanding card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF429BEE)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Total Outstanding',
                        style: TextStyle(color: Colors.white70),
                      ),
                      Icon(Icons.account_balance_wallet, color: Colors.white70),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Text(
                      '\$${controller.totalOutstanding.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        controller.quickPayAll();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                      ),
                      child: const Text('Quick Pay All'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Recent Invoices header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Invoices',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(onPressed: controller.goToHistory, child: const Text('History')),
              ],
            ),
            const SizedBox(height: 8),
            // Invoices list
            Obx(
              () => Column(
                children:
                    controller.invoices.map((invoice) {
                      return _buildInvoiceCard(
                        title: (invoice['title'] ?? '').toString(),
                        subtitle: (invoice['subtitle'] ?? '').toString(),
                        amount: (invoice['amount'] is num)
                            ? (invoice['amount'] as num).toDouble()
                            : double.tryParse(invoice['amount']?.toString() ?? '') ?? 0,
                        dueDate: (invoice['dueDate'] ?? '').toString(),
                        onViewDetails:
                            () => controller.viewDetails(
                              invoice['id'] as String? ?? '',
                            ),
                        onPayNow:
                            () {
                              controller.payNow(invoice['id'] as String? ?? '');
                            },
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            // Overdue warning
            Obx(() {
              if (controller.overdueInvoices.isEmpty) return const SizedBox();
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${controller.overdueInvoices.length} Overdue Invoice Found',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          Text(
                            '${controller.overdueInvoices.first['title']} - \$${controller.overdueInvoices.first['amount']} (Due ${controller.overdueInvoices.first['dueDate']})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.red),
                  ],
                ),
              );
            }),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: const ParentBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildTab(String label, int index) {
    return Expanded(
      child: Obx(
        () => GestureDetector(
          onTap: () => controller.selectedTab.value = index,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color:
                  controller.selectedTab.value == index
                      ? (Theme.of(Get.context!).brightness == Brightness.dark
                          ? AppColors.surfaceDark
                          : Colors.white)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    controller.selectedTab.value == index
                        ? AppColors.primary
                        : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceCard({
    required String title,
    required String subtitle,
    required double amount,
    required String dueDate,
    required VoidCallback onViewDetails,
    required VoidCallback onPayNow,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            Theme.of(Get.context!).brightness == Brightness.dark
                ? AppColors.surfaceDark
                : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              Theme.of(Get.context!).brightness == Brightness.dark
                  ? AppColors.borderDark
                  : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.menu_book, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$$amount',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    dueDate,
                    style: const TextStyle(fontSize: 10, color: Colors.amber),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onViewDetails,
                  child: const Text('View Details'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: onPayNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Pay Now'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
