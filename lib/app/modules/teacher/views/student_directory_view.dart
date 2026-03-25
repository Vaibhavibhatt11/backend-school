import 'package:erp_frontend/app/core/constants/app_constants.dart';
import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/teacher/models/teacher_models.dart';
import 'package:erp_frontend/app/navbar/teacher_bottom_nav_bar.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/student_directory_controller.dart';

class StudentDirectoryView extends GetView<StudentDirectoryController> {
  const StudentDirectoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Header with back and filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: () => Get.back(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Grade 10-A',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Mathematics • 24 Students',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (value) => controller.searchQuery.value = value,
                decoration: InputDecoration(
                  hintText: 'Search students by name or ID...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Alphabetical index (vertical on right)
            Expanded(
              child: Obx(() {
                final grouped = controller.groupedStudents;

                return Row(
                  children: [
                    /// MAIN LIST
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children:
                            grouped.entries.map((entry) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Section Header
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              entry.key,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Divider(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  ...entry.value.map(
                                    (student) => _buildStudentTile(student),
                                  ),

                                  const SizedBox(height: 12),
                                ],
                              );
                            }).toList(),
                      ),
                    ),

                    /// ALPHABET SIDEBAR
                    Container(
                      width: 30,
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(26, (index) {
                            final letter = String.fromCharCode(65 + index);
                            return GestureDetector(
                              onTap: () => controller.selectLetter(letter),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Text(
                                  letter,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight:
                                        controller.selectedLetter.value ==
                                                letter
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    color:
                                        controller.selectedLetter.value ==
                                                letter
                                            ? AppColors.primary
                                            : Colors.grey,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),

      bottomNavigationBar: const TeacherBottomNavBar(
        currentIndex: 2,
      ), // Classes tab
    );
  }

  Widget _buildStudentTile(Student student) {
    Color statusColor;
    IconData statusIcon;
    switch (student.recentAttendance.values.last) {
      // just an example
      case AttendanceStatus.present:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case AttendanceStatus.absent:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case AttendanceStatus.late:
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return GestureDetector(
      onTap:
          () => Get.toNamed(
            AppRoutes.TEACHER_STUDENT_PROFILE,
            arguments: student,
          ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                '${AppConstants.placeholderImage}${student.id}',
              ),
              child: student.imageUrl == null ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Roll: ${student.rollNo}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            // Status indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(statusIcon, size: 14, color: statusColor),
                  const SizedBox(width: 4),
                  Text(
                    student.recentAttendance.values.last
                        .toString()
                        .split('.')
                        .last,
                    style: TextStyle(fontSize: 10, color: statusColor),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
