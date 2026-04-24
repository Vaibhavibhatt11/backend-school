import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/theme/app_color.dart';
import '../../../common/fonts/common_textstyle.dart';
import '../../../common/utils/responsive.dart';
import '../../../common/routes/common_routes_screens.dart';
import '../../../widgets/module_tile.dart';

class MoreTab extends StatelessWidget {
  const MoreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.authBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  Responsive.w(context, 20),
                  Responsive.h(context, 20),
                  Responsive.w(context, 20),
                  Responsive.h(context, 8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('More', style: AppTextStyle.headlineLarge(context)),
                    SizedBox(height: Responsive.h(context, 4)),
                    Text(
                      'Profile, fees, events & settings',
                      style: AppTextStyle.bodySmall(context),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 16)),
                child: Column(
                  children: [
                    ModuleTile(
                      title: 'Profile',
                      subtitle: 'Personal & academic details',
                      icon: Icons.person_rounded,
                      onTap: () => Get.toNamed(CommonScreenRoutes.studentProfile),
                    ),
                    SizedBox(height: Responsive.h(context, 10)),
                    ModuleTile(
                      title: 'Attendance',
                      subtitle: 'Daily & monthly records',
                      icon: Icons.fact_check_rounded,
                      onTap: () => Get.toNamed(CommonScreenRoutes.studentAttendance),
                    ),
                    SizedBox(height: Responsive.h(context, 10)),
                    ModuleTile(
                      title: 'Fees',
                      subtitle: 'Payments & receipts',
                      icon: Icons.payments_rounded,
                      onTap: () => Get.toNamed(CommonScreenRoutes.studentFees),
                    ),
                    SizedBox(height: Responsive.h(context, 10)),
                    ModuleTile(
                      title: 'Events',
                      subtitle: 'Competitions & activities',
                      icon: Icons.event_rounded,
                      onTap: () => Get.toNamed(CommonScreenRoutes.studentEvents),
                    ),
                    SizedBox(height: Responsive.h(context, 10)),
                    ModuleTile(
                      title: 'Health',
                      subtitle: 'Medical information',
                      icon: Icons.health_and_safety_rounded,
                      onTap: () => Get.toNamed(CommonScreenRoutes.studentHealth),
                    ),
                    SizedBox(height: Responsive.h(context, 10)),
                    // Transport module commented for now
                    // ModuleTile(
                    //   title: 'Transport',
                    //   subtitle: 'Bus tracking & routes',
                    //   icon: Icons.directions_bus_rounded,
                    //   onTap: () => Get.toNamed(CommonScreenRoutes.studentTransport),
                    // ),
                    // SizedBox(height: Responsive.h(context, 10)),
                    // Library module commented for now
                    // ModuleTile(
                    //   title: 'Library',
                    //   subtitle: 'Books & resources',
                    //   icon: Icons.local_library_rounded,
                    //   onTap: () => Get.toNamed(CommonScreenRoutes.studentLibrary),
                    // ),
                    // SizedBox(height: Responsive.h(context, 10)),
                    // Achievements module commented for now
                    // ModuleTile(
                    //   title: 'Achievements',
                    //   subtitle: 'Certificates & records',
                    //   icon: Icons.emoji_events_rounded,
                    //   onTap: () => Get.toNamed(CommonScreenRoutes.studentAchievements),
                    // ),
                    // SizedBox(height: Responsive.h(context, 10)),
                    ModuleTile(
                      title: 'Settings',
                      subtitle: 'Account & preferences',
                      icon: Icons.settings_rounded,
                      onTap: () => Get.toNamed(CommonScreenRoutes.studentSettings),
                    ),
                    SizedBox(height: Responsive.h(context, 24)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
