import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/theme/app_color.dart';
import '../../../common/fonts/common_textstyle.dart';
import '../../../common/utils/responsive.dart';
import '../../../widgets/app_scaffold.dart';
import 'models/timetable_models.dart';
import 'student_timetable_controller.dart';

class StudentTimetableScreen extends GetView<StudentTimetableController> {
  const StudentTimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Timetable',
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.w(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context),
            SizedBox(height: Responsive.h(context, 20)),
            Obx(() {
              final classIds = controller.availableClassIds;
              if (classIds.isEmpty) return const SizedBox.shrink();
              final classId = classIds.first;
              final timetable = controller.timetableForClass(classId);
              if (timetable == null) return const SizedBox.shrink();
              return _TimetableCard(
                timetable: timetable,
                controller: controller,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(Responsive.w(context, 10)),
          decoration: BoxDecoration(
            color: AppColor.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
          ),
          child: Icon(
            Icons.schedule_rounded,
            color: AppColor.primary,
            size: Responsive.w(context, 24),
          ),
        ),
        SizedBox(width: Responsive.w(context, 12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weekly timetable',
                style: AppTextStyle.titleLarge(context).copyWith(
                  color: AppColor.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: Responsive.h(context, 2)),
              Text(
                'Mon – Fri • Tap a slot for details',
                style: AppTextStyle.caption(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

}

class _TimetableCard extends StatelessWidget {
  const _TimetableCard({required this.timetable, required this.controller});
  final ClassTimetable timetable;
  final StudentTimetableController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.base,
        borderRadius: BorderRadius.circular(Responsive.w(context, 18)),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppColor.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: Responsive.h(context, 16),
              horizontal: Responsive.w(context, 18),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.primary,
                  AppColor.primaryDark.withValues(alpha: 0.88),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primaryDark.withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(Responsive.w(context, 8)),
                  decoration: BoxDecoration(
                    color: AppColor.base.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(Responsive.w(context, 10)),
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    color: AppColor.base,
                    size: Responsive.w(context, 22),
                  ),
                ),
                SizedBox(width: Responsive.w(context, 12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timetable.classLabel,
                        style: TextStyle(
                          fontSize: Responsive.sp(context, 18),
                          fontWeight: FontWeight.w700,
                          color: AppColor.base,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: Responsive.h(context, 2)),
                      Text(
                        'Mon – Fri • 8 periods',
                        style: TextStyle(
                          fontSize: Responsive.sp(context, 11),
                          fontWeight: FontWeight.w500,
                          color: AppColor.base.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: EdgeInsets.all(Responsive.w(context, 12)),
              child: SizedBox(
                height: _TimetableGrid.computeHeight(context),
                child: _TimetableGrid(
                  timetable: timetable,
                  controller: controller,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimetableGrid extends StatelessWidget {
  const _TimetableGrid({required this.timetable, required this.controller});
  final ClassTimetable timetable;
  final StudentTimetableController controller;

  static const int _periods = 8;
  static const double _timeColWidth = 58;
  static const double _cellWidth = 76;
  static const double _cellHeight = 60;
  static const double _headerHeight = 44;
  static const double _rowSpacing = 8;

  /// Total height so the grid can be given bounded constraints inside a horizontal scroll.
  static double computeHeight(BuildContext context) {
    return _headerHeight + _rowSpacing + _periods * (_cellHeight + _rowSpacing);
  }

  @override
  Widget build(BuildContext context) {
    final dayCount = kTimetableDayLabels.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day headers row
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              width: _timeColWidth,
              height: _headerHeight,
              child: Center(
                child: Text(
                  'Time',
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 10),
                    fontWeight: FontWeight.w700,
                    color: AppColor.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            SizedBox(width: Responsive.w(context, 6)),
            ...List.generate(dayCount, (d) {
              return Padding(
                padding: EdgeInsets.only(right: Responsive.w(context, 6)),
                child: Container(
                  width: _cellWidth,
                  height: _headerHeight,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColor.primary.withValues(alpha: 0.18),
                        AppColor.primary.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(Responsive.w(context, 10)),
                    border: Border.all(
                      color: AppColor.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    kTimetableDayLabels[d],
                    style: TextStyle(
                      fontSize: Responsive.sp(context, 12),
                      fontWeight: FontWeight.w700,
                      color: AppColor.primaryDark,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
        SizedBox(height: _rowSpacing),
        // Period rows
        ...List.generate(_periods, (p) {
          final period = p + 1;
          final timeLabel = kDefaultPeriodTimes[period - 1];
          return Padding(
            padding: EdgeInsets.only(bottom: _rowSpacing),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: _timeColWidth,
                  height: _cellHeight,
                  decoration: BoxDecoration(
                    color: AppColor.border.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(Responsive.w(context, 10)),
                    border: Border.all(color: AppColor.border.withValues(alpha: 0.8)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'P$period',
                        style: TextStyle(
                          fontSize: Responsive.sp(context, 10),
                          fontWeight: FontWeight.w700,
                          color: AppColor.primaryDark.withValues(alpha: 0.8),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        timeLabel,
                        style: TextStyle(
                          fontSize: Responsive.sp(context, 9),
                          fontWeight: FontWeight.w500,
                          color: AppColor.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: Responsive.w(context, 6)),
                ...List.generate(dayCount, (d) {
                  final slot = controller.getSlot(timetable.classId, d, period);
                  return Padding(
                    padding: EdgeInsets.only(right: Responsive.w(context, 6)),
                    child: _Cell(slot: slot),
                  );
                }),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({this.slot});
  final TimetableSlot? slot;

  static const double _cellWidth = 76;
  static const double _cellHeight = 60;

  @override
  Widget build(BuildContext context) {
    final hasSlot = slot != null;
    return Container(
      width: _cellWidth,
      height: _cellHeight,
      decoration: BoxDecoration(
        color: hasSlot
            ? AppColor.cardHighlight
            : AppColor.border.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(Responsive.w(context, 10)),
        border: Border.all(
          color: hasSlot
              ? AppColor.primary.withValues(alpha: 0.35)
              : AppColor.border.withValues(alpha: 0.6),
          width: hasSlot ? 1.5 : 1,
        ),
        boxShadow: hasSlot
            ? [
                BoxShadow(
                  color: AppColor.primary.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: hasSlot
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showSlotBottomSheet(context, slot!),
                borderRadius: BorderRadius.circular(Responsive.w(context, 10)),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(context, 6),
                    vertical: Responsive.h(context, 8),
                  ),
                  child: Center(
                    child: Text(
                      slot!.subject,
                      style: TextStyle(
                        fontSize: Responsive.sp(context, 12),
                        fontWeight: FontWeight.w600,
                        color: AppColor.primaryDark,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                '—',
                style: TextStyle(
                  fontSize: Responsive.sp(context, 14),
                  fontWeight: FontWeight.w300,
                  color: AppColor.textMuted.withValues(alpha: 0.6),
                ),
              ),
            ),
    );
  }

  void _showSlotBottomSheet(BuildContext context, TimetableSlot slot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
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
              width: double.infinity,
              margin: EdgeInsets.only(top: Responsive.h(context, 20)),
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(context, 20),
                vertical: Responsive.h(context, 16),
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
                      Icons.menu_book_rounded,
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
                          slot.subject,
                          style: TextStyle(
                            fontSize: Responsive.sp(context, 20),
                            fontWeight: FontWeight.w700,
                            color: AppColor.base,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: Responsive.h(context, 4)),
                        Text(
                          '${slot.startTime} – ${slot.endTime}',
                          style: TextStyle(
                            fontSize: Responsive.sp(context, 13),
                            fontWeight: FontWeight.w500,
                            color: AppColor.base.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(Responsive.w(context, 20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (slot.teacher != null) ...[
                    _SlotDetailRow(
                      icon: Icons.person_outline_rounded,
                      label: slot.teacher!,
                    ),
                    SizedBox(height: Responsive.h(context, 12)),
                  ],
                  if (slot.room != null) ...[
                    _SlotDetailRow(
                      icon: Icons.room_rounded,
                      label: 'Room ${slot.room}',
                    ),
                    SizedBox(height: Responsive.h(context, 12)),
                  ],
                  SizedBox(height: Responsive.h(context, 8)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotDetailRow extends StatelessWidget {
  const _SlotDetailRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(context, 14),
        vertical: Responsive.h(context, 12),
      ),
      decoration: BoxDecoration(
        color: AppColor.cardBackground,
        borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
        border: Border.all(color: AppColor.border.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColor.primary),
          SizedBox(width: Responsive.w(context, 12)),
          Expanded(
            child: Text(
              label,
              style: AppTextStyle.bodyMedium(context).copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
