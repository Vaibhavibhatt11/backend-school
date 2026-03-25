import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../navbar/parent_bottom_nav_bar.dart';
import '../controllers/invoice_detail_controller.dart';

class InvoiceDetailView extends GetView<InvoiceDetailController> {
  const InvoiceDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Invoice Details',
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.invoiceId.value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Issued on ${controller.issuedDate.value}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      controller.status.value,
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Student card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      'https://via.placeholder.com/60',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () => Text(
                          controller.studentName.value,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Obx(
                        () => Text(
                          controller.studentDetail.value,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Due date and total due
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Due Date',
                    controller.dueDate.value,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    'Total Due',
                    '\$${controller.totalDue.value}',
                    AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Fee breakdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Fee Breakdown',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '4 Items',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Obx(
                () => Column(
                  children:
                      controller.breakdown.map((item) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.school,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['item']! as String,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      item['description']! as String,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '\$${item['amount']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      (item['amount'] as num?) != null && (item['amount'] as num) < 0 ? Colors.green : null,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Subtotal, tax, total
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    'Subtotal',
                    '\$${controller.subtotal.value.toStringAsFixed(2)}',
                  ),
                  _buildSummaryRow(
                    'Tax (IGST 5%)',
                    '\$${controller.tax.value.toStringAsFixed(2)}',
                  ),
                  const Divider(),
                  _buildSummaryRow(
                    'Total Amount',
                    '\$${controller.total.value.toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Payment history
            const Text(
              'Payment History',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Column(
                children:
                    controller.paymentHistory.map((payment) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Partial Payment Received',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Ref ID: ${payment['ref']}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${payment['amount']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  '${payment['date']} • ${payment['method']}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: const ParentBottomNavBar(currentIndex: 2),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton.extended(
          onPressed: controller.payBalance,
          label: const Text('Pay Balance (\$1,240)'),
          icon: const Icon(Icons.payments),
          backgroundColor: AppColors.primary,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildInfoCard(String label, String value, Color color) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: isTotal ? FontWeight.bold : null),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : null,
              fontSize: isTotal ? 20 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
