import 'package:flutter/material.dart';
import '../common/theme/app_color.dart';
import '../common/utils/responsive.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.primary = true,
    this.loading = false,
    this.minHeight,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool primary;
  final bool loading;
  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    final height = minHeight ?? Responsive.h(context, 44);
    final style = primary
        ? FilledButton.styleFrom(
            backgroundColor: AppColor.primary,
            foregroundColor: AppColor.base,
            minimumSize: Size(double.infinity, height),
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 20)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Responsive.w(context, 10)),
            ),
          )
        : OutlinedButton.styleFrom(
            foregroundColor: AppColor.primary,
            side: const BorderSide(color: AppColor.primary),
            minimumSize: Size(double.infinity, height),
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 20)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Responsive.w(context, 10)),
            ),
          );
    if (loading) {
      return SizedBox(
        height: height,
        child: Center(
          child: SizedBox(
            width: Responsive.w(context, 24),
            height: Responsive.w(context, 24),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: primary ? AppColor.base : AppColor.primary,
            ),
          ),
        ),
      );
    }
    if (icon != null) {
      if (primary) {
        return FilledButton.icon(
          onPressed: onPressed,
          icon: icon!,
          label: Text(label),
          style: style,
        );
      }
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon!,
        label: Text(label),
        style: style,
      );
    }
    if (primary) {
      return FilledButton(
        onPressed: onPressed,
      style: style,
      child: Text(label),
      );
    }
    return OutlinedButton(
      onPressed: onPressed,
      style: style,
      child: Text(label),
    );
  }
}
