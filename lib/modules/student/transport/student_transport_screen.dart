import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/theme/app_color.dart';
import '../../../common/fonts/common_textstyle.dart';
import '../../../common/utils/responsive.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/section_header.dart';
import 'student_transport_controller.dart';

class StudentTransportScreen extends GetView<StudentTransportController> {
  const StudentTransportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Transport',
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.w(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: 'Live bus / auto tracking'),
            Obx(() => AppCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tracking', style: AppTextStyle.titleMedium(context)),
                      Icon(
                        controller.trackingLive.value ? Icons.location_on : Icons.location_off,
                        color: controller.trackingLive.value ? AppColor.success : AppColor.textMuted,
                        size: Responsive.w(context, 24),
                      ),
                    ],
                  ),
                )),
            SectionHeader(title: 'Bus route'),
            AppCard(child: Text('View route and stops.', style: AppTextStyle.bodySmall(context))),
            SectionHeader(title: 'Driver details'),
            AppCard(child: Text('Driver name and contact.', style: AppTextStyle.bodySmall(context))),
            SectionHeader(title: 'Pickup alerts'),
            AppCard(child: Text('Alerts when bus is near your stop.', style: AppTextStyle.bodySmall(context))),
            SizedBox(height: Responsive.h(context, 24)),
          ],
        ),
      ),
    );
  }
}
