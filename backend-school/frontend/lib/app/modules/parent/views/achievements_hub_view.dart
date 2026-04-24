import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/fonts/common_textstyle.dart';
import '../../../../common/theme/app_color.dart';
import '../../../../common/utils/responsive.dart';
import '../../../../widgets/app_scaffold.dart';
import '../controllers/achievements_hub_controller.dart';

class AchievementsHubView extends GetView<AchievementsHubController> {
  const AchievementsHubView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Achievements',
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(Responsive.w(context, 16)),
            child: _tabs(context),
          ),
          Expanded(
            child: Obx(() {
              switch (controller.selectedTab.value) {
                case 'competition':
                  return _simpleList(controller.competitionCertificates, 'file');
                case 'activity':
                  return _simpleList(controller.activityRecords, 'remarks');
                case 'digital':
                  return _simpleList(controller.digitalCertificates, 'id');
                default:
                  return _simpleList(controller.academicAchievements, 'by');
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _tabs(BuildContext context) {
    const tabs = [
      ('academic', 'Academic'),
      ('competition', 'Competition Certificates'),
      ('activity', 'Activity Records'),
      ('digital', 'Digital Certificates'),
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

  Widget _simpleList(List<Map<String, String>> items, String trailingKey) {
    if (items.isEmpty) {
      return const Center(child: Text('No records found'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColor.base,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.borderLight),
          ),
          child: ListTile(
            title: Text(item['title'] ?? '-'),
            subtitle: Text(item['date'] ?? item['issuedBy'] ?? '-'),
            trailing: Text(
              item[trailingKey] ?? '-',
              style: const TextStyle(color: AppColor.primaryDark, fontWeight: FontWeight.w700),
            ),
          ),
        );
      },
    );
  }
}
