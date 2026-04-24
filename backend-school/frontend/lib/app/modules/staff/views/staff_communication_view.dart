import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_communication_controller.dart';
import 'package:erp_frontend/app/modules/staff/models/staff_communication_models.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/utils/safe_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffCommunicationView extends StatefulWidget {
  const StaffCommunicationView({super.key});

  @override
  State<StaffCommunicationView> createState() => _StaffCommunicationViewState();
}

class _StaffCommunicationViewState extends State<StaffCommunicationView> {
  late final StaffCommunicationController controller;
  bool _prefetchedDirectories = false;

  @override
  void initState() {
    super.initState();
    controller = Get.find<StaffCommunicationController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_prefetchedDirectories) return;
      _prefetchedDirectories = true;
      if (controller.parentRecipients.isEmpty) {
        controller.loadRecipients(
          StaffMessageAudience.parent,
          showErrors: false,
        );
      }
      if (controller.studentRecipients.isEmpty) {
        controller.loadRecipients(
          StaffMessageAudience.student,
          showErrors: false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Obx(() {
        if (controller.isLoading.value &&
            controller.conversationThreads.isEmpty &&
            controller.announcementItems.isEmpty &&
            controller.notificationItems.isEmpty &&
            controller.meetingSchedules.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final recentThreads = controller.conversationThreads.take(3).toList();
        final recentAnnouncements =
            controller.announcementResults().take(3).toList();
        final upcomingMeetings = controller
            .meetingResults(filter: 'UPCOMING')
            .take(3)
            .toList();

        return RefreshIndicator(
          onRefresh: controller.loadCommunication,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Communication Center',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.textDark
                                : AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Parent messaging, student outreach, notices, notifications, and meetings in one place.',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.support_agent_rounded,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Staff Communication Hub',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _SummaryChip(
                          label: 'Threads',
                          value: '${controller.conversationThreads.length}',
                        ),
                        _SummaryChip(
                          label: 'Announcements',
                          value: '${controller.liveAnnouncementCount}',
                        ),
                        _SummaryChip(
                          label: 'Unread',
                          value: '${controller.unreadNotificationsCount}',
                        ),
                        _SummaryChip(
                          label: 'Meetings',
                          value: '${controller.scheduledMeetingCount}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => SafeNavigation.toNamed(
                        AppRoutes.STAFF_COMMUNICATION_MEETINGS,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                      ),
                      icon: const Icon(Icons.groups_rounded),
                      label: const Text('Schedule PTM'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 900;
                  final medium = constraints.maxWidth > 620;
                  final crossAxisCount = wide ? 3 : medium ? 2 : 1;
                  final itemWidth =
                      (constraints.maxWidth - ((crossAxisCount - 1) * 12)) /
                          crossAxisCount;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _ActionCard(
                        width: itemWidth,
                        title: 'Message Parents',
                        subtitle: 'Open parent directory and send direct updates.',
                        icon: Icons.family_restroom_rounded,
                        color: Colors.teal,
                        onTap: () => SafeNavigation.toNamed(
                          AppRoutes.STAFF_COMMUNICATION_RECIPIENTS,
                          arguments: {'audience': StaffMessageAudience.parent.value},
                        ),
                      ),
                      _ActionCard(
                        width: itemWidth,
                        title: 'Message Students',
                        subtitle: 'Reach active students with classroom follow-ups.',
                        icon: Icons.school_rounded,
                        color: Colors.orange,
                        onTap: () => SafeNavigation.toNamed(
                          AppRoutes.STAFF_COMMUNICATION_RECIPIENTS,
                          arguments: {'audience': StaffMessageAudience.student.value},
                        ),
                      ),
                      _ActionCard(
                        width: itemWidth,
                        title: 'Announcements',
                        subtitle: 'Create, save, and publish school notices.',
                        icon: Icons.campaign_rounded,
                        color: Colors.redAccent,
                        trailingText: '${controller.liveAnnouncementCount}',
                        onTap: () => SafeNavigation.toNamed(
                          AppRoutes.STAFF_COMMUNICATION_ANNOUNCEMENTS,
                        ),
                      ),
                      _ActionCard(
                        width: itemWidth,
                        title: 'Notifications',
                        subtitle: 'Review school notifications and mark them read.',
                        icon: Icons.notifications_active_rounded,
                        color: Colors.indigo,
                        trailingText: '${controller.unreadNotificationsCount}',
                        onTap: () => SafeNavigation.toNamed(
                          AppRoutes.STAFF_COMMUNICATION_NOTIFICATIONS,
                        ),
                      ),
                      _ActionCard(
                        width: itemWidth,
                        title: 'Parent-Teacher Meetings',
                        subtitle: 'Schedule PTMs and send invitation messages.',
                        icon: Icons.event_available_rounded,
                        color: Colors.green,
                        trailingText: '${controller.scheduledMeetingCount}',
                        onTap: () => SafeNavigation.toNamed(
                          AppRoutes.STAFF_COMMUNICATION_MEETINGS,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 22),
              _SectionHeader(
                title: 'Recent Conversations',
                actionLabel: 'View all',
                onAction: () => SafeNavigation.toNamed(
                  AppRoutes.STAFF_COMMUNICATION_RECIPIENTS,
                  arguments: {'audience': StaffMessageAudience.parent.value},
                ),
              ),
              const SizedBox(height: 10),
              if (recentThreads.isEmpty)
                _EmptyStateCard(
                  label: 'No recent chats yet. Start a parent or student conversation.',
                )
              else
                ...recentThreads.map(
                  (thread) => _InfoTile(
                    title: thread.recipientName,
                    subtitle: thread.lastMessage.isEmpty
                        ? 'Conversation ready'
                        : thread.lastMessage,
                    meta: _relativeTime(thread.updatedAt),
                    icon: Icons.chat_bubble_outline_rounded,
                    onTap: thread.audience != null && thread.recipientId != null
                        ? () => SafeNavigation.toNamed(
                              AppRoutes.STAFF_COMMUNICATION_CONVERSATION,
                              arguments: {
                                'audience': thread.audience!.value,
                                'recipientId': thread.recipientId,
                              },
                            )
                        : null,
                  ),
                ),
              const SizedBox(height: 18),
              _SectionHeader(
                title: 'Latest Announcements',
                actionLabel: 'Manage',
                onAction: () => SafeNavigation.toNamed(
                  AppRoutes.STAFF_COMMUNICATION_ANNOUNCEMENTS,
                ),
              ),
              const SizedBox(height: 10),
              if (recentAnnouncements.isEmpty)
                _EmptyStateCard(
                  label: 'No announcements available yet.',
                )
              else
                ...recentAnnouncements.map(
                  (item) => _InfoTile(
                    title: item.title,
                    subtitle: item.content.isEmpty ? item.audience : item.content,
                    meta: item.status,
                    icon: item.isUrgent
                        ? Icons.priority_high_rounded
                        : Icons.campaign_rounded,
                    onTap: () => SafeNavigation.toNamed(
                      AppRoutes.STAFF_COMMUNICATION_ANNOUNCEMENTS,
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              _SectionHeader(
                title: 'Upcoming Meetings',
                actionLabel: 'Schedule',
                onAction: () => SafeNavigation.toNamed(
                  AppRoutes.STAFF_COMMUNICATION_MEETINGS,
                ),
              ),
              const SizedBox(height: 10),
              if (upcomingMeetings.isEmpty)
                _EmptyStateCard(
                  label: 'No meetings scheduled yet.',
                )
              else
                ...upcomingMeetings.map(
                  (meeting) => _InfoTile(
                    title: meeting.title,
                    subtitle: meeting.purpose,
                    meta: _meetingDate(meeting.dateTime),
                    icon: Icons.groups_rounded,
                    onTap: () => SafeNavigation.toNamed(
                      AppRoutes.STAFF_COMMUNICATION_MEETINGS,
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  String _relativeTime(DateTime value) {
    final diff = DateTime.now().difference(value);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  String _meetingDate(DateTime value) {
    final months = const [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final local = value.toLocal();
    final hour = local.hour == 0
        ? 12
        : local.hour > 12
            ? local.hour - 12
            : local.hour;
    final suffix = local.hour >= 12 ? 'PM' : 'AM';
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.day} ${months[local.month - 1]} | $hour:$minute $suffix';
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.width,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.trailingText = '',
  });

  final double width;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String trailingText;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color),
                  ),
                  const Spacer(),
                  if (trailingText.isNotEmpty)
                    Text(
                      trailingText,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.textDark
                            : AppColors.textLight,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ),
        ),
        const Spacer(),
        TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.icon,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String meta;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              meta,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
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
