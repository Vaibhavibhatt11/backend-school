import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/theme/app_color.dart';
import '../../../common/fonts/common_textstyle.dart';
import '../../../common/utils/responsive.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/section_header.dart';
import 'models/attendance_report_models.dart';
import 'student_attendance_controller.dart';

class StudentAttendanceScreen extends GetView<StudentAttendanceController> {
  const StudentAttendanceScreen({super.key});

  static const List<String> _periods = ['Daily', 'Week', 'Month', 'Year'];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Attendance',
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.w(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              final selectedPeriod = controller.reportPeriod.value;
              return _PeriodSelector(controller: controller, selectedPeriod: selectedPeriod);
            }),
            SizedBox(height: Responsive.h(context, 20)),
            _AttendancePinchHint(),
            SizedBox(height: Responsive.h(context, 12)),
            _AttendancePinchWrapper(controller: controller),
            SizedBox(height: Responsive.h(context, 24)),
            SectionHeader(title: 'Leave applications'),
            _LeaveApplicationsCard(controller: controller),
            SizedBox(height: Responsive.h(context, 24)),
          ],
        ),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.controller, required this.selectedPeriod});
  final StudentAttendanceController controller;
  final String selectedPeriod;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: StudentAttendanceScreen._periods.map((p) {
          final key = p.toLowerCase();
          final selected = selectedPeriod == key;
          return Padding(
            padding: EdgeInsets.only(right: Responsive.w(context, 10)),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.setReportPeriod(key),
                borderRadius: BorderRadius.circular(Responsive.w(context, 20)),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(context, 18),
                    vertical: Responsive.h(context, 10),
                  ),
                  decoration: BoxDecoration(
                    color: selected ? AppColor.primary : AppColor.cardBackground,
                    borderRadius: BorderRadius.circular(Responsive.w(context, 20)),
                    border: Border.all(
                      color: selected ? AppColor.primary : AppColor.borderLight,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    p,
                    style: AppTextStyle.titleSmall(context).copyWith(
                      color: selected ? AppColor.base : AppColor.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Shows a bottom sheet with the selected day's attendance report.
void _showDayReportSheet(BuildContext context, DayRecord record, StudentAttendanceController controller) {
  final date = record.date;
  final weekdayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final monthNames = ['January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'];
  final dayName = weekdayNames[date.weekday - 1];
  final dateStr = '${date.day} ${monthNames[date.month - 1]} ${date.year}';
  String status;
  IconData icon;
  Color color;
  if (record.isHoliday) {
    status = 'Holiday';
    icon = Icons.beach_access_rounded;
    color = AppColor.tokenYellowFont;
  } else if (record.isPresent) {
    status = record.isLate ? 'Present (Late)' : 'Present';
    icon = record.isLate ? Icons.schedule_rounded : Icons.check_circle_rounded;
    color = record.isLate ? AppColor.orange : AppColor.success;
  } else {
    status = 'Absent';
    icon = Icons.cancel_rounded;
    color = AppColor.error;
  }
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => Container(
      padding: EdgeInsets.fromLTRB(
        Responsive.w(ctx, 20),
        Responsive.h(ctx, 24),
        Responsive.w(ctx, 20),
        MediaQuery.of(ctx).padding.bottom + Responsive.h(ctx, 24),
      ),
      decoration: BoxDecoration(
        color: AppColor.base,
        borderRadius: BorderRadius.vertical(top: Radius.circular(Responsive.w(ctx, 20))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: Responsive.w(ctx, 40),
              height: 4,
              decoration: BoxDecoration(
                color: AppColor.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: Responsive.h(ctx, 20)),
          Text(dayName, style: AppTextStyle.label(ctx).copyWith(color: AppColor.textMuted)),
          SizedBox(height: Responsive.h(ctx, 4)),
          Text(dateStr, style: AppTextStyle.headlineSmall(ctx)),
          SizedBox(height: Responsive.h(ctx, 16)),
          Row(
            children: [
              Icon(icon, color: color, size: Responsive.w(ctx, 28)),
              SizedBox(width: Responsive.w(ctx, 12)),
              Text(status, style: AppTextStyle.titleLarge(ctx).copyWith(color: color)),
            ],
          ),
          SizedBox(height: Responsive.h(ctx, 24)),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                controller.goToWeekView(date);
              },
              icon: Icon(Icons.calendar_view_week_rounded, size: Responsive.w(ctx, 20)),
              label: const Text('View week'),
              style: TextButton.styleFrom(
                foregroundColor: AppColor.primary,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Hint for pinch gesture.
class _AttendancePinchHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Pinch out for week → month → year • Pinch in to zoom back',
        style: AppTextStyle.caption(context),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _LeaveApplicationsCard extends StatelessWidget {
  const _LeaveApplicationsCard({required this.controller});
  final StudentAttendanceController controller;

  static String _fmt(DateTime d) {
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Apply and view leave requests',
                style: AppTextStyle.titleSmall(context).copyWith(
                  color: AppColor.textSecondary,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showApplyLeaveSheet(context, controller),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Apply'),
                style: TextButton.styleFrom(foregroundColor: AppColor.primary),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(context, 8)),
          Obx(() {
            final leaves = controller.leaveApplications;
            if (leaves.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 8)),
                child: Text(
                  'No leave applications yet.',
                  style: AppTextStyle.bodySmall(context),
                ),
              );
            }
            return Column(
              children: leaves.map((l) {
                Color statusColor;
                if (l.status == 'Approved') {
                  statusColor = AppColor.success;
                } else if (l.status == 'Rejected') {
                  statusColor = AppColor.error;
                } else {
                  statusColor = AppColor.orange;
                }
                return Container(
                  margin: EdgeInsets.only(bottom: Responsive.h(context, 10)),
                  padding: EdgeInsets.all(Responsive.w(context, 12)),
                  decoration: BoxDecoration(
                    color: AppColor.base,
                    borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
                    border: Border.all(color: AppColor.border.withValues(alpha: 0.8)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(top: Responsive.h(context, 6)),
                        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                      ),
                      SizedBox(width: Responsive.w(context, 10)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${l.type} leave',
                              style: AppTextStyle.titleSmall(context),
                            ),
                            SizedBox(height: Responsive.h(context, 2)),
                            Text(
                              '${_fmt(l.fromDate)} - ${_fmt(l.toDate)}',
                              style: AppTextStyle.caption(context),
                            ),
                            SizedBox(height: Responsive.h(context, 2)),
                            Text(
                              l.reason,
                              style: AppTextStyle.bodySmall(context),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: Responsive.w(context, 8)),
                      Text(
                        l.status,
                        style: AppTextStyle.caption(context).copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}

void _showApplyLeaveSheet(BuildContext context, StudentAttendanceController controller) {
  String leaveType = 'Sick';
  DateTime? fromDate;
  DateTime? toDate;
  final reasonCtrl = TextEditingController();

  Future<void> pickDate(bool isFrom, StateSetter setSheet) async {
    final now = DateTime.now();
    final initial = isFrom ? (fromDate ?? now) : (toDate ?? fromDate ?? now);
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      initialDate: initial,
    );
    if (picked != null) {
      setSheet(() {
        if (isFrom) {
          fromDate = picked;
          if (toDate != null && toDate!.isBefore(fromDate!)) toDate = fromDate;
        } else {
          toDate = picked;
        }
      });
    }
  }

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setSheet) {
          String dateText(DateTime? d) {
            if (d == null) return 'Select date';
            const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            return '${d.day} ${m[d.month - 1]} ${d.year}';
          }

          return Container(
            padding: EdgeInsets.fromLTRB(
              Responsive.w(ctx, 16),
              Responsive.h(ctx, 16),
              Responsive.w(ctx, 16),
              MediaQuery.of(ctx).padding.bottom + Responsive.h(ctx, 16),
            ),
            decoration: BoxDecoration(
              color: AppColor.base,
              borderRadius: BorderRadius.vertical(top: Radius.circular(Responsive.w(ctx, 20))),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: Responsive.w(ctx, 36),
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColor.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: Responsive.h(ctx, 16)),
                Text('Apply leave', style: AppTextStyle.titleLarge(ctx)),
                SizedBox(height: Responsive.h(ctx, 12)),
                DropdownButtonFormField<String>(
                  value: leaveType,
                  items: const ['Sick', 'Casual', 'Emergency', 'Other']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setSheet(() => leaveType = v ?? 'Sick'),
                  decoration: const InputDecoration(labelText: 'Leave type'),
                ),
                SizedBox(height: Responsive.h(ctx, 10)),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => pickDate(true, setSheet),
                        child: Text('From: ${dateText(fromDate)}', overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    SizedBox(width: Responsive.w(ctx, 8)),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => pickDate(false, setSheet),
                        child: Text('To: ${dateText(toDate)}', overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(ctx, 10)),
                TextField(
                  controller: reasonCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Reason',
                    hintText: 'Write reason for leave',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: Responsive.h(ctx, 14)),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final error = controller.validateLeave(
                        type: leaveType,
                        reason: reasonCtrl.text,
                        fromDate: fromDate,
                        toDate: toDate,
                      );
                      if (error != null) {
                        Get.snackbar('Leave', error);
                        return;
                      }
                      controller.applyLeave(
                        type: leaveType,
                        reason: reasonCtrl.text,
                        fromDate: fromDate!,
                        toDate: toDate!,
                      );
                      Navigator.of(ctx).pop();
                      Get.snackbar('Leave', 'Leave application submitted.');
                    },
                    child: const Text('Submit application'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

/// Wraps zoomable content: pinch to change level + smooth calendar-style animations.
class _AttendancePinchWrapper extends StatefulWidget {
  const _AttendancePinchWrapper({required this.controller});
  final StudentAttendanceController controller;

  @override
  State<_AttendancePinchWrapper> createState() => _AttendancePinchWrapperState();
}

class _AttendancePinchWrapperState extends State<_AttendancePinchWrapper> {
  double _scale = 1.0;
  bool _didPinch = false;

  void _onScaleStart(ScaleStartDetails details) {
    _scale = 1.0;
    _didPinch = details.pointerCount >= 2;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount >= 2) {
      _didPinch = true;
      setState(() => _scale = details.scale);
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (!_didPinch) return;
    if (_scale > 1.15) {
      widget.controller.zoomOut();
    } else if (_scale < 0.88) {
      widget.controller.zoomIn();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onScaleEnd: _onScaleEnd,
      behavior: HitTestBehavior.opaque,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: Responsive.h(context, 280)),
        child: Obx(() {
          final level = widget.controller.zoomLevel.value;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.94, end: 1.0).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                  ),
                  child: child,
                ),
              );
            },
            child: _viewForLevel(level),
          );
        }),
      ),
    );
  }

  Widget _viewForLevel(int level) {
    switch (level) {
      case 1:
        return _WeekCalendarView(key: const ValueKey<int>(1), controller: widget.controller);
      case 2:
        return _MonthCalendarView(key: const ValueKey<int>(2), controller: widget.controller);
      case 3:
        return _YearSummarySection(key: const ValueKey<int>(3), controller: widget.controller);
      default:
        return _TodayBoxView(key: const ValueKey<int>(0), controller: widget.controller);
    }
  }
}

/// Single prominent box: today's date and attendance status.
class _TodayBoxView extends StatelessWidget {
  const _TodayBoxView({super.key, required this.controller});
  final StudentAttendanceController controller;

  static const List<String> _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayName = _weekdays[now.weekday - 1];
    final monthYear = '${_months[now.month - 1]} ${now.year}';
    return Obx(() {
      final present = controller.todayPresent.value;
      final status = present ? 'Present' : 'Absent';
      final color = present ? AppColor.success : AppColor.error;
      final icon = present ? Icons.check_circle_rounded : Icons.cancel_rounded;
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColor.base,
          borderRadius: BorderRadius.circular(Responsive.w(context, 20)),
          boxShadow: [
            BoxShadow(
              color: AppColor.primary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: AppColor.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 12)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColor.primary,
                    AppColor.primary.withValues(alpha: 0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(Responsive.w(context, 20)),
                ),
              ),
              child: Text(
                'TODAY',
                style: TextStyle(
                  fontSize: Responsive.sp(context, 12),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: AppColor.base.withValues(alpha: 0.95),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 28)),
              child: Column(
                children: [
                  Text(
                    dayName.toUpperCase(),
                    style: TextStyle(
                      fontSize: Responsive.sp(context, 11),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.4,
                      color: AppColor.textMuted,
                    ),
                  ),
                  SizedBox(height: Responsive.h(context, 14)),
                  Container(
                    width: Responsive.w(context, 80),
                    height: Responsive.w(context, 80),
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      borderRadius: BorderRadius.circular(Responsive.w(context, 40)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primary.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: AppColor.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${now.day}',
                        style: TextStyle(
                          fontSize: Responsive.sp(context, 32),
                          fontWeight: FontWeight.w700,
                          color: AppColor.base,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.h(context, 10)),
                  Text(
                    monthYear,
                    style: AppTextStyle.bodyLarge(context).copyWith(
                      color: AppColor.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: Responsive.h(context, 24)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.w(context, 20),
                      vertical: Responsive.h(context, 12),
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(Responsive.w(context, 24)),
                      border: Border.all(
                        color: color.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, color: color, size: Responsive.w(context, 24)),
                        SizedBox(width: Responsive.w(context, 10)),
                        Text(
                          status,
                          style: AppTextStyle.titleMedium(context).copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// Week: 7-day calendar strip (Google Calendar week bar style).
class _WeekCalendarView extends StatelessWidget {
  const _WeekCalendarView({super.key, required this.controller});
  final StudentAttendanceController controller;

  static const List<String> _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final report = controller.weekReport.value;
      if (report == null) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PeriodNav(
            label: '${report.weekStart.day} – ${report.weekEnd.day} ${_monthName(report.weekStart.month)} ${report.weekStart.year}',
            onPrev: controller.previousWeek,
            onNext: controller.nextWeek,
          ),
          SizedBox(height: Responsive.h(context, 16)),
          Container(
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
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 10)),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColor.primary,
                        AppColor.primary.withValues(alpha: 0.88),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _dayNames.map((d) => Expanded(
                      child: Text(
                        d,
                        style: TextStyle(
                          fontSize: Responsive.sp(context, 11),
                          fontWeight: FontWeight.w700,
                          color: AppColor.base.withValues(alpha: 0.95),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )).toList(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: Responsive.h(context, 14),
                    horizontal: Responsive.w(context, 4),
                  ),
                  child: Row(
                    children: List.generate(7, (i) {
                      final r = report.dayRecords.length > i ? report.dayRecords[i] : null;
                      if (r == null) return const Expanded(child: SizedBox());
                      final isToday = _isSameDay(r.date, DateTime.now());
                      final isWeekend = r.date.weekday == 6 || r.date.weekday == 7;
                      final Color dotColor;
                      if (r.isHoliday) {
                        dotColor = AppColor.tokenYellowFont;
                      } else if (r.isPresent) {
                        dotColor = r.isLate ? AppColor.orange : AppColor.success;
                      } else {
                        dotColor = AppColor.error;
                      }
                      return Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _showDayReportSheet(context, r, controller),
                            borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 2),
                              padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 8)),
                              decoration: BoxDecoration(
                                color: isToday
                                    ? AppColor.primary.withValues(alpha: 0.12)
                                    : (isWeekend ? AppColor.border.withValues(alpha: 0.3) : null),
                                borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
                                border: isToday
                                    ? Border.all(
                                        color: AppColor.primary.withValues(alpha: 0.5),
                                        width: 1.5,
                                      )
                                    : null,
                                boxShadow: isToday
                                    ? [
                                        BoxShadow(
                                          color: AppColor.primary.withValues(alpha: 0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${r.date.day}',
                                    style: TextStyle(
                                      fontSize: Responsive.sp(context, 16),
                                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                                      color: isToday
                                          ? AppColor.primary
                                          : (isWeekend ? AppColor.textMuted : AppColor.textPrimary),
                                    ),
                                  ),
                                  SizedBox(height: Responsive.h(context, 6)),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: dotColor,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: dotColor.withValues(alpha: 0.4),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  static String _monthName(int m) {
    const names = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return names[m - 1];
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Month: full calendar grid (Google Calendar month style).
class _MonthCalendarView extends StatelessWidget {
  const _MonthCalendarView({super.key, required this.controller});
  final StudentAttendanceController controller;

  static const List<String> _weekHeaders = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final report = controller.monthReport.value;
      if (report == null) return const SizedBox.shrink();
      final year = report.year;
      final month = report.month;
      final first = DateTime(year, month, 1);
      final last = DateTime(year, month + 1, 0);
      final daysInMonth = last.day;
      final startWeekday = first.weekday % 7;
      final leadingEmpty = startWeekday;
      final totalCells = leadingEmpty + daysInMonth;
      final rows = (totalCells / 7).ceil();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PeriodNav(
            label: '${report.monthName} $year',
            onPrev: controller.previousMonth,
            onNext: controller.nextMonth,
          ),
          SizedBox(height: Responsive.h(context, 16)),
          Container(
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
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 12)),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColor.primary,
                        AppColor.primaryDark.withValues(alpha: 0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: _weekHeaders.map((h) => Expanded(
                      child: Text(
                        h.toUpperCase(),
                        style: TextStyle(
                          fontSize: Responsive.sp(context, 11),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppColor.base.withValues(alpha: 0.95),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )).toList(),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    final cellSize = w / 7;
                    final cellH = cellSize * 0.92;
                    return Column(
                      children: List.generate(rows, (row) {
                        return Row(
                          children: List.generate(7, (col) {
                            final index = row * 7 + col;
                            if (index < leadingEmpty) {
                              return SizedBox(
                                width: cellSize,
                                height: cellH,
                                child: ColoredBox(
                                  color: AppColor.border.withValues(alpha: 0.2),
                                ),
                              );
                            }
                            final day = index - leadingEmpty + 1;
                            if (day > daysInMonth) {
                              return SizedBox(
                                width: cellSize,
                                height: cellH,
                                child: ColoredBox(
                                  color: AppColor.border.withValues(alpha: 0.2),
                                ),
                              );
                            }
                            final d = DateTime(year, month, day);
                            final isToday = _isSameDay(d, DateTime.now());
                            final isWeekend = d.weekday == 6 || d.weekday == 7;
                            final dayRecord = controller.getDayRecordForDate(d);
                            return SizedBox(
                              width: cellSize,
                              height: cellH,
                              child: Material(
                                color: isWeekend
                                    ? AppColor.border.withValues(alpha: 0.25)
                                    : Colors.transparent,
                                child: InkWell(
                                  onTap: () => _showDayReportSheet(context, dayRecord, controller),
                                  child: Center(
                                    child: Container(
                                      width: cellSize * 0.65,
                                      height: cellSize * 0.65,
                                      decoration: isToday
                                          ? BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  AppColor.primary,
                                                  AppColor.primaryDark.withValues(alpha: 0.9),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColor.primary.withValues(alpha: 0.4),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            )
                                          : null,
                                      child: Center(
                                        child: Text(
                                          '$day',
                                          style: TextStyle(
                                            fontSize: Responsive.sp(context, 14),
                                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                                            color: isToday
                                                ? AppColor.base
                                                : (isWeekend ? AppColor.textMuted : AppColor.textPrimary),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _YearSummarySection extends StatelessWidget {
  const _YearSummarySection({super.key, required this.controller});
  final StudentAttendanceController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final report = controller.yearReport.value;
      if (report == null) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PeriodNav(
            label: '${report.year}',
            onPrev: controller.previousYear,
            onNext: controller.nextYear,
          ),
          SizedBox(height: Responsive.h(context, 16)),
          Container(
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
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: Responsive.h(context, 14),
                    horizontal: Responsive.w(context, 16),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColor.primary,
                        AppColor.primaryDark.withValues(alpha: 0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Text(
                    'Year summary',
                    style: TextStyle(
                      fontSize: Responsive.sp(context, 16),
                      fontWeight: FontWeight.w700,
                      color: AppColor.base.withValues(alpha: 0.98),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(Responsive.w(context, 16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _YearStatRow('Working days', '${report.totalWorkingDays}', AppColor.textPrimary),
                      SizedBox(height: Responsive.h(context, 8)),
                      _YearStatRow('Present', '${report.totalPresentDays}', AppColor.success),
                      SizedBox(height: Responsive.h(context, 8)),
                      _YearStatRow('Absent', '${report.totalAbsentDays}', AppColor.error),
                      SizedBox(height: Responsive.h(context, 8)),
                      _YearStatRow('Holidays', '${report.totalHolidays}', AppColor.tokenYellowFont),
                      SizedBox(height: Responsive.h(context, 8)),
                      _YearStatRow('Late entries', '${report.totalLateEntries}', AppColor.orange),
                      SizedBox(height: Responsive.h(context, 14)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: Responsive.h(context, 10),
                          horizontal: Responsive.w(context, 12),
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
                          border: Border.all(color: AppColor.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Attendance',
                              style: AppTextStyle.titleSmall(context),
                            ),
                            Text(
                              '${report.attendancePercent.toStringAsFixed(1)}%',
                              style: AppTextStyle.titleMedium(context).copyWith(
                                color: AppColor.primary,
                                fontWeight: FontWeight.w700,
                              ),
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
          SizedBox(height: Responsive.h(context, 20)),
          Padding(
            padding: EdgeInsets.only(bottom: Responsive.h(context, 8)),
            child: Text(
              'Tap a month to view',
              style: AppTextStyle.titleSmall(context).copyWith(color: AppColor.textSecondary),
            ),
          ),
          _YearMonthGrid(controller: controller, months: report.months),
        ],
      );
    });
  }
}

class _YearStatRow extends StatelessWidget {
  const _YearStatRow(this.label, this.value, this.valueColor);
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyle.bodyMedium(context).copyWith(color: AppColor.textSecondary)),
        Text(value, style: AppTextStyle.bodyMedium(context).copyWith(fontWeight: FontWeight.w600, color: valueColor)),
      ],
    );
  }
}

class _PeriodNav extends StatelessWidget {
  const _PeriodNav({
    required this.label,
    required this.onPrev,
    required this.onNext,
  });
  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left_rounded, size: Responsive.w(context, 28)),
          onPressed: onPrev,
          color: AppColor.primary,
        ),
        Text(label, style: AppTextStyle.titleMedium(context)),
        IconButton(
          icon: Icon(Icons.chevron_right_rounded, size: Responsive.w(context, 28)),
          onPressed: onNext,
          color: AppColor.primary,
        ),
      ],
    );
  }
}

class _YearMonthGrid extends StatelessWidget {
  const _YearMonthGrid({required this.controller, required this.months});
  final StudentAttendanceController controller;
  final List<MonthReport> months;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > Breakpoints.lg ? 4 : (constraints.maxWidth > Breakpoints.sm ? 3 : 2);
        final ratio = constraints.maxWidth > Breakpoints.lg
            ? 1.35
            : (constraints.maxWidth > Breakpoints.sm ? 1.22 : 1.05);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            childAspectRatio: ratio,
            crossAxisSpacing: Responsive.w(context, 12),
            mainAxisSpacing: Responsive.h(context, 12),
          ),
          itemCount: months.length,
          itemBuilder: (context, index) {
            final m = months[index];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.goToMonthView(m.year, m.month),
                borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColor.base,
                    borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.primary.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                      BoxShadow(
                        color: AppColor.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: Responsive.h(context, 10),
                          horizontal: Responsive.w(context, 10),
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColor.primary.withValues(alpha: 0.9),
                              AppColor.primaryDark.withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Text(
                          m.monthName,
                          style: TextStyle(
                            fontSize: Responsive.sp(context, 13),
                            fontWeight: FontWeight.w700,
                            color: AppColor.base.withValues(alpha: 0.98),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(Responsive.w(context, 10)),
                          child: LayoutBuilder(
                            builder: (context, box) {
                              final compact = box.maxHeight < 46;
                              final percentText = '${m.attendancePercent.toStringAsFixed(0)}%';

                              if (compact) {
                                // Compact mode prevents RenderFlex overflow on very short tiles.
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    percentText,
                                    style: AppTextStyle.titleSmall(context).copyWith(
                                      color: AppColor.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${m.presentDays} / ${m.workingDays} days',
                                    style: AppTextStyle.caption(context).copyWith(color: AppColor.textSecondary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: Responsive.h(context, 6)),
                                  Text(
                                    percentText,
                                    style: AppTextStyle.titleSmall(context).copyWith(
                                      color: AppColor.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
