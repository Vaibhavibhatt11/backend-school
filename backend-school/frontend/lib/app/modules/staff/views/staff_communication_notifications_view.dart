import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/core/widgets/custom_app_bar.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_communication_controller.dart';
import 'package:erp_frontend/app/modules/staff/models/staff_communication_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffCommunicationNotificationsView extends StatefulWidget {
  const StaffCommunicationNotificationsView({super.key});

  @override
  State<StaffCommunicationNotificationsView> createState() =>
      _StaffCommunicationNotificationsViewState();
}

class _StaffCommunicationNotificationsViewState
    extends State<StaffCommunicationNotificationsView> {
  late final StaffCommunicationController controller;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    controller = Get.find<StaffCommunicationController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadNotifications(showErrors: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: CustomAppBar(
        title: 'Notifications',
        actions: [
          TextButton(
            onPressed: controller.markAllNotificationsRead,
            child: const Text('Mark all read'),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => controller.loadNotifications(showErrors: true),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Obx(() {
        final items = controller.notificationResults(
          query: _searchController.text,
          filter: _selectedFilter,
        );
        final loading = controller.isNotificationsLoading.value;
        final error = controller.notificationError.value;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live School Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Review real-time items from school communication and keep your inbox organized.',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search title, category, or body',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor:
                          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      'ALL',
                      'UNREAD',
                      'TASKS',
                      'ANNOUNCEMENTS',
                      'EXAMS',
                      'MEETINGS',
                    ].map((filter) {
                      return _NotificationFilterChip._internal(filter);
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (loading && items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (items.isEmpty)
              _EmptyNotificationState(
                label: error.isNotEmpty
                    ? error
                    : 'No notifications available for this filter.',
              )
            else
              ...items.map(
                (item) => _NotificationCard(
                  item: item,
                  onTap: () => controller.markNotificationRead(item.id),
                ),
              ),
          ],
        );
      }),
    );
  }

  void updateFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }
}

class _NotificationFilterChip extends StatelessWidget {
  const _NotificationFilterChip._internal(this.filter);

  final String filter;

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<
        _StaffCommunicationNotificationsViewState>();
    final selected = state?._selectedFilter == filter;
    return ChoiceChip(
      label: Text(filter),
      selected: selected,
      onSelected: (_) {
        if (state == null) return;
        state.updateFilter(filter);
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(color: selected ? Colors.white : null),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item, required this.onTap});

  final StaffNotificationRecord item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: item.isRead
            ? (isDark ? AppColors.surfaceDark : Colors.white)
            : AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: item.isRead
              ? (isDark ? AppColors.borderDark : AppColors.borderLight)
              : AppColors.primary.withValues(alpha: 0.35),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _colorForCategory(item.category).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            _iconForCategory(item.category),
            color: _colorForCategory(item.category),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
              ),
            ),
            if (!item.isRead)
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Pill(
                  label: item.category.toUpperCase(),
                  color: _colorForCategory(item.category),
                ),
                _Pill(
                  label: item.status.toUpperCase(),
                  color: item.isRead ? Colors.grey : AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              item.body.isEmpty ? 'No body preview available.' : item.body,
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(item.createdAt),
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _iconForCategory(String category) {
    switch (category.toUpperCase()) {
      case 'TASKS':
        return Icons.task_alt_rounded;
      case 'ANNOUNCEMENTS':
        return Icons.campaign_rounded;
      case 'EXAMS':
        return Icons.assignment_rounded;
      case 'MEETINGS':
        return Icons.groups_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  static Color _colorForCategory(String category) {
    switch (category.toUpperCase()) {
      case 'TASKS':
        return Colors.teal;
      case 'ANNOUNCEMENTS':
        return Colors.orange;
      case 'EXAMS':
        return Colors.indigo;
      case 'MEETINGS':
        return Colors.green;
      default:
        return AppColors.primary;
    }
  }

  static String _formatDate(DateTime value) {
    final diff = DateTime.now().difference(value);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} days ago';
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _EmptyNotificationState extends StatelessWidget {
  const _EmptyNotificationState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}
