import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/teacher/models/teacher_models.dart';
import 'package:erp_frontend/app/navbar/teacher_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/student_profile_controller.dart';

class StudentProfileView extends GetView<StudentProfileController> {
  const StudentProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final student = controller.student;
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 12),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  onPressed: () => Get.back(),
                ),
                const Spacer(),
                Text(
                  'Student Profile',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: 20),
                // Profile header
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                student.imageUrl != null
                                    ? NetworkImage(student.imageUrl!)
                                    : null,
                            child:
                                student.imageUrl == null
                                    ? const Icon(Icons.person, size: 50)
                                    : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.fromBorderSide(
                                  BorderSide(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        student.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Grade ${student.grade}',
                              style: const TextStyle(color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'ID: ${student.rollNo}',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Quick info grid
                Row(
                  children: [
                    Expanded(
                      child: _infoCard(
                        label: 'Date of Birth',
                        value: '--',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _infoCard(
                        label: 'Gender',
                        value: '--',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Parent/Guardian
                Text(
                  'Parent / Guardian',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                _parentTile(
                  name: 'Sarah Henderson',
                  relation: 'Mother',
                  onCall: () => controller.callParent(''),
                  onMessage: () => controller.messageParent(''),
                ),
                _parentTile(
                  name: 'Robert Henderson',
                  relation: 'Father',
                  onCall: () => controller.callParent(''),
                  onMessage: () => controller.messageParent(''),
                ),
                const SizedBox(height: 24),
                // Attendance Record
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Attendance Record',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '${student.attendancePercentage}%',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent 5 Days',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          Row(
                            children:
                                ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'].map((day) {
                                  final status =
                                      student.recentAttendance[day] ??
                                      AttendanceStatus.unknown;
                                  Color bgColor;
                                  IconData icon;
                                  Color iconColor;
                                  switch (status) {
                                    case AttendanceStatus.present:
                                      bgColor = Colors.green.shade100;
                                      icon = Icons.check;
                                      iconColor = Colors.green;
                                      break;
                                    case AttendanceStatus.absent:
                                      bgColor = Colors.red.shade100;
                                      icon = Icons.close;
                                      iconColor = Colors.red;
                                      break;
                                    case AttendanceStatus.late:
                                      bgColor = Colors.orange.shade100;
                                      icon = Icons.access_time;
                                      iconColor = Colors.orange;
                                      break;
                                    default:
                                      bgColor = Colors.grey.shade200;
                                      icon = Icons.help;
                                      iconColor = Colors.grey;
                                  }
                                  return Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: bgColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      icon,
                                      size: 16,
                                      color: iconColor,
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: student.attendancePercentage / 100,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Upload Document button
                ElevatedButton.icon(
                  onPressed: controller.uploadDocument,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Document'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const TeacherBottomNavBar(currentIndex: 2),
    );
  }

  Widget _infoCard({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _parentTile({
    required String name,
    required String relation,
    required VoidCallback onCall,
    required VoidCallback onMessage,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  relation,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.call, color: AppColors.primary),
            onPressed: onCall,
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble, color: AppColors.primary),
            onPressed: onMessage,
          ),
        ],
      ),
    );
  }
}
