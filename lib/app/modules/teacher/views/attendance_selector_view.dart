import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/navbar/teacher_bottom_nav_bar.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/attendance_selector_controller.dart';

class AttendanceSelectorView extends GetView<AttendanceSelectorController> {
  final bool embedded;

  const AttendanceSelectorView({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final d = controller.selectedDate.value;
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final weekday = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ][(d.weekday - 1).clamp(0, 6)];

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Attendance',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(icon: const Icon(Icons.search), onPressed: () {}),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Obx(
              () => Text(
                '$weekday, ${monthNames[d.month - 1]} ${d.day} • ${controller.pendingClasses.length} classes pending',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ),
          // Segmented control
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Obx(
                    () => GestureDetector(
                      onTap: () => controller.selectedTabIndex.value = 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: controller.selectedTabIndex.value == 0
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            'Pending',
                            style: TextStyle(
                              fontWeight: controller.selectedTabIndex.value == 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: controller.selectedTabIndex.value == 0
                                  ? AppColors.primary
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Obx(
                    () => GestureDetector(
                      onTap: () => controller.selectedTabIndex.value = 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: controller.selectedTabIndex.value == 1
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            'Completed',
                            style: TextStyle(
                              fontWeight: controller.selectedTabIndex.value == 1
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: controller.selectedTabIndex.value == 1
                                  ? AppColors.primary
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.pendingClasses.isEmpty &&
                  controller.completedClasses.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.selectedTabIndex.value == 0) {
                return _buildPendingList();
              } else {
                return _buildCompletedList();
              }
            }),
          ),
        ],
      ),
      bottomNavigationBar: embedded
          ? null
          : const TeacherBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildPendingList() {
    if (controller.pendingClasses.isEmpty) {
      return const Center(child: Text('No pending classes for today'));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: controller.pendingClasses.length,
      itemBuilder: (context, index) {
        final cls = controller.pendingClasses[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cls['title']!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        cls['subtitle']!,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  if (index == 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Due Now',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 14),
                  const SizedBox(width: 4),
                  Text(cls['time']!),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.toNamed(
                    AppRoutes.TEACHER_MARK_ATTENDANCE,
                    arguments: {'class': cls},
                  ),
                  child: const Text('Mark Attendance'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompletedList() {
    return Obx(() {
      if (controller.completedClasses.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('No classes completed today'),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: controller.completedClasses.length,
        itemBuilder: (context, index) {
          final cls = controller.completedClasses[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cls['title']?.toString() ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  cls['subtitle']?.toString() ?? '',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 14),
                    const SizedBox(width: 4),
                    Text(cls['time']?.toString() ?? ''),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.toNamed(
                      AppRoutes.TEACHER_MARK_ATTENDANCE,
                      arguments: {'class': cls},
                    ),
                    child: const Text('Edit Attendance'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}
