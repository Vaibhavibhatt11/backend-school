import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../common/theme/app_color.dart';
import '../common/utils/responsive.dart';
import '../common/routes/common_routes_screens.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.showProfileIcon = true,
    this.onBack,
    this.onNotificationTap,
    this.onProfileTap,
  });

  final String title;
  final bool showBackButton;
  final bool showProfileIcon;
  final VoidCallback? onBack;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.base,
      elevation: 0,
      scrolledUnderElevation: 1,
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: Responsive.w(context, 20)),
              onPressed: onBack ?? () => Get.back(),
              color: AppColor.textPrimary,
            )
          : null,
      leadingWidth: showBackButton ? Responsive.clamp(context, 56, min: 48, max: 68) : 0,
      title: Text(
        title,
        style: TextStyle(
          fontSize: Responsive.sp(context, 18),
          fontWeight: FontWeight.w600,
          color: AppColor.textPrimary,
        ),
      ),
      titleSpacing: showBackButton ? 0 : Responsive.clamp(context, 20, min: 12, max: 30),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_outlined, size: Responsive.w(context, 24)),
          onPressed: onNotificationTap ?? () {},
          color: AppColor.textPrimary,
        ),
        if (showProfileIcon)
          IconButton(
            icon: Icon(Icons.person_outline_rounded, size: Responsive.w(context, 24)),
            onPressed: onProfileTap ?? () => Get.toNamed(CommonScreenRoutes.studentProfile),
            color: AppColor.textPrimary,
          ),
      ],
    );
  }
}
