import 'package:flutter/material.dart';
import 'package:erp_frontend/common/utils/responsive.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool isOutlined;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: _buildChild(context),
      );
    }
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: _buildChild(context),
    );
  }

  Widget _buildChild(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: Responsive.clamp(context, 20, min: 16, max: 24),
        width: Responsive.clamp(context, 20, min: 16, max: 24),
        child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: Responsive.clamp(context, 20, min: 16, max: 24)),
          SizedBox(width: Responsive.clamp(context, 8, min: 6, max: 12)),
          Flexible(child: Text(text, overflow: TextOverflow.ellipsis)),
        ],
      );
    }
    return Text(text);
  }
}
