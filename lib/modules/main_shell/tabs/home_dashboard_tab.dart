import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/theme/app_color.dart';
import '../../../common/fonts/common_textstyle.dart';
import '../../../common/utils/responsive.dart';
import '../../../common/routes/common_routes_screens.dart';

class HomeDashboardTab extends StatelessWidget {
  const HomeDashboardTab({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.authBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _HeaderSection(greeting: _greeting()),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: Responsive.h(context, 16)),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 16)),
                child: _StatsGrid(),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: Responsive.h(context, 20)),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 16)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Quick actions', style: AppTextStyle.titleLarge(context)),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: Responsive.h(context, 12)),
            ),
            SliverToBoxAdapter(
              child: _QuickActions(
                onAttendance: () => Get.toNamed(CommonScreenRoutes.studentAttendance),
                onHomework: () => Get.toNamed(CommonScreenRoutes.studentHomework),
                onTimetable: () => Get.toNamed(CommonScreenRoutes.studentTimetable),
                onFees: () => Get.toNamed(CommonScreenRoutes.studentFees),
                onMessages: () => Get.toNamed(CommonScreenRoutes.studentCommunication),
                onIdCard: null, // ID card option commented for now
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: Responsive.h(context, 24)),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 16)),
                child: Text('Today', style: AppTextStyle.titleLarge(context)),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: Responsive.h(context, 10)),
            ),
            SliverToBoxAdapter(
              child: _TodayCard(),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: Responsive.h(context, 24)),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 16)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent activity', style: AppTextStyle.titleLarge(context)),
                    TextButton(
                      onPressed: () => Get.toNamed(CommonScreenRoutes.studentCommunication),
                      child: Text('See all', style: TextStyle(color: AppColor.primary, fontSize: Responsive.sp(context, 13))),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: Responsive.h(context, 8)),
            ),
            SliverToBoxAdapter(
              child: _RecentActivityList(),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: Responsive.h(context, 100)),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.greeting});

  final String greeting;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        Responsive.w(context, 20),
        Responsive.h(context, 14),
        Responsive.w(context, 20),
        Responsive.h(context, 18),
      ),
      decoration: BoxDecoration(
        color: AppColor.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(Responsive.w(context, 24)),
          bottomRight: Radius.circular(Responsive.w(context, 24)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: TextStyle(
                      fontSize: Responsive.sp(context, 14),
                      color: AppColor.base.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: Responsive.h(context, 4)),
                  Text(
                    'Alex Johnson',
                    style: TextStyle(
                      fontSize: Responsive.sp(context, 20),
                      fontWeight: FontWeight.w700,
                      color: AppColor.base,
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                radius: Responsive.w(context, 26),
                backgroundColor: AppColor.base.withValues(alpha: 0.25),
                child: Text(
                  'AJ',
                  style: TextStyle(
                    color: AppColor.base,
                    fontWeight: FontWeight.w600,
                    fontSize: Responsive.sp(context, 16),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(context, 8)),
          Text(
            'Class 10-A • Roll No. 24',
            style: TextStyle(
              fontSize: Responsive.sp(context, 13),
              color: AppColor.base.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Attendance',
            value: '94%',
            subtitle: 'This month',
            color: AppColor.tokenGreen,
            valueColor: AppColor.tokenGreenFont,
            icon: Icons.check_circle_outline_rounded,
          ),
        ),
        SizedBox(width: Responsive.w(context, 12)),
        Expanded(
          child: _StatCard(
            title: 'Pending',
            value: '3',
            subtitle: 'Homework',
            color: AppColor.tokenYellow,
            valueColor: AppColor.tokenYellowFont,
            icon: Icons.assignment_outlined,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.valueColor,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final Color valueColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(context, 14),
        vertical: Responsive.h(context, 14),
      ),
      decoration: BoxDecoration(
        color: AppColor.base,
        borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: Responsive.w(context, 20), color: valueColor),
              SizedBox(width: Responsive.w(context, 6)),
              Text(
                title,
                style: AppTextStyle.label(context).copyWith(color: AppColor.textSecondary),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(context, 8)),
          Text(
            value,
            style: AppTextStyle.headlineMedium(context).copyWith(color: valueColor),
          ),
          SizedBox(height: Responsive.h(context, 2)),
          Text(
            subtitle,
            style: AppTextStyle.caption(context),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onAttendance,
    required this.onHomework,
    required this.onTimetable,
    required this.onFees,
    required this.onMessages,
    this.onIdCard,
  });

  final VoidCallback onAttendance;
  final VoidCallback onHomework;
  final VoidCallback onTimetable;
  final VoidCallback onFees;
  final VoidCallback onMessages;
  final VoidCallback? onIdCard;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 16)),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _ActionChip(label: 'Attendance', icon: Icons.fact_check_rounded, onTap: onAttendance)),
              SizedBox(width: Responsive.w(context, 10)),
              Expanded(child: _ActionChip(label: 'Homework', icon: Icons.assignment_rounded, onTap: onHomework)),
              SizedBox(width: Responsive.w(context, 10)),
              Expanded(child: _ActionChip(label: 'Timetable', icon: Icons.calendar_month_rounded, onTap: onTimetable)),
            ],
          ),
          SizedBox(height: Responsive.h(context, 10)),
          Row(
            children: [
              Expanded(child: _ActionChip(label: 'Fees', icon: Icons.payments_rounded, onTap: onFees)),
              SizedBox(width: Responsive.w(context, 10)),
              Expanded(child: _ActionChip(label: 'Messages', icon: Icons.chat_rounded, onTap: onMessages)),
              if (onIdCard != null) ...[
                SizedBox(width: Responsive.w(context, 10)),
                Expanded(child: _ActionChip(label: 'ID Card', icon: Icons.badge_rounded, onTap: onIdCard!)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 14)),
          decoration: BoxDecoration(
            color: AppColor.base,
            borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
            boxShadow: [
              BoxShadow(
                color: AppColor.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColor.primary, size: Responsive.w(context, 28)),
              SizedBox(height: Responsive.h(context, 6)),
              Text(
                label,
                style: AppTextStyle.caption(context).copyWith(
                  color: AppColor.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 16)),
      child: Container(
        padding: EdgeInsets.all(Responsive.w(context, 16)),
        decoration: BoxDecoration(
          color: AppColor.base,
          borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
          boxShadow: [
            BoxShadow(
              color: AppColor.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: Responsive.w(context, 48),
              height: Responsive.w(context, 48),
              decoration: BoxDecoration(
                color: AppColor.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
              ),
              child: Icon(Icons.schedule_rounded, color: AppColor.primary, size: Responsive.w(context, 26)),
            ),
            SizedBox(width: Responsive.w(context, 14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Next: Mathematics', style: AppTextStyle.titleMedium(context)),
                  SizedBox(height: Responsive.h(context, 2)),
                  Text('10:00 AM • Room 204', style: AppTextStyle.caption(context)),
                ],
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed(CommonScreenRoutes.studentTimetable),
              child: Text('View', style: TextStyle(color: AppColor.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentActivityList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      {'title': 'New homework: Math Ch 5', 'time': '2h ago', 'icon': Icons.assignment_rounded},
      {'title': 'Attendance marked for today', 'time': '5h ago', 'icon': Icons.check_circle_rounded},
      {'title': 'Fee reminder: Due Mar 25', 'time': '1d ago', 'icon': Icons.payments_rounded},
    ];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 16)),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            Container(
              margin: EdgeInsets.only(bottom: Responsive.h(context, 10)),
              padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 14), vertical: Responsive.h(context, 12)),
              decoration: BoxDecoration(
                color: AppColor.base,
                borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    items[i]['icon'] as IconData,
                    size: Responsive.w(context, 22),
                    color: AppColor.primary,
                  ),
                  SizedBox(width: Responsive.w(context, 12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(items[i]['title'] as String, style: AppTextStyle.bodyMedium(context)),
                        SizedBox(height: Responsive.h(context, 2)),
                        Text(items[i]['time'] as String, style: AppTextStyle.caption(context)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
