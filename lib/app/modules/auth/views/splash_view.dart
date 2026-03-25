import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundLight,
              Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : AppColors.backgroundDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              Column(
                children: [
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).brightness == Brightness.light
                              ? AppColors.surfaceLight
                              : AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.school,
                      size: 80,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: 'Edu',
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? AppColors.textLight
                                    : AppColors.textDark,
                          ),
                        ),
                        TextSpan(
                          text: 'Sync',
                          style: const TextStyle(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Institutional Ecosystem',
                    style: TextStyle(
                      color:
                          Theme.of(context).brightness == Brightness.light
                              ? AppColors.textSecondaryLight
                              : AppColors.textSecondaryDark,
                      letterSpacing: 1.5,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: controller.goToNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'VERSION 1.0.8 • SECURE CAMPUS',
                      style: TextStyle(
                        color:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.grey[400]
                                : AppColors.textSecondaryDark.withOpacity(0.5),
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 120,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
