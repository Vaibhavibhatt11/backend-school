import 'package:flutter/material.dart';
import '../common/theme/app_color.dart';
import '../common/utils/responsive.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.elevation = 0,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final double? borderRadius;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding ?? EdgeInsets.all(Responsive.w(context, 14)),
      decoration: BoxDecoration(
        color: color ?? AppColor.cardBackground,
        borderRadius: BorderRadius.circular(borderRadius ?? Responsive.w(context, 12)),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: AppColor.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: child,
    );
    if (onTap != null) {
      return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius ?? Responsive.w(context, 12)),
            child: content,
          ),
        ),
      );
    }
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: content,
    );
  }
}
