import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/theme/app_color.dart';
import '../../../common/fonts/common_textstyle.dart';
import '../../../common/utils/responsive.dart';
import '../../../widgets/app_scaffold.dart';
import 'student_health_controller.dart';

class StudentHealthScreen extends GetView<StudentHealthController> {
  const StudentHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Health',
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.w(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerCard(context),
            SizedBox(height: Responsive.h(context, 16)),
            _healthSummary(context),
            SizedBox(height: Responsive.h(context, 16)),
            _medicalInfo(context),
            SizedBox(height: Responsive.h(context, 16)),
            _recordsSection(context),
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
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(Responsive.w(context, 10)),
            decoration: BoxDecoration(
              color: AppColor.base.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
            ),
            child: Icon(Icons.health_and_safety_rounded, color: AppColor.base, size: Responsive.w(context, 24)),
          ),
          SizedBox(width: Responsive.w(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student health profile',
                  style: AppTextStyle.titleLarge(context).copyWith(
                    color: AppColor.base,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: Responsive.h(context, 4)),
                Text(
                  'Medical records, vitals and emergency details',
                  style: AppTextStyle.bodySmall(context).copyWith(
                    color: AppColor.base.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _healthSummary(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(context, 14)),
      decoration: BoxDecoration(
        color: AppColor.base,
        borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
        border: Border.all(color: AppColor.border.withValues(alpha: 0.8)),
      ),
      child: Obx(() => Wrap(
            spacing: Responsive.w(context, 10),
            runSpacing: Responsive.h(context, 10),
            children: [
              _pill(context, 'Blood Group', controller.bloodGroup.value, AppColor.primary),
              _pill(context, 'Allergy', controller.allergy.value, AppColor.orange),
              _pill(context, 'Condition', controller.chronicCondition.value, AppColor.info),
            ],
          )),
    );
  }

  Widget _pill(BuildContext context, String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(context, 10),
        vertical: Responsive.h(context, 8),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: RichText(
        text: TextSpan(
          style: AppTextStyle.bodySmall(context),
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
            TextSpan(
              text: value,
              style: TextStyle(color: AppColor.textPrimary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _medicalInfo(BuildContext context) {
    return Obx(() => Container(
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
              Text(
                'Emergency information',
                style: AppTextStyle.titleSmall(context).copyWith(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: Responsive.h(context, 10)),
              _row(context, Icons.call_rounded, 'Emergency Contact', controller.emergencyContact.value),
              SizedBox(height: Responsive.h(context, 8)),
              _row(context, Icons.local_hospital_rounded, 'Preferred Hospital', controller.preferredHospital.value),
            ],
          ),
        ));
  }

  Widget _row(BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: Responsive.w(context, 18), color: AppColor.primary),
        SizedBox(width: Responsive.w(context, 8)),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: AppTextStyle.bodySmall(context),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(color: AppColor.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _recordsSection(BuildContext context) {
    return Obx(() {
      final records = controller.records;
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(Responsive.w(context, 14)),
        decoration: BoxDecoration(
          color: AppColor.base,
          borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
          border: Border.all(color: AppColor.border.withValues(alpha: 0.8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Medical records',
              style: AppTextStyle.titleSmall(context).copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: Responsive.h(context, 10)),
            ...records.map((r) => _recordTile(context, r)),
          ],
        ),
      );
    });
  }

  Widget _recordTile(BuildContext context, Map<String, String> record) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.h(context, 8)),
      decoration: BoxDecoration(
        color: AppColor.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.border.withValues(alpha: 0.7)),
      ),
      child: ListTile(
        onTap: () => _showRecordDetails(context, record),
        contentPadding: EdgeInsets.symmetric(
          horizontal: Responsive.w(context, 12),
          vertical: Responsive.h(context, 4),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColor.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.assignment_rounded, color: AppColor.primary),
        ),
        title: Text(
          record['title'] ?? '',
          style: AppTextStyle.bodyMedium(context).copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          record['date'] ?? '',
          style: AppTextStyle.caption(context),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: AppColor.textMuted),
      ),
    );
  }

  void _showRecordDetails(BuildContext context, Map<String, String> record) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.78),
        decoration: BoxDecoration(
          color: AppColor.base,
          borderRadius: BorderRadius.vertical(top: Radius.circular(Responsive.w(ctx, 22))),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            Responsive.w(ctx, 16),
            Responsive.h(ctx, 14),
            Responsive.w(ctx, 16),
            MediaQuery.of(ctx).padding.bottom + Responsive.h(ctx, 16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: Responsive.w(ctx, 38),
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColor.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: Responsive.h(ctx, 14)),
              Text(
                record['title'] ?? '',
                style: AppTextStyle.titleLarge(ctx).copyWith(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: Responsive.h(ctx, 8)),
              _detail(ctx, 'Date', record['date'] ?? ''),
              SizedBox(height: Responsive.h(ctx, 8)),
              _detail(ctx, 'Doctor/Team', record['doctor'] ?? ''),
              SizedBox(height: Responsive.h(ctx, 8)),
              _detail(ctx, 'Vitals', record['vitals'] ?? ''),
              SizedBox(height: Responsive.h(ctx, 12)),
              Text(
                'Summary',
                style: AppTextStyle.titleSmall(ctx).copyWith(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: Responsive.h(ctx, 6)),
              Text(
                record['summary'] ?? '',
                style: AppTextStyle.bodyMedium(ctx).copyWith(height: 1.45),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detail(BuildContext context, String label, String value) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(context, 10)),
      decoration: BoxDecoration(
        color: AppColor.cardBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text.rich(
        TextSpan(
          style: AppTextStyle.bodySmall(context),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
