import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../navbar/parent_bottom_nav_bar.dart';
import '../controllers/notifications_controller.dart';

class NotificationsCenterView extends GetView<NotificationsController> {
  const NotificationsCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notifications',
        actions: [
          TextButton(
            onPressed: controller.markAllRead,
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:
                    ['All', 'Academic', 'Fees', 'Attendance', 'General']
                        .map(
                          (filter) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Obx(
                              () => ChoiceChip(
                                label: Text(filter),
                                selected:
                                    controller.selectedFilter.value == filter,
                                onSelected: (selected) {
                                  if (selected) controller.setFilter(filter);
                                },
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color:
                                      controller.selectedFilter.value == filter
                                          ? Colors.white
                                          : null,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
            const SizedBox(height: 20),
            // Notifications grouped by section
            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    controller.notifications.map((section) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              (section['section'] ?? '').toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...((section['items'] is List ? section['items'] as List : const [])
                              .map(
                            (item) => _buildNotificationCard(
                              Map<String, dynamic>.from(item as Map),
                              isDark,
                            ),
                          )),
                        ],
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: const ParentBottomNavBar(
        currentIndex: 0,
      ), // Notifications from home
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.search),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> item, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              item['unread'] as bool
                  ? AppColors.primary
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: item['unread'] as bool ? 2 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getIconColor(item['type']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIcon(item['type']),
              color: _getIconColor(item['type']),
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
                    Text(
                      (item['title'] ?? '').toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      (item['time'] ?? '').toString(),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text((item['description'] ?? '').toString()),
                if (item['action'] != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      (item['action'] ?? '').toString(),
                      style: const TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (item['unread'] as bool)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'fee':
        return Icons.account_balance_wallet;
      case 'attendance':
        return Icons.person_off;
      case 'exam':
        return Icons.assignment;
      case 'timetable':
        return Icons.event_note;
      case 'profile':
        return Icons.verified_user;
      default:
        return Icons.campaign;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'fee':
        return Colors.amber;
      case 'attendance':
        return Colors.red;
      case 'exam':
        return Colors.blue;
      case 'timetable':
        return Colors.purple;
      case 'profile':
        return Colors.green;
      default:
        return AppColors.primary;
    }
  }
}
