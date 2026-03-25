import 'package:flutter/material.dart';
import '../common/fonts/common_textstyle.dart';
import '../common/utils/responsive.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.padding,
  });

  final String title;
  final Widget? trailing;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.only(
        left: Responsive.w(context, 4),
        right: Responsive.w(context, 4),
        top: Responsive.h(context, 8),
        bottom: Responsive.h(context, 6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyle.titleLarge(context)),
          trailing ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}
