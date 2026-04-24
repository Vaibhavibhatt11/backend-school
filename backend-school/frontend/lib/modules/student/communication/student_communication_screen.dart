import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/theme/app_color.dart';
import '../../../common/fonts/common_textstyle.dart';
import '../../../common/utils/responsive.dart';
import '../../../widgets/app_scaffold.dart';
import 'models/communication_models.dart';
import 'student_communication_controller.dart';

class StudentCommunicationScreen extends GetView<StudentCommunicationController> {
  const StudentCommunicationScreen({super.key, this.embedded = false});

  /// When true, renders only content (no AppScaffold/app bar),
  /// useful inside MainShell tabs that already provide app bar/nav.
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      padding: EdgeInsets.all(Responsive.w(context, 16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          SizedBox(height: Responsive.h(context, 20)),
          _buildFilterChips(context),
          SizedBox(height: Responsive.h(context, 16)),
          _buildScheduledMeetings(context),
          SizedBox(height: Responsive.h(context, 20)),
          _buildList(context),
          SizedBox(height: Responsive.h(context, 24)),
        ],
      ),
    );

    if (embedded) return content;

    return AppScaffold(
      title: 'Messages',
      body: content,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Obx(() {
      final unread = controller.unreadCount.value;
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(Responsive.w(context, 18)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.primary,
              AppColor.primaryDark.withValues(alpha: 0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(Responsive.w(context, 20)),
          boxShadow: [
            BoxShadow(
              color: AppColor.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(Responsive.w(context, 12)),
              decoration: BoxDecoration(
                color: AppColor.base.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
              ),
              child: Icon(
                Icons.chat_bubble_rounded,
                color: AppColor.base,
                size: Responsive.w(context, 28),
              ),
            ),
            SizedBox(width: Responsive.w(context, 16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Messages & alerts',
                    style: TextStyle(
                      fontSize: Responsive.sp(context, 18),
                      fontWeight: FontWeight.w700,
                      color: AppColor.base,
                    ),
                  ),
                  SizedBox(height: Responsive.h(context, 4)),
                  Text(
                    unread > 0
                        ? '$unread unread from school & faculty'
                        : 'All caught up',
                    style: TextStyle(
                      fontSize: Responsive.sp(context, 13),
                      color: AppColor.base.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            if (unread > 0)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(context, 10),
                  vertical: Responsive.h(context, 6),
                ),
                decoration: BoxDecoration(
                  color: AppColor.base.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(Responsive.w(context, 20)),
                ),
                child: Text(
                  '$unread new',
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 12),
                    fontWeight: FontWeight.w700,
                    color: AppColor.base,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildFilterChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(() {
        final selected = controller.selectedFilter.value;
        return Row(
          children: [
            _FilterChip(
              label: 'All',
              selected: selected == 'all',
              onTap: () => controller.setFilter('all'),
            ),
            SizedBox(width: Responsive.w(context, 10)),
            _FilterChip(
              label: 'Messages',
              selected: selected == 'message',
              onTap: () => controller.setFilter('message'),
            ),
            SizedBox(width: Responsive.w(context, 10)),
            _FilterChip(
              label: 'Alerts',
              selected: selected == 'alert',
              onTap: () => controller.setFilter('alert'),
            ),
            SizedBox(width: Responsive.w(context, 10)),
            _FilterChip(
              label: 'Announcements',
              selected: selected == 'announcement',
              onTap: () => controller.setFilter('announcement'),
            ),
            SizedBox(width: Responsive.w(context, 10)),
            _FilterChip(
              label: 'Meetings',
              selected: selected == 'meeting',
              onTap: () => controller.setFilter('meeting'),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildList(BuildContext context) {
    return Obx(() {
      final list = controller.filteredItems;
      if (controller.showMeetingsOnly) {
        return const SizedBox.shrink();
      }
      if (list.isEmpty) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 40)),
          alignment: Alignment.center,
          child: Column(
            children: [
              Icon(
                Icons.inbox_rounded,
                size: Responsive.w(context, 56),
                color: AppColor.textMuted.withValues(alpha: 0.6),
              ),
              SizedBox(height: Responsive.h(context, 12)),
              Text(
                'No messages in this category',
                style: AppTextStyle.bodyMedium(context).copyWith(
                  color: AppColor.textMuted,
                ),
              ),
            ],
          ),
        );
      }
      return Column(
        children: list.map((item) => _MessageCard(
          item: item,
          onTap: () {
            controller.markAsRead(item.id);
            _showDetailBottomSheet(context, item);
          },
        )).toList(),
      );
    });
  }

  Widget _buildScheduledMeetings(BuildContext context) {
    return Obx(() {
      if (!controller.showScheduledMeetingsSection) {
        return const SizedBox.shrink();
      }
      final meetings = controller.scheduledMeetings;
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(Responsive.w(context, 14)),
        decoration: BoxDecoration(
          color: AppColor.base,
          borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
          border: Border.all(color: AppColor.border.withValues(alpha: 0.8)),
          boxShadow: [
            BoxShadow(
              color: AppColor.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.video_call_rounded, color: AppColor.primary, size: Responsive.w(context, 20)),
                SizedBox(width: Responsive.w(context, 8)),
                Text(
                  'Scheduled meetings',
                  style: AppTextStyle.titleSmall(context).copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(context, 8),
                    vertical: Responsive.h(context, 2),
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${meetings.length}',
                    style: AppTextStyle.caption(context).copyWith(
                      color: AppColor.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: Responsive.h(context, 10)),
            if (meetings.isEmpty)
              Text(
                'No meetings scheduled yet.',
                style: AppTextStyle.bodySmall(context).copyWith(color: AppColor.textSecondary),
              )
            else
              Column(
                children: meetings.map((m) {
                  const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
                  final dateText = '${m.date.day} ${months[m.date.month - 1]} ${m.date.year}';
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showMeetingDetailSheet(context, m),
                      borderRadius: BorderRadius.circular(Responsive.w(context, 10)),
                      child: Container(
                    margin: EdgeInsets.only(bottom: Responsive.h(context, 8)),
                    padding: EdgeInsets.all(Responsive.w(context, 10)),
                    decoration: BoxDecoration(
                      color: AppColor.cardBackground,
                      borderRadius: BorderRadius.circular(Responsive.w(context, 10)),
                      border: Border.all(color: AppColor.border.withValues(alpha: 0.7)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${m.subject} • ${m.facultyName}',
                                style: AppTextStyle.bodyMedium(context).copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              m.status,
                              style: AppTextStyle.caption(context).copyWith(
                                color: AppColor.tokenGreenFont,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Responsive.h(context, 4)),
                        Text(
                          '${m.day}, $dateText • ${m.time}',
                          style: AppTextStyle.bodySmall(context).copyWith(color: AppColor.primaryDark),
                        ),
                        SizedBox(height: Responsive.h(context, 4)),
                        Text(
                          m.reason,
                          style: AppTextStyle.caption(context).copyWith(color: AppColor.textSecondary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
    });
  }

  void _showMeetingDetailSheet(BuildContext context, ScheduledMeeting meeting) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final dateText = '${meeting.date.day} ${months[meeting.date.month - 1]} ${meeting.date.year}';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(ctx).height * 0.8,
        ),
        decoration: BoxDecoration(
          color: AppColor.base,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Responsive.w(ctx, 24)),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.primaryDark.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: Responsive.h(ctx, 12)),
                child: Container(
                  width: Responsive.w(ctx, 40),
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColor.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: Responsive.h(ctx, 16)),
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(ctx, 20),
                vertical: Responsive.h(ctx, 16),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColor.primary,
                    AppColor.primaryDark.withValues(alpha: 0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(Responsive.w(ctx, 24)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(Responsive.w(ctx, 10)),
                    decoration: BoxDecoration(
                      color: AppColor.base.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(Responsive.w(ctx, 12)),
                    ),
                    child: Icon(
                      Icons.video_call_rounded,
                      color: AppColor.base,
                      size: Responsive.w(ctx, 24),
                    ),
                  ),
                  SizedBox(width: Responsive.w(ctx, 14)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Scheduled meeting',
                          style: TextStyle(
                            fontSize: Responsive.sp(ctx, 11),
                            fontWeight: FontWeight.w600,
                            color: AppColor.base.withValues(alpha: 0.9),
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: Responsive.h(ctx, 4)),
                        Text(
                          meeting.subject,
                          style: TextStyle(
                            fontSize: Responsive.sp(ctx, 18),
                            fontWeight: FontWeight.w700,
                            color: AppColor.base,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(Responsive.w(ctx, 20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MeetingDetailRow(
                      icon: Icons.person_rounded,
                      label: 'Faculty',
                      value: meeting.facultyName,
                    ),
                    SizedBox(height: Responsive.h(ctx, 10)),
                    _MeetingDetailRow(
                      icon: Icons.book_rounded,
                      label: 'Subject',
                      value: meeting.subject,
                    ),
                    SizedBox(height: Responsive.h(ctx, 10)),
                    _MeetingDetailRow(
                      icon: Icons.event_rounded,
                      label: 'Date',
                      value: dateText,
                    ),
                    SizedBox(height: Responsive.h(ctx, 10)),
                    _MeetingDetailRow(
                      icon: Icons.today_rounded,
                      label: 'Day',
                      value: meeting.day,
                    ),
                    SizedBox(height: Responsive.h(ctx, 10)),
                    _MeetingDetailRow(
                      icon: Icons.access_time_rounded,
                      label: 'Time',
                      value: meeting.time,
                    ),
                    SizedBox(height: Responsive.h(ctx, 10)),
                    _MeetingDetailRow(
                      icon: Icons.verified_rounded,
                      label: 'Status',
                      value: meeting.status,
                    ),
                    SizedBox(height: Responsive.h(ctx, 12)),
                    Text(
                      'Reason for meeting',
                      style: AppTextStyle.titleSmall(ctx).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: Responsive.h(ctx, 6)),
                    Text(
                      meeting.reason,
                      style: AppTextStyle.bodyMedium(ctx).copyWith(height: 1.45),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailBottomSheet(BuildContext context, CommunicationItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        decoration: BoxDecoration(
          color: AppColor.base,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Responsive.w(context, 24)),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.primaryDark.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: Responsive.h(context, 12)),
                child: Container(
                  width: Responsive.w(context, 40),
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColor.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: Responsive.h(context, 20)),
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(context, 20),
                vertical: Responsive.h(context, 16),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _colorForType(item.type),
                    _colorForType(item.type).withValues(alpha: 0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(Responsive.w(context, 24)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(Responsive.w(context, 10)),
                    decoration: BoxDecoration(
                      color: AppColor.base.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
                    ),
                    child: Icon(
                      _iconForType(item.type),
                      color: AppColor.base,
                      size: Responsive.w(context, 24),
                    ),
                  ),
                  SizedBox(width: Responsive.w(context, 14)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _labelForType(item.type),
                          style: TextStyle(
                            fontSize: Responsive.sp(context, 11),
                            fontWeight: FontWeight.w600,
                            color: AppColor.base.withValues(alpha: 0.9),
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: Responsive.h(context, 4)),
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: Responsive.sp(context, 18),
                            fontWeight: FontWeight.w700,
                            color: AppColor.base,
                          ),
                        ),
                        SizedBox(height: Responsive.h(context, 4)),
                        Text(
                          'From ${item.from}',
                          style: TextStyle(
                            fontSize: Responsive.sp(context, 12),
                            color: AppColor.base.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(Responsive.w(context, 20)),
                child: Text(
                  item.body,
                  style: AppTextStyle.bodyMedium(context).copyWith(
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _colorForType(CommunicationType t) {
    switch (t) {
      case CommunicationType.message:
        return AppColor.primary;
      case CommunicationType.alert:
        return AppColor.orange;
      case CommunicationType.announcement:
        return AppColor.info;
    }
  }

  static IconData _iconForType(CommunicationType t) {
    switch (t) {
      case CommunicationType.message:
        return Icons.mail_rounded;
      case CommunicationType.alert:
        return Icons.notifications_rounded;
      case CommunicationType.announcement:
        return Icons.campaign_rounded;
    }
  }

  static String _labelForType(CommunicationType t) {
    switch (t) {
      case CommunicationType.message:
        return 'MESSAGE';
      case CommunicationType.alert:
        return 'ALERT';
      case CommunicationType.announcement:
        return 'ANNOUNCEMENT';
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Responsive.w(context, 20)),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(context, 18),
            vertical: Responsive.h(context, 12),
          ),
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(
                    colors: [
                      AppColor.primary,
                      AppColor.primaryDark.withValues(alpha: 0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: selected ? null : AppColor.cardBackground,
            borderRadius: BorderRadius.circular(Responsive.w(context, 20)),
            border: Border.all(
              color: selected ? AppColor.primary : AppColor.borderLight,
              width: 1.5,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColor.primary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: AppTextStyle.titleSmall(context).copyWith(
              color: selected ? AppColor.base : AppColor.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.item, required this.onTap});
  final CommunicationItem item;
  final VoidCallback onTap;

  static String _formatDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inDays == 0) {
      if (diff.inHours == 0) return '${diff.inMinutes}m ago';
      return '${diff.inHours}h ago';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForType(item.type);
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.h(context, 12)),
      decoration: BoxDecoration(
        color: AppColor.base,
        borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
        border: Border.all(
          color: item.isRead
              ? AppColor.border.withValues(alpha: 0.8)
              : color.withValues(alpha: 0.35),
          width: item.isRead ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
          child: Padding(
            padding: EdgeInsets.all(Responsive.w(context, 16)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(Responsive.w(context, 10)),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
                  ),
                  child: Icon(
                    _iconForType(item.type),
                    color: color,
                    size: Responsive.w(context, 22),
                  ),
                ),
                SizedBox(width: Responsive.w(context, 14)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: AppTextStyle.titleMedium(context).copyWith(
                                fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _formatDate(item.date),
                            style: AppTextStyle.caption(context),
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.h(context, 6)),
                      Text(
                        item.body,
                        style: AppTextStyle.bodySmall(context).copyWith(
                          color: AppColor.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: Responsive.h(context, 6)),
                      Text(
                        item.from,
                        style: AppTextStyle.caption(context).copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!item.isRead)
                  Padding(
                    padding: EdgeInsets.only(left: Responsive.w(context, 8)),
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Color _colorForType(CommunicationType t) {
    switch (t) {
      case CommunicationType.message:
        return AppColor.primary;
      case CommunicationType.alert:
        return AppColor.orange;
      case CommunicationType.announcement:
        return AppColor.info;
    }
  }

  static IconData _iconForType(CommunicationType t) {
    switch (t) {
      case CommunicationType.message:
        return Icons.mail_rounded;
      case CommunicationType.alert:
        return Icons.notifications_rounded;
      case CommunicationType.announcement:
        return Icons.campaign_rounded;
    }
  }
}

class _MeetingDetailRow extends StatelessWidget {
  const _MeetingDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(context, 12),
        vertical: Responsive.h(context, 10),
      ),
      decoration: BoxDecoration(
        color: AppColor.cardBackground,
        borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
        border: Border.all(color: AppColor.border.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          Icon(icon, size: Responsive.w(context, 18), color: AppColor.primary),
          SizedBox(width: Responsive.w(context, 10)),
          Text(
            '$label: ',
            style: AppTextStyle.bodySmall(context).copyWith(
              color: AppColor.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyle.bodySmall(context).copyWith(
                color: AppColor.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
