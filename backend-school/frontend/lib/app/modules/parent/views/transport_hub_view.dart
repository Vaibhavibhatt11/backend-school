import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/fonts/common_textstyle.dart';
import '../../../../common/theme/app_color.dart';
import '../../../../common/utils/responsive.dart';
import '../../../../widgets/app_scaffold.dart';
import '../controllers/transport_hub_controller.dart';

class TransportHubView extends GetView<TransportHubController> {
  const TransportHubView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Transport Center',
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(Responsive.w(context, 16)),
            child: Column(
              children: [
                _header(context),
                SizedBox(height: Responsive.h(context, 10)),
                _tabs(context),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              switch (controller.selectedTab.value) {
                case 'route':
                  return _routeTab(context);
                case 'driver':
                  return _driverTab(context);
                case 'pickup':
                  return _pickupTab(context);
                default:
                  return _trackingTab(context);
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(context, 14)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.primary, AppColor.primaryDark.withValues(alpha: 0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Live bus/auto tracking, route, driver details and pickup alerts.',
        style: AppTextStyle.bodySmall(context).copyWith(
          color: AppColor.base,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _tabs(BuildContext context) {
    const tabs = [
      ('tracking', 'Live Tracking'),
      ('route', 'Bus Route'),
      ('driver', 'Driver Details'),
      ('pickup', 'Pickup Alerts'),
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

  Widget _trackingTab(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(Responsive.w(context, 16)),
      children: [
        Container(
          padding: EdgeInsets.all(Responsive.w(context, 14)),
          decoration: BoxDecoration(
            color: AppColor.base,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Live bus/auto tracking', style: AppTextStyle.titleMedium(context).copyWith(fontWeight: FontWeight.w700)),
              SizedBox(height: Responsive.h(context, 12)),
              Obx(() => LinearProgressIndicator(
                    value: controller.busPosition.value,
                    minHeight: 10,
                    backgroundColor: AppColor.border,
                    color: AppColor.primary,
                  )),
              SizedBox(height: Responsive.h(context, 8)),
              Obx(() => Text(
                    'Current ETA: ${controller.nextPickupEta.value}',
                    style: AppTextStyle.bodySmall(context),
                  )),
              SizedBox(height: Responsive.h(context, 10)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: controller.updateTracking,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Refresh Live Location'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _routeTab(BuildContext context) {
    return Obx(
      () => ListView(
        padding: EdgeInsets.all(Responsive.w(context, 16)),
        children: controller.routeStops
            .asMap()
            .entries
            .map((e) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColor.primary.withValues(alpha: 0.12),
                    child: Text('${e.key + 1}', style: const TextStyle(color: AppColor.primaryDark)),
                  ),
                  title: Text(e.value),
                ))
            .toList(),
      ),
    );
  }

  Widget _driverTab(BuildContext context) {
    return Obx(
      () => ListView(
        padding: EdgeInsets.all(Responsive.w(context, 16)),
        children: [
          _item(context, 'Driver Name', controller.driver['name'] ?? '-'),
          _item(context, 'Contact', controller.driver['contact'] ?? '-'),
          _item(context, 'Vehicle Number', controller.driver['vehicle'] ?? '-'),
          _item(context, 'Attendant', controller.driver['assistant'] ?? '-'),
        ],
      ),
    );
  }

  Widget _pickupTab(BuildContext context) {
    return Obx(
      () => ListView(
        padding: EdgeInsets.all(Responsive.w(context, 16)),
        children: [
          SwitchListTile(
            value: controller.pickupAlertEnabled.value,
            onChanged: controller.togglePickupAlert,
            title: const Text('Enable Pickup Alerts'),
            subtitle: const Text('Get notifications before pickup/drop'),
          ),
          _item(context, 'Morning Pickup', '07:40 AM'),
          _item(context, 'Afternoon Drop', '02:35 PM'),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.h(context, 10)),
      padding: EdgeInsets.all(Responsive.w(context, 12)),
      decoration: BoxDecoration(
        color: AppColor.base,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.borderLight),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyle.bodySmall(context).copyWith(color: AppColor.textSecondary))),
          Text(value, style: AppTextStyle.bodyMedium(context).copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
