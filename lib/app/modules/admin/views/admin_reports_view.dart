import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/navbar/admin_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_reports_controller.dart';

class AdminReportsView extends GetView<AdminReportsController> {
  const AdminReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Reports',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'School Admin Portal',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
                Stack(
                  children: [
                    CircleAvatar(
                      backgroundImage: const NetworkImage(
                        'https://via.placeholder.com/150',
                      ),
                      radius: 20,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.fromBorderSide(
                            BorderSide(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Global Filters
            const Text(
              'GLOBAL FILTERS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildFilterButton(
                    icon: Icons.calendar_today,
                    label: 'RANGE',
                    value: controller.selectedRange.value,
                    onTap: controller.onRangeTap,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFilterButton(
                    icon: Icons.school,
                    label: 'CLASS',
                    value: controller.selectedClass.value,
                    onTap: controller.onClassTap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Attendance Report Card
            _buildReportCard(
              icon: Icons.how_to_reg,
              iconColor: Colors.blue,
              title: 'Attendance Report',
              description:
                  'Detailed breakdown of student and staff presence logs for the selected period.',
              badge: '94% Attendance',
              badgeColor: Colors.green,
              primaryAction: 'View Detailed Log',
              onPrimary: controller.onViewDetailedLog,
              secondaryActions: [
                ReportAction(
                  'PDF EXPORT',
                  Icons.picture_as_pdf,
                  controller.onPDFExport,
                ),
                ReportAction(
                  'EXCEL',
                  Icons.table_view,
                  controller.onExcelExport,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Fee Collections Card
            _buildReportCard(
              icon: Icons.payments,
              iconColor: Colors.amber,
              title: 'Fee Collections',
              description:
                  'Status of tuition fees, pending invoices, and historical payment collections.',
              badge: '\$4,250.00',
              badgeColor: Colors.red,
              badgePrefix: 'Outstanding',
              primaryAction: 'Collection Analysis',
              onPrimary: controller.onCollectionAnalysis,
              secondaryActions: [
                ReportAction(
                  'PDF EXPORT',
                  Icons.picture_as_pdf,
                  controller.onPDFExport,
                ),
                ReportAction(
                  'EXCEL',
                  Icons.table_view,
                  controller.onExcelExport,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Exam Performance (coming soon)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.auto_graph, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Exam Performance',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Coming soon for Mid-Terms',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AdminBottomNavBar(currentIndex: 2), // Reports tab
    );
  }

  Widget _buildFilterButton({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              Theme.of(Get.context!).brightness == Brightness.dark
                  ? AppColors.surfaceDark
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 8, color: Colors.grey),
                  ),
                  Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const Icon(Icons.expand_more, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String badge,
    Color badgeColor = Colors.green,
    String? badgePrefix,
    required String primaryAction,
    required VoidCallback onPrimary,
    required List<ReportAction> secondaryActions,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            Theme.of(Get.context!).brightness == Brightness.dark
                ? AppColors.surfaceDark
                : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor),
              ),
              if (badgePrefix == null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      badgePrefix,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    Text(
                      badge,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: badgeColor,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPrimary,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                primaryAction,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children:
                secondaryActions.map((action) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: OutlinedButton(
                        onPressed: () => action.onTap(action.label),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color:
                                action.label.contains('PDF')
                                    ? AppColors.primary
                                    : Colors.green,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              action.icon,
                              size: 16,
                              color:
                                  action.label.contains('PDF')
                                      ? AppColors.primary
                                      : Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              action.label,
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    action.label.contains('PDF')
                                        ? AppColors.primary
                                        : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}

class ReportAction {
  final String label;
  final IconData icon;
  final Function(String) onTap;
  ReportAction(this.label, this.icon, this.onTap);
}
