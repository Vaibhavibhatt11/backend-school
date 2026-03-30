import 'package:erp_frontend/common/widgets/app_user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../navbar/parent_bottom_nav_bar.dart';
import '../controllers/profile_controller.dart';

class StudentProfileHubView extends GetView<ProfileController> {
  const StudentProfileHubView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Profile Hub',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: controller.openSettings,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.goToLibrary,
        child: const Icon(Icons.my_library_books),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF429BEE)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Obx(
                    () => AppUserAvatar(
                      radius: 40,
                      photoUrl: controller.studentPhotoUrl.value.isEmpty
                          ? null
                          : controller.studentPhotoUrl.value,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Text(
                            controller.studentName.value,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Obx(
                          () => Text(
                            controller.studentClass.value,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Obx(
                            () => Text(
                              controller.academicYear.value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Tabs
            DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  const TabBar(
                    isScrollable: true,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: 'Personal'),
                      Tab(text: 'Academic History'),
                      Tab(text: 'Documents'),
                      Tab(text: 'Activities'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Personal tab content
                  SizedBox(
                    height:
                        600, // fixed height, but we'll use SingleChildScrollView inside
                    child: TabBarView(
                      children: [
                        _buildPersonalTab(isDark),
                        _buildAcademicTab(isDark),
                        _buildDocumentsTab(isDark),
                        _buildActivitiesTab(isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const ParentBottomNavBar(currentIndex: 4),
    );
  }

  Widget _buildPersonalTab(bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Personal Details',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: controller.editPersonal,
                child: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildInfoBox(
                  icon: Icons.cake,
                  label: 'Date of Birth',
                  value: controller.dob.value,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoBox(
                  icon: Icons.bloodtype,
                  label: 'Blood Group',
                  value: controller.bloodGroup.value,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Guardian Info',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: controller.editGuardian,
                child: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildGuardianCard('Father', controller.fatherName.value),
          const SizedBox(height: 8),
          _buildGuardianCard('Mother', controller.motherName.value),
          const SizedBox(height: 24),
          const Text(
            'Performance',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Current Term'),
                    Obx(
                      () => Text(
                        'Grade: ${controller.currentTermGrade.value}',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: controller.currentTermPercentage.value / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${controller.currentTermPercentage.value}%'),
                    Text(
                      'Class Avg: ${controller.classAvg.value}%',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildInfoBox({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildGuardianCard(String role, String name) {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.green, size: 20),
            onPressed: controller.loadProfile,
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicTab(bool isDark) {
    return Center(
      child: Obx(
        () => Text(
          controller.currentTermPercentage.value > 0
              ? 'Current term performance: ${controller.currentTermPercentage.value.toStringAsFixed(1)}%'
              : 'No academic history available yet.',
        ),
      ),
    );
  }

  Widget _buildDocumentsTab(bool isDark) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quick Documents',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              TextButton(onPressed: null, child: Text('View All')),
            ],
          ),
          const SizedBox(height: 8),
          Obx(
            () => Column(
              children:
                  controller.documents.map((doc) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.description,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc['name']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${doc['status']} • ${doc['size']}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.download),
                            onPressed:
                                () => controller.downloadDocument(doc['name']!),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesTab(bool isDark) {
    return const Center(child: Text('No activities available yet.'));
  }
}
