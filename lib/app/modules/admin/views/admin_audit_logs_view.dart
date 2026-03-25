import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/navbar/admin_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_audit_logs_controller.dart';

class AdminAuditLogsView extends GetView<AdminAuditLogsController> {
  const AdminAuditLogsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with filter
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Audit Logs',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.filter_list,
                        color: AppColors.primary,
                      ),
                      onPressed: () => Get.snackbar('Filter', 'Filter logs'),
                    ),
                  ),
                ],
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: controller.onSearch,
                decoration: InputDecoration(
                  hintText: 'Search by user, action or date...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor:
                      isDark ? AppColors.surfaceDark : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Filter chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterChip('All Logs', 0),
                  _buildFilterChip('Logins', 1),
                  _buildFilterChip('Fee Edits', 2),
                  _buildFilterChip('Config', 3),
                  _buildFilterChip('Users', 4),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Logs list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (controller.logsToday.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Today',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    ...controller.logsToday.map(
                      (log) => _buildLogItem(log, isDark),
                    ),
                  ],
                  if (controller.logsYesterday.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Yesterday - Oct 23',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    ...controller.logsYesterday.map(
                      (log) => _buildLogItem(log, isDark),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        const CircularProgressIndicator(strokeWidth: 2),
                        const SizedBox(height: 8),
                        const Text(
                          'Loading historical logs...',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AdminBottomNavBar(
        currentIndex: 2,
      ), // Reports tab but audit logs is under reports? We'll keep as is.
    );
  }

  Widget _buildFilterChip(String label, int index) {
    return Obx(() {
      final selected = controller.selectedFilter.value == label;
      return GestureDetector(
        onTap: () => controller.onFilter(label),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color:
                selected
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildLogItem(AuditLog log, bool isDark) {
    return GestureDetector(
      onTap: () => controller.onLogTap(log),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getIconColor(log.action).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIcon(log.action),
                color: _getIconColor(log.action),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          log.action,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        log.time,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Admin: ${log.admin}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  if (log.ip != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'IP: ${log.ip}',
                            style: const TextStyle(fontSize: 8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (log.details != null && log.details!.contains('App'))
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              log.details!.split(' ').last,
                              style: const TextStyle(fontSize: 8),
                            ),
                          ),
                      ],
                    ),
                  ],
                  if (log.details != null && !log.details!.contains('App'))
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        log.details!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  if (log.isCritical)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.purple.shade100),
                      ),
                      child: const Text(
                        'Critical Change',
                        style: TextStyle(fontSize: 8, color: Colors.purple),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String action) {
    if (action.contains('Login')) return Icons.login;
    if (action.contains('Fee')) return Icons.payments;
    if (action.contains('Permission') || action.contains('Update')) {
      return Icons.settings_suggest;
    }
    if (action.contains('Failed')) return Icons.error_outline;
    if (action.contains('Announcement')) return Icons.campaign;
    return Icons.info;
  }

  Color _getIconColor(String action) {
    if (action.contains('Login')) return Colors.blue;
    if (action.contains('Fee')) return Colors.amber;
    if (action.contains('Permission')) return Colors.purple;
    if (action.contains('Failed')) return Colors.red;
    if (action.contains('Announcement')) return Colors.green;
    return Colors.grey;
  }
}
