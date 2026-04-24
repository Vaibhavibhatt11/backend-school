import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/theme/app_color.dart';
import '../../../common/fonts/common_textstyle.dart';
import '../../../common/utils/responsive.dart';
import '../../../widgets/app_scaffold.dart';
import 'models/event_models.dart';
import 'student_events_controller.dart';

class StudentEventsScreen extends GetView<StudentEventsController> {
  const StudentEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Events',
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.w(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerCard(context),
            SizedBox(height: Responsive.h(context, 16)),
            _filterChips(context),
            SizedBox(height: Responsive.h(context, 14)),
            _eventsList(context),
            SizedBox(height: Responsive.h(context, 24)),
          ],
        ),
      ),
    );
  }

  Widget _headerCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(context, 16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.primary, AppColor.primaryDark.withValues(alpha: 0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(Responsive.w(context, 18)),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withValues(alpha: 0.28),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(Responsive.w(context, 10)),
            decoration: BoxDecoration(
              color: AppColor.base.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
            ),
            child: Icon(Icons.event_available_rounded, color: AppColor.base, size: Responsive.w(context, 24)),
          ),
          SizedBox(width: Responsive.w(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'School events',
                  style: AppTextStyle.titleLarge(context).copyWith(
                    color: AppColor.base,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: Responsive.h(context, 4)),
                Text(
                  'See new, upcoming and past events with details',
                  style: AppTextStyle.bodySmall(context).copyWith(
                    color: AppColor.base.withValues(alpha: 0.92),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChips(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedFilter.value;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _chip(context, label: 'All', selected: selected == null, onTap: () => controller.setFilter(null)),
            SizedBox(width: Responsive.w(context, 8)),
            _chip(
              context,
              label: 'New',
              selected: selected == EventCategory.newEvent,
              onTap: () => controller.setFilter(EventCategory.newEvent),
            ),
            SizedBox(width: Responsive.w(context, 8)),
            _chip(
              context,
              label: 'Upcoming',
              selected: selected == EventCategory.upcoming,
              onTap: () => controller.setFilter(EventCategory.upcoming),
            ),
            SizedBox(width: Responsive.w(context, 8)),
            _chip(
              context,
              label: 'Past',
              selected: selected == EventCategory.past,
              onTap: () => controller.setFilter(EventCategory.past),
            ),
          ],
        ),
      );
    });
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(context, 16),
            vertical: Responsive.h(context, 10),
          ),
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(
                    colors: [AppColor.primary, AppColor.primaryDark.withValues(alpha: 0.9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: selected ? null : AppColor.cardBackground,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? AppColor.primary : AppColor.borderLight,
            ),
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

  Widget _eventsList(BuildContext context) {
    return Obx(() {
      final list = controller.filteredEvents;
      if (list.isEmpty) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 34)),
          alignment: Alignment.center,
          child: Text(
            'No events in this category.',
            style: AppTextStyle.bodyMedium(context).copyWith(color: AppColor.textMuted),
          ),
        );
      }
      return Column(
        children: list.map((e) => _EventCard(item: e)).toList(),
      );
    });
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.item});
  final EventItem item;

  @override
  Widget build(BuildContext context) {
    final status = _status(item.category);
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.h(context, 10)),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showEventDetail(context, item),
          borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
          child: Padding(
            padding: EdgeInsets.all(Responsive.w(context, 14)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.w(context, 8),
                        vertical: Responsive.h(context, 4),
                      ),
                      decoration: BoxDecoration(
                        color: status.color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status.label,
                        style: AppTextStyle.caption(context).copyWith(
                          color: status.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right_rounded, color: AppColor.textMuted),
                  ],
                ),
                SizedBox(height: Responsive.h(context, 8)),
                Text(
                  item.title,
                  style: AppTextStyle.titleMedium(context).copyWith(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: Responsive.h(context, 6)),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.bodySmall(context).copyWith(color: AppColor.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEventDetail(BuildContext context, EventItem item) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final date = '${item.startAt.day} ${months[item.startAt.month - 1]} ${item.startAt.year}';
    final hour = item.startAt.hour % 12 == 0 ? 12 : item.startAt.hour % 12;
    final min = item.startAt.minute.toString().padLeft(2, '0');
    final ap = item.startAt.hour >= 12 ? 'PM' : 'AM';
    final time = '$hour:$min $ap';
    final status = _status(item.category);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.8),
        decoration: BoxDecoration(
          color: AppColor.base,
          borderRadius: BorderRadius.vertical(top: Radius.circular(Responsive.w(ctx, 24))),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            Responsive.w(ctx, 18),
            Responsive.h(ctx, 14),
            Responsive.w(ctx, 18),
            MediaQuery.of(ctx).padding.bottom + Responsive.h(ctx, 18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: Responsive.w(ctx, 40),
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColor.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: Responsive.h(ctx, 14)),
              Text(item.title, style: AppTextStyle.titleLarge(ctx).copyWith(fontWeight: FontWeight.w700)),
              SizedBox(height: Responsive.h(ctx, 10)),
              Wrap(
                spacing: Responsive.w(ctx, 8),
                runSpacing: Responsive.h(ctx, 8),
                children: [
                  _pill(ctx, status.label, status.color),
                  _pill(ctx, date, AppColor.primaryDark),
                  _pill(ctx, time, AppColor.primary),
                ],
              ),
              SizedBox(height: Responsive.h(ctx, 14)),
              _detailRow(ctx, 'Venue', item.venue),
              SizedBox(height: Responsive.h(ctx, 8)),
              _detailRow(ctx, 'Organizer', item.organizer),
              SizedBox(height: Responsive.h(ctx, 12)),
              Text(
                'Details',
                style: AppTextStyle.titleSmall(ctx).copyWith(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: Responsive.h(ctx, 6)),
              Text(
                item.description,
                style: AppTextStyle.bodyMedium(ctx).copyWith(height: 1.45),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(context, 10)),
      decoration: BoxDecoration(
        color: AppColor.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.border.withValues(alpha: 0.8)),
      ),
      child: RichText(
        text: TextSpan(
          style: AppTextStyle.bodySmall(context),
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                color: AppColor.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                color: AppColor.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(BuildContext context, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(context, 10),
        vertical: Responsive.h(context, 5),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyle.caption(context).copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  _EventStatus _status(EventCategory c) {
    switch (c) {
      case EventCategory.newEvent:
        return _EventStatus('New', AppColor.info);
      case EventCategory.upcoming:
        return _EventStatus('Upcoming', AppColor.primary);
      case EventCategory.past:
        return _EventStatus('Past', AppColor.textMuted);
    }
  }
}

class _EventStatus {
  const _EventStatus(this.label, this.color);
  final String label;
  final Color color;
}
