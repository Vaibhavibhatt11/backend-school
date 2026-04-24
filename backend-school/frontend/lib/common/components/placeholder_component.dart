import 'package:flutter/material.dart';
import '../theme/app_color.dart';
import '../utils/responsive.dart';

/// Common placeholder for empty or coming-soon content.
class PlaceholderComponent extends StatelessWidget {
  const PlaceholderComponent({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Responsive.w(context, 24)),
        child: Text(
          message ?? 'Content coming soon.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: Responsive.sp(context, 14),
            color: AppColor.textSecondary,
          ),
        ),
      ),
    );
  }
}
