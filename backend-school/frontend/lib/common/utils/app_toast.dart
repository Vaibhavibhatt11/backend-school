import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppToast {
  AppToast._();

  static OverlayEntry? _entry;
  static Timer? _timer;

  static void show(String message) {
    final overlay = Get.key.currentState?.overlay;
    if (overlay == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final retryOverlay = Get.key.currentState?.overlay;
        if (retryOverlay == null) return;
        _insertToast(retryOverlay, message);
      });
      return;
    }

    _insertToast(overlay, message);
  }

  static void _insertToast(OverlayState overlay, String message) {
    _timer?.cancel();
    _entry?.remove();

    _entry = OverlayEntry(
      builder: (ctx) => Positioned(
        left: 20,
        right: 20,
        bottom: 36,
        child: IgnorePointer(
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_entry!);
    _timer = Timer(const Duration(seconds: 2), () {
      _entry?.remove();
      _entry = null;
    });
  }
}

