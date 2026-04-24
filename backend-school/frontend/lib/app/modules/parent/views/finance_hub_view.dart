import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/fonts/common_textstyle.dart';
import '../../../../common/theme/app_color.dart';
import '../../../../common/utils/responsive.dart';
import '../../../../widgets/app_scaffold.dart';
import '../controllers/finance_hub_controller.dart';

class FinanceHubView extends GetView<FinanceHubController> {
  const FinanceHubView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Finance & Fees',
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(Responsive.w(context, 16)),
            child: _tabs(context),
          ),
          Expanded(
            child: Obx(() {
              switch (controller.selectedTab.value) {
                case 'payment':
                  return _list(controller.feePayments, 'invoice', 'amount', 'status');
                case 'history':
                  return _list(controller.paymentHistory, 'date', 'amount', 'mode');
                case 'receipts':
                  return _list(controller.receipts, 'receiptNo', 'invoice', null);
                case 'dues':
                  return _list(controller.pendingDues, 'title', 'amount', 'due');
                case 'scholarship':
                  return _list(controller.scholarship, 'scheme', 'amount', 'status');
                case 'notifications':
                  return _list(controller.paymentNotifications, 'title', 'message', null);
                default:
                  return _list(controller.feeStructure, 'head', 'amount', null);
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _tabs(BuildContext context) {
    const tabs = [
      ('structure', 'Fee Structure'),
      ('payment', 'Fee Payments'),
      ('history', 'Payment History'),
      ('receipts', 'Fee Receipts'),
      ('dues', 'Pending Dues'),
      ('scholarship', 'Scholarship'),
      ('notifications', 'Payment Alerts'),
    ];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => SizedBox(width: Responsive.w(context, 8)),
        itemBuilder: (_, i) => Obx(() {
          final active = controller.selectedTab.value == tabs[i].$1;
          return InkWell(
            onTap: () => controller.changeTab(tabs[i].$1),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 14), vertical: 8),
              decoration: BoxDecoration(
                color: active ? AppColor.primary : AppColor.cardBackground,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                tabs[i].$2,
                style: AppTextStyle.caption(context).copyWith(
                  color: active ? AppColor.base : AppColor.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _list(
    List<Map<String, String>> rows,
    String titleKey,
    String subtitleKey,
    String? trailingKey,
  ) {
    if (rows.isEmpty) return const Center(child: Text('No records found'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rows.length,
      itemBuilder: (_, i) {
        final r = rows[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColor.base,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.borderLight),
          ),
          child: ListTile(
            title: Text(r[titleKey] ?? '-'),
            subtitle: Text(r[subtitleKey] ?? '-'),
            trailing: trailingKey == null
                ? null
                : Text(
                    r[trailingKey] ?? '-',
                    style: const TextStyle(color: AppColor.primaryDark, fontWeight: FontWeight.w700),
                  ),
          ),
        );
      },
    );
  }
}
