import 'package:flutter/material.dart';

/// Breakpoints for mobile, tablet, fold, and desktop.
/// Use for layout and font/size scaling.
class Breakpoints {
  Breakpoints._();

  /// Small phones (e.g. iPhone SE)
  static const double xs = 320;

  /// Phones
  static const double sm = 360;

  /// Large phones
  static const double md = 414;

  /// Small tablets / large phones
  static const double lg = 600;

  /// Tablets
  static const double xl = 768;

  /// Large tablets / small desktop
  static const double xxl = 900;

  /// Desktop
  static const double xxxl = 1200;
}

/// Responsive helper: get value scaled by screen width.
/// [context] can be from BuildContext or use Get.context.
class Responsive {
  Responsive._();

  static Size _size(BuildContext context) => MediaQuery.sizeOf(context);

  static double width(BuildContext context) => _size(context).width;
  static double height(BuildContext context) => _size(context).height;

  /// Scale factor based on design width (e.g. 360). Use for fonts and spacing.
  static double scale(BuildContext context, {double designWidth = 360}) {
    final w = width(context);
    if (w <= Breakpoints.xs) return w / designWidth * 0.9;
    if (w <= Breakpoints.sm) return w / designWidth;
    if (w <= Breakpoints.md) return (w / designWidth).clamp(1.0, 1.15);
    if (w <= Breakpoints.lg) return (w / designWidth).clamp(1.0, 1.25);
    if (w <= Breakpoints.xl) return (w / 768).clamp(1.2, 1.4);
    return (w / 900).clamp(1.2, 1.5);
  }

  /// Responsive horizontal spacing (scale with width, cap for tablets).
  static double w(BuildContext context, double value, {double designWidth = 360}) {
    return value * scale(context, designWidth: designWidth);
  }

  /// Responsive vertical spacing.
  static double h(BuildContext context, double value, {double designWidth = 360}) {
    return value * scale(context, designWidth: designWidth);
  }

  /// Font size that scales on small screens, caps on large.
  static double sp(BuildContext context, double value, {double designWidth = 360}) {
    return value * scale(context, designWidth: designWidth);
  }

  /// Percentage of screen width (0.0 to 1.0).
  static double wp(BuildContext context, double fraction) =>
      width(context) * fraction.clamp(0.0, 1.0);

  /// Percentage of screen height.
  static double hp(BuildContext context, double fraction) =>
      height(context) * fraction.clamp(0.0, 1.0);

  static bool isPhone(BuildContext context) => width(context) < Breakpoints.lg;
  static bool isTablet(BuildContext context) =>
      width(context) >= Breakpoints.lg && width(context) < Breakpoints.xxxl;
  static bool isDesktop(BuildContext context) => width(context) >= Breakpoints.xxxl;
  static bool isFoldOrSmall(BuildContext context) => width(context) <= Breakpoints.sm;
}

/// Widget that builds different layouts by breakpoint.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.builder,
    this.phone,
    this.tablet,
    this.desktop,
  });

  final Widget Function(BuildContext context) builder;
  final Widget Function(BuildContext context)? phone;
  final Widget Function(BuildContext context)? tablet;
  final Widget Function(BuildContext context)? desktop;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (desktop != null && w >= Breakpoints.xxxl) return desktop!(context);
    if (tablet != null && w >= Breakpoints.lg) return tablet!(context);
    if (phone != null && w < Breakpoints.lg) return phone!(context);
    return builder(context);
  }
}

/// Constrains max width on tablets for readable content.
class ResponsivePadding extends StatelessWidget {
  const ResponsivePadding({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth = Breakpoints.xxl,
    this.horizontal,
    this.vertical,
  });

  final Widget child;
  final EdgeInsets? padding;
  final double maxWidth;
  final double? horizontal;
  final double? vertical;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final h = horizontal ?? 16;
    final v = vertical ?? 16;
    final effectiveHorizontal = width > maxWidth
        ? ((width - maxWidth) / 2 + h)
        : Responsive.w(context, h);
    final effectiveVertical = Responsive.h(context, v);
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: effectiveHorizontal, vertical: effectiveVertical),
      child: child,
    );
  }
}
