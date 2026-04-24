import 'package:flutter/material.dart';
import '../../../common/theme/app_color.dart';
import '../../../common/fonts/common_textstyle.dart';
import '../../../common/utils/responsive.dart';
import '../../../widgets/app_card.dart';

/// Reusable action tile for student module screens.
class StudentModuleAction extends StatelessWidget {
  const StudentModuleAction({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.h(context, 8)),
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: AppColor.primary, size: Responsive.w(context, 22)),
            SizedBox(width: Responsive.w(context, 12)),
            Expanded(child: Text(title, style: AppTextStyle.titleMedium(context))),
            Icon(Icons.arrow_forward_ios_rounded, size: Responsive.w(context, 14), color: AppColor.textMuted),
          ],
        ),
      ),
    );
  }
}
