import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/core/widgets/custom_app_bar.dart';
import 'package:erp_frontend/app/modules/staff/models/staff_module_catalog.dart';
import 'package:erp_frontend/app/modules/staff/utils/staff_portal_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffFeatureDetailView extends StatelessWidget {
  const StaffFeatureDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final rawArgs = Get.arguments as Map?;
    final args = rawArgs?.cast<String, dynamic>() ?? const {};
    final moduleId = (args['moduleId'] ?? '').toString();
    final moduleName = (args['module'] ?? '').toString();
    final feature = (args['feature'] ?? 'Workflow').toString();
    final module = kStaffModules.firstWhereOrNull(
      (item) => item.id == moduleId,
    );
    final title =
        module?.title ?? (moduleName.isEmpty ? 'Staff Workflow' : moduleName);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screens = StaffPortalNavigation.screensForModule(moduleId);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: CustomAppBar(title: title),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feature,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This workflow is now routed through real staff and teacher screens instead of a placeholder page.',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: screens.isEmpty
                          ? () => StaffPortalNavigation.openModule(
                              moduleId,
                              feature: feature,
                            )
                          : () =>
                                StaffPortalNavigation.openScreen(screens.first),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('Open Linked Screen'),
                    ),
                  ),
                ],
              ),
            ),
            if (screens.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Related Screens',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: screens.length,
                  itemBuilder: (context, index) {
                    final screen = screens[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                      ),
                      child: ListTile(
                        onTap: () => StaffPortalNavigation.openScreen(screen),
                        leading: const Icon(
                          Icons.open_in_new_rounded,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          screen.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textDark
                                : AppColors.textLight,
                          ),
                        ),
                        subtitle: Text(
                          screen.description,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
