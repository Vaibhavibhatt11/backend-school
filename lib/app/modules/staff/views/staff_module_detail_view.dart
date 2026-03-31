import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/core/widgets/custom_app_bar.dart';
import 'package:erp_frontend/app/modules/staff/models/staff_module_catalog.dart';
import 'package:erp_frontend/app/modules/staff/utils/staff_portal_navigation.dart';
import 'package:erp_frontend/app/modules/staff/widgets/staff_ai_assistant_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffModuleDetailView extends StatelessWidget {
  const StaffModuleDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final rawArgs = Get.arguments as Map?;
    final args = rawArgs?.cast<String, dynamic>() ?? const {};
    final id = (args['moduleId'] ?? '').toString();
    final module = kStaffModules.firstWhereOrNull((e) => e.id == id);
    if (module == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (id.isNotEmpty) {
          StaffPortalNavigation.openModule(id);
        } else {
          Get.back();
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: CustomAppBar(title: module.title),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (module.id == 'ai_teaching_assistant') ...[
            FilledButton.icon(
              onPressed: StaffAiAssistantSheet.open,
              icon: const Icon(Icons.smart_toy_rounded),
              label: const Text('Open AI Teaching Assistant'),
            ),
            const SizedBox(height: 16),
          ],
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(module.icon, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${module.features.length} feature workflows',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...module.features.map(
            (f) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: ListTile(
                onTap: () => StaffPortalNavigation.openModule(
                  module.id,
                  feature: f,
                ),
                leading: const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary),
                title: Text(f),
                subtitle: Text(
                  module.id == 'ai_teaching_assistant'
                      ? 'Powered by server-side LLM when configured.'
                      : 'Tap to open the linked screen for this workflow.',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

