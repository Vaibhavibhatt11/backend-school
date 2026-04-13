import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/app_toast.dart';

class DoubleBackExitScope extends StatefulWidget {
  const DoubleBackExitScope({
    super.key,
    required this.child,
    this.message = 'Press again to Exit',
    this.interval = const Duration(seconds: 2),
  });

  final Widget child;
  final String message;
  final Duration interval;

  @override
  State<DoubleBackExitScope> createState() => _DoubleBackExitScopeState();
}

class _DoubleBackExitScopeState extends State<DoubleBackExitScope> {
  DateTime? _lastBackPressedAt;

  void _handleBackPress() {
    final now = DateTime.now();
    final recentlyPressed =
        _lastBackPressedAt != null &&
        now.difference(_lastBackPressedAt!) <= widget.interval;

    if (recentlyPressed) {
      SystemNavigator.pop();
      return;
    }

    _lastBackPressedAt = now;
    AppToast.show(widget.message);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBackPress();
      },
      child: widget.child,
    );
  }
}
