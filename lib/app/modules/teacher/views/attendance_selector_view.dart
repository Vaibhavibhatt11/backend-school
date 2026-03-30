import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/navbar/teacher_bottom_nav_bar.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/attendance_selector_controller.dart';

class AttendanceSelectorView extends GetView<AttendanceSelectorController> {
  const AttendanceSelectorView({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: Text(
              'Thursday, Oct 24 • 3 classes left',
              style: TextStyle(color: Colors.grey.shade600),
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
                          color:
                              controller.selectedTabIndex.value == 0
                                  ? Colors.white
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            'Pending',
                            style: TextStyle(
                              fontWeight:
                                  controller.selectedTabIndex.value == 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              color:
                                  controller.selectedTabIndex.value == 0
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
                          color:
                              controller.selectedTabIndex.value == 1
                                  ? Colors.white
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            'Completed',
                            style: TextStyle(
                              fontWeight:
                                  controller.selectedTabIndex.value == 1
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              color:
                                  controller.selectedTabIndex.value == 1
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
              if (controller.selectedTabIndex.value == 0) {
                return _buildPendingList();
              } else {
                return _buildCompletedList();
              }
            }),
          ),
        ],
      ),
      bottomNavigationBar: const TeacherBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildPendingList() {
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
                  onPressed:
                      () => Get.toNamed(
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
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text('2 classes completed today'),
          SizedBox(height: 4),
          Text('View history', style: TextStyle(color: AppColors.primary)),
        ],
      ),
    );
  }
}
