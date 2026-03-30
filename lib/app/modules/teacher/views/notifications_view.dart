import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/teacher/models/teacher_models.dart';
import 'package:erp_frontend/app/navbar/teacher_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 12),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: controller.markAllAsRead,
                  child: const Text('Mark all as read'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Notifications list grouped by date
          Expanded(
            child: Obx(() {
              final today = <NotificationItem>[];
              final yesterday = <NotificationItem>[];
              final older = <NotificationItem>[];

              for (var n in controller.notifications) {
                if (n.timestamp.day == DateTime.now().day) {
                  today.add(n);
                } else if (n.timestamp.day ==
                    DateTime.now().subtract(const Duration(days: 1)).day) {
                  yesterday.add(n);
                } else {
                  older.add(n);
                }
              }

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  if (today.isNotEmpty) _buildGroup('TODAY', today),
                  if (yesterday.isNotEmpty) _buildGroup('YESTERDAY', yesterday),
                  if (older.isNotEmpty) _buildGroup('OLDER', older),
                ],
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: const TeacherBottomNavBar(currentIndex: -1),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.filter_list),
      ),
    );
  }

  Widget _buildGroup(String title, List<NotificationItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        ...items.map((item) => _buildNotificationTile(item)),
      ],
    );
  }

  Widget _buildNotificationTile(NotificationItem item) {
    Color categoryColor;
    IconData categoryIcon;
    switch (item.category) {
      case 'Attendance':
        categoryColor = AppColors.primary;
        categoryIcon = Icons.event_busy;
        break;
      case 'Principal':
        categoryColor = Colors.amber;
        categoryIcon = Icons.campaign;
        break;
      case 'System':
        categoryColor = Colors.blue;
        categoryIcon = Icons.update;
        break;
      case 'Timetable':
        categoryColor = Colors.purple;
        categoryIcon = Icons.schedule;
        break;
      case 'Reports':
        categoryColor = Colors.green;
        categoryIcon = Icons.description;
        break;
      default:
        categoryColor = Colors.grey;
        categoryIcon = Icons.notifications;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.isRead ? Colors.white : AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              item.isRead
                  ? Colors.grey.shade200
                  : AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(categoryIcon, color: categoryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _timeAgo(item.timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  item.body,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          if (!item.isRead)
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

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} days ago';
  }
}
