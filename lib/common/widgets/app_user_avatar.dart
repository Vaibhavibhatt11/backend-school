import 'package:flutter/material.dart';

/// User avatar: [photoUrl] when backend provides HTTPS URL; otherwise a local person icon (no demo URLs).
class AppUserAvatar extends StatelessWidget {
  const AppUserAvatar({
    super.key,
    this.photoUrl,
    this.radius = 16,
    this.backgroundColor,
  });

  final String? photoUrl;
  final double radius;
  final Color? backgroundColor;

  bool get _hasUrl {
    final u = photoUrl?.trim();
    return u != null &&
        u.isNotEmpty &&
        (u.startsWith('https://') || u.startsWith('http://'));
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasUrl) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.grey.shade300,
        child: Icon(Icons.person, size: radius * 1.15, color: Colors.grey.shade700),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey.shade300,
      backgroundImage: NetworkImage(photoUrl!.trim()),
      onBackgroundImageError: (_, __) {},
      child: null,
    );
  }
}
