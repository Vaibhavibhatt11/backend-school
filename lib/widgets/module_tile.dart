import 'package:flutter/material.dart';
import '../common/theme/app_color.dart';
import '../common/fonts/common_textstyle.dart';
import '../common/utils/responsive.dart';
import 'app_card.dart';

class ModuleTile extends StatelessWidget {
  const ModuleTile({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
    this.subtitle,
  });

  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final size = Responsive.w(context, 48);
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(context, 14),
        vertical: Responsive.h(context, 14),
      ),
      child: Row(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColor.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(Responsive.w(context, 10)),
            ),
            child: Icon(icon, color: AppColor.primary, size: Responsive.w(context, 24)),
          ),
          SizedBox(width: Responsive.w(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTextStyle.titleMedium(context)),
                if (subtitle != null) ...[
                  SizedBox(height: Responsive.h(context, 2)),
                  Text(
                    subtitle!,
                    style: AppTextStyle.caption(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.chevron_right_rounded,
              color: AppColor.textMuted,
              size: Responsive.w(context, 22),
            ),
        ],
      ),
    );
  }
}
