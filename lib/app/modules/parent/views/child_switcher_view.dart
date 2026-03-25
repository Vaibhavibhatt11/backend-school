import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../controllers/child_switcher_controller.dart';

class ChildSwitcherView extends GetView<ChildSwitcherController> {
  const ChildSwitcherView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Switch Child',
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Children',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Select a profile to view school records and activities.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Obx(
              () => Column(
                children:
                    controller.children.asMap().entries.map((entry) {
                      final index = entry.key;
                      final child = entry.value;
                      return GestureDetector(
                        onTap: () => controller.selectChild(index),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                child['active'] as bool
                                    ? AppColors.primary.withOpacity(0.05)
                                    : (isDark
                                        ? AppColors.surfaceDark
                                        : Colors.white),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  child['active'] as bool
                                      ? AppColors.primary
                                      : (isDark
                                          ? AppColors.borderDark
                                          : AppColors.borderLight),
                              width: child['active'] as bool ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(
                                  'https://via.placeholder.com/60',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      child['name']! as String,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '${child['grade']} • ID: ${child['id']}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    if (child['active'] as bool)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 4),
                                        child: Text(
                                          'Currently Viewing',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (child['active'] as bool)
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                )
                              else
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey,
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: controller.linkAnotherChild,
              icon: const Icon(Icons.person_add_alt),
              label: const Text('Link Another Child'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info, color: AppColors.primary, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Changing the active student will update your dashboard, attendance, and fee information. You can switch back at any time.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
