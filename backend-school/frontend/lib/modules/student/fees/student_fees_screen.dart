import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/theme/app_color.dart';
import '../../../common/fonts/common_textstyle.dart';
import '../../../common/utils/responsive.dart';
import '../../../widgets/app_scaffold.dart';
import 'models/fee_models.dart';
import 'student_fees_controller.dart';

class StudentFeesScreen extends GetView<StudentFeesController> {
  const StudentFeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Fees',
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.w(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            SizedBox(height: Responsive.h(context, 24)),
            _buildPendingSummary(context),
            SizedBox(height: Responsive.h(context, 24)),
            _buildSectionTitle(context, 'Upcoming fees', 'Pay before due date'),
            SizedBox(height: Responsive.h(context, 12)),
            _buildUpcomingList(context),
            SizedBox(height: Responsive.h(context, 24)),
            _buildSectionTitle(context, 'Paid fees', 'Download receipts'),
            SizedBox(height: Responsive.h(context, 12)),
            _buildPaidList(context),
            SizedBox(height: Responsive.h(context, 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
              Icons.payments_rounded,
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
                  'Fee management',
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 18),
                    fontWeight: FontWeight.w700,
                    color: AppColor.base,
                  ),
                ),
                SizedBox(height: Responsive.h(context, 4)),
                Text(
                  'Pay dues & download receipts',
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 13),
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

  Widget _buildPendingSummary(BuildContext context) {
    return Obx(() {
      final pending = controller.pendingDues.value;
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(context, 18),
          vertical: Responsive.h(context, 16),
        ),
        decoration: BoxDecoration(
          color: pending > 0
              ? AppColor.tokenRed.withValues(alpha: 0.4)
              : AppColor.tokenGreen.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
          border: Border.all(
            color: pending > 0
                ? AppColor.error.withValues(alpha: 0.3)
                : AppColor.success.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  pending > 0 ? Icons.schedule_rounded : Icons.check_circle_rounded,
                  color: pending > 0 ? AppColor.error : AppColor.success,
                  size: Responsive.w(context, 26),
                ),
                SizedBox(width: Responsive.w(context, 12)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pending > 0 ? 'Total pending' : 'All clear',
                      style: AppTextStyle.titleSmall(context).copyWith(
                        color: AppColor.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (pending > 0)
                      Text(
                        '${controller.upcomingFees.length} dues',
                        style: AppTextStyle.caption(context),
                      ),
                  ],
                ),
              ],
            ),
            if (pending > 0)
              Text(
                '₹${pending.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: Responsive.sp(context, 20),
                  fontWeight: FontWeight.w700,
                  color: AppColor.error,
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    return Row(
      children: [
        Container(
          width: 4,
          height: Responsive.h(context, 24),
          decoration: BoxDecoration(
            color: AppColor.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: Responsive.w(context, 12)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyle.titleLarge(context).copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: Responsive.h(context, 2)),
            Text(
              subtitle,
              style: AppTextStyle.caption(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUpcomingList(BuildContext context) {
    return Obx(() {
      final list = controller.upcomingFees;
      if (list.isEmpty) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 24)),
          alignment: Alignment.center,
          child: Text(
            'No upcoming fees',
            style: AppTextStyle.bodyMedium(context).copyWith(
              color: AppColor.textMuted,
            ),
          ),
        );
      }
      return Column(
        children: list.map((fee) => _UpcomingFeeCard(
          fee: fee,
          onPay: () => controller.payFee(fee.id),
        )).toList(),
      );
    });
  }

  Widget _buildPaidList(BuildContext context) {
    return Obx(() {
      final list = controller.paidFees;
      if (list.isEmpty) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 24)),
          alignment: Alignment.center,
          child: Text(
            'No payment history yet',
            style: AppTextStyle.bodyMedium(context).copyWith(
              color: AppColor.textMuted,
            ),
          ),
        );
      }
      return Column(
        children: list.map((fee) => _PaidFeeCard(
          fee: fee,
          onDownload: () => controller.downloadReceipt(fee.id),
        )).toList(),
      );
    });
  }
}

class _UpcomingFeeCard extends StatelessWidget {
  const _UpcomingFeeCard({required this.fee, required this.onPay});
  final UpcomingFee fee;
  final VoidCallback onPay;

  static String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDueSoon = fee.dueDate.difference(DateTime.now()).inDays <= 7;
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.h(context, 12)),
      decoration: BoxDecoration(
        color: AppColor.base,
        borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
        border: Border.all(
          color: isDueSoon
              ? AppColor.orange.withValues(alpha: 0.4)
              : AppColor.border.withValues(alpha: 0.8),
          width: 1.5,
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
          onTap: onPay,
          borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
          child: Padding(
            padding: EdgeInsets.all(Responsive.w(context, 16)),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(Responsive.w(context, 10)),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: AppColor.primary,
                    size: Responsive.w(context, 24),
                  ),
                ),
                SizedBox(width: Responsive.w(context, 14)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fee.title,
                        style: AppTextStyle.titleMedium(context),
                      ),
                      SizedBox(height: Responsive.h(context, 4)),
                      Text(
                        'Due ${_formatDate(fee.dueDate)}',
                        style: AppTextStyle.caption(context).copyWith(
                          color: isDueSoon ? AppColor.orange : null,
                          fontWeight: isDueSoon ? FontWeight.w600 : null,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${fee.amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 16),
                    fontWeight: FontWeight.w700,
                    color: AppColor.primaryDark,
                  ),
                ),
                SizedBox(width: Responsive.w(context, 12)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(context, 14),
                    vertical: Responsive.h(context, 10),
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
                    borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.primary.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Pay',
                    style: TextStyle(
                      fontSize: Responsive.sp(context, 13),
                      fontWeight: FontWeight.w700,
                      color: AppColor.base,
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
}

class _PaidFeeCard extends StatelessWidget {
  const _PaidFeeCard({required this.fee, required this.onDownload});
  final PaidFee fee;
  final VoidCallback onDownload;

  static String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.h(context, 12)),
      decoration: BoxDecoration(
        color: AppColor.base,
        borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
        border: Border.all(color: AppColor.border.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(Responsive.w(context, 16)),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(Responsive.w(context, 10)),
              decoration: BoxDecoration(
                color: AppColor.tokenGreen.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: AppColor.success,
                size: Responsive.w(context, 24),
              ),
            ),
            SizedBox(width: Responsive.w(context, 14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fee.title,
                    style: AppTextStyle.titleMedium(context),
                  ),
                  SizedBox(height: Responsive.h(context, 4)),
                  Text(
                    'Paid ${_formatDate(fee.paidDate)}',
                    style: AppTextStyle.caption(context),
                  ),
                  if (fee.receiptId != null) ...[
                    SizedBox(height: Responsive.h(context, 4)),
                    Text(
                      'Receipt: ${fee.receiptId}',
                      style: AppTextStyle.caption(context).copyWith(
                        color: AppColor.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              '₹${fee.amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: Responsive.sp(context, 15),
                fontWeight: FontWeight.w700,
                color: AppColor.success,
              ),
            ),
            SizedBox(width: Responsive.w(context, 12)),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onDownload,
                borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
                child: Container(
                  padding: EdgeInsets.all(Responsive.w(context, 10)),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
                    border: Border.all(color: AppColor.primary.withValues(alpha: 0.3)),
                  ),
                  child: Icon(
                    Icons.download_rounded,
                    color: AppColor.primary,
                    size: Responsive.w(context, 22),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
