import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffProfileView extends GetView<StaffProfileController> {
  const StaffProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Obx(() {
        if (controller.isLoading.value && controller.name.value.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Staff Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                        child: Text(
                          controller.name.value.isEmpty ? 'S' : controller.name.value.trim()[0].toUpperCase(),
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          controller.name.value,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Department: ${controller.department.value}'),
                  Text('Qualification: ${controller.qualification.value}'),
                  Text('Experience: ${controller.experience.value}'),
                  Text('Contact: ${controller.contact.value}'),
                  Text('Email: ${controller.email.value}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Documents', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Obx(
                  () => Column(
                    children: controller.documents
                        .map(
                          (d) => ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.description_rounded, color: AppColors.primary, size: 18),
                            ),
                            title: Text(d),
                            trailing: const Icon(Icons.chevron_right_rounded),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
      }),
    );
  }
}

