import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/widgets/app_user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../navbar/parent_bottom_nav_bar.dart';
import '../controllers/attendance_controller.dart';

class AttendanceTrackerView extends GetView<AttendanceController> {
  const AttendanceTrackerView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Attendance Tracker',
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Get.toNamed(AppRoutes.PARENT_NOTIFICATIONS),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Student info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Obx(
                    () => AppUserAvatar(
                      radius: 30,
                      photoUrl: controller.studentPhotoUrl.value.isEmpty
                          ? null
                          : controller.studentPhotoUrl.value,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () => Text(
                          controller.studentName.value,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Obx(
                        () => Text(
                          controller.studentClass.value,
                          style: TextStyle(
                            color:
                                isDark
                                    ? AppColors.textSecondaryDark
                                    : Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Month selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => Text(
                    controller.month.value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: controller.previousMonth,
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: controller.nextMonth,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Calendar grid
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                children: [
                  // Weekday headers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children:
                        ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                            .map(
                              (day) => Expanded(
                                child: Text(
                                  day,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 8),
                  // Calendar days grid (5 rows x 7 columns)

                  // Assuming controller.calendarDays is a list of 35 items (some null)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          childAspectRatio: 1,
                        ),
                    itemCount: 35,
                    itemBuilder: (context, index) {
                      final day = controller.calendarDays[index];
                      if (day == null) {
                        return Container();
                      }
                      // Determine status based on dummy data (we'll add a method in controller)
                      String status = controller.getStatusForDay(day);
                      Color bgColor;
                      Color textColor;
                      if (status == 'present') {
                        bgColor = Colors.green.withOpacity(0.1);
                        textColor = Colors.green;
                      } else if (status == 'absent') {
                        bgColor = Colors.red.withOpacity(0.1);
                        textColor = Colors.red;
                      } else if (status == 'late') {
                        bgColor = Colors.orange.withOpacity(0.1);
                        textColor = Colors.orange;
                      } else {
                        bgColor = Colors.transparent;
                        textColor = isDark ? Colors.white : Colors.black;
                      }
                      return Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            day.toString(),
                            style: TextStyle(
                              color: textColor,
                              fontWeight:
                                  status.isNotEmpty
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLegendItem(Colors.green, 'Present'),
                      _buildLegendItem(Colors.red, 'Absent'),
                      _buildLegendItem(Colors.orange, 'Late'),
                      _buildLegendItem(Colors.grey, 'Holiday'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Performance summary
            const Text(
              'Performance Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A), // dark card
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Circular progress
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: 0.9,
                              strokeWidth: 8,
                              backgroundColor: Colors.white10,
                              valueColor: const AlwaysStoppedAnimation(
                                AppColors.primary,
                              ),
                            ),
                            Center(
                              child: Text(
                                '90%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Excellent!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Marcus has been very consistent. Only 2 absences recorded this month.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Stats grid
                  Obx(
                    () => Row(
                      children: [
                        _buildStatItem(
                          'Present',
                          controller.attendanceStats['present'].toString(),
                          Colors.green,
                        ),
                        _buildStatItem(
                          'Absent',
                          controller.attendanceStats['absent'].toString(),
                          Colors.red,
                        ),
                        _buildStatItem(
                          'Late',
                          controller.attendanceStats['late'].toString(),
                          Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: const ParentBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
