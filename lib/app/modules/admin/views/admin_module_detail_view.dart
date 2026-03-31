import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/admin/models/admin_module_catalog.dart';
import 'package:erp_frontend/app/modules/admin/utils/admin_portal_navigation.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminModuleDetailView extends StatelessWidget {
  const AdminModuleDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final rawArgs = Get.arguments as Map?;
    final args = rawArgs?.cast<String, dynamic>() ?? const {};
    final moduleId = (args['moduleId'] ?? '').toString();
    final module = kAdminModules.firstWhereOrNull((m) => m.id == moduleId);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (module == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (moduleId.isNotEmpty) {
          AdminPortalNavigation.openFromCatalog(
            moduleId: moduleId,
            feature: args['feature']?.toString() ?? moduleId,
          );
        } else {
          Get.back();
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(module.title),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        module.description,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Features',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 10),
          ...module.features.map(
            (feature) => _FeatureTile(module: module, feature: feature),
          ),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.module, required this.feature});
  final AdminModuleItem module;
  final String feature;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: ListTile(
        onTap: () => AdminPortalNavigation.openFromCatalog(
          moduleId: module.id,
          feature: feature,
        ),
        leading: const Icon(Icons.task_alt_rounded, color: AppColors.primary),
        title: Text(
          feature,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ),
        ),
        subtitle: Text(
          'Open workflow and manage $feature',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

class AdminFeatureDetailView extends StatelessWidget {
  const AdminFeatureDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final moduleId = (args['moduleId'] ?? '').toString();
    final feature = (args['feature'] ?? 'Feature').toString();
    final module = kAdminModules.firstWhereOrNull((m) => m.id == moduleId);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(feature),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _summaryCard(isDark, module?.title ?? 'Admin Module', feature),
          const SizedBox(height: 14),
          _workflowCard(isDark),
          const SizedBox(height: 14),
          _dataEntryCard(isDark),
          const SizedBox(height: 14),
          _actionsRow(),
        ],
      ),
    );
  }

  Widget _summaryCard(bool isDark, String moduleTitle, String feature) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Feature Overview',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Module: $moduleTitle',
            style: TextStyle(
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Feature: $feature',
            style: TextStyle(
              color: isDark ? AppColors.textDark : AppColors.textLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _workflowCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Workflow',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 8),
          const Text('1) Create/Update'),
          const Text('2) Review/Approve'),
          const Text('3) Publish/Notify'),
          const Text('4) Track analytics'),
        ],
      ),
    );
  }

  Widget _dataEntryCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data Entry',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 8),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          const TextField(
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Description / Notes',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionsRow() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => AppToast.show('Saved as draft'),
            child: const Text('Save Draft'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () => AppToast.show('Submitted successfully'),
            child: const Text('Submit'),
          ),
        ),
      ],
    );
  }
}

