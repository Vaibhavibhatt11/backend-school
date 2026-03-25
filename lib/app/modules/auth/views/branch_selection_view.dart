import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../controllers/branch_controller.dart';

class BranchSelectionView extends GetView<BranchController> {
  const BranchSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: const CustomAppBar(title: 'Branch Selection'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Your Campus',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose the school branch you are associated with.',
                  style: TextStyle(
                    color:
                        isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    onChanged: (val) => controller.searchQuery.value = val,
                    decoration: InputDecoration(
                      hintText: 'Search by name or city...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.filteredBranches.length,
                itemBuilder: (context, index) {
                  final branch = controller.filteredBranches[index];
                  return GestureDetector(
                    onTap: () => controller.selectBranch(branch.id),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            branch.isSelected
                                ? AppColors.primary.withOpacity(0.05)
                                : (isDark
                                    ? AppColors.surfaceDark
                                    : AppColors.surfaceLight),
                        border: Border.all(
                          color:
                              branch.isSelected
                                  ? AppColors.primary
                                  : (isDark
                                      ? AppColors.borderDark
                                      : AppColors.borderLight),
                          width: branch.isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color:
                                  branch.isSelected
                                      ? AppColors.primary.withOpacity(0.2)
                                      : (isDark
                                          ? AppColors.surfaceDark
                                          : Colors.grey[100]),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.school, color: AppColors.primary),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  branch.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color:
                                        isDark
                                            ? AppColors.textDark
                                            : AppColors.textLight,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  branch.address,
                                  style: TextStyle(
                                    color:
                                        isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (branch.isSelected)
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
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      isDark
                                          ? AppColors.borderDark
                                          : AppColors.borderLight,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: controller.confirmSelection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Confirm Selection',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
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
          ),
        ],
      ),
    );
  }
}
