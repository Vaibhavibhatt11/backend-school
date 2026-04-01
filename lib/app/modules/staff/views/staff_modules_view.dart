import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/core/widgets/custom_app_bar.dart';
import 'package:erp_frontend/app/modules/staff/models/staff_module_catalog.dart';
import 'package:erp_frontend/app/modules/staff/utils/staff_portal_navigation.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffModulesView extends StatelessWidget {
  const StaffModulesView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: const CustomAppBar(title: 'Staff ERP Modules'),
      body: LayoutBuilder(
        builder: (context, c) {
          final cols = c.maxWidth > 1000
              ? 4
              : c.maxWidth > 680
              ? 3
              : 2;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: kStaffModules.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (_, i) {
              final m = kStaffModules[i];
              final screens = StaffPortalNavigation.screensForModule(m.id);
              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  final args = <String, dynamic>{'moduleId': m.id};
                  try {
                    Get.toNamed(AppRoutes.STAFF_MODULE_DETAIL, arguments: args);
                  } catch (_) {
                    StaffPortalNavigation.openModule(m.id);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(m.icon, color: AppColors.primary),
                      const SizedBox(height: 8),
                      Text(
                        m.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      if (screens.isNotEmpty)
                        Text(
                          screens.first.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      const Spacer(),
                      Text(
                        '${screens.length} screens available',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
