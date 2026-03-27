import 'package:erp_frontend/app/modules/parent/controllers/progress_reposrts_controller.dart';
import 'package:erp_frontend/common/widgets/app_user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../navbar/parent_bottom_nav_bar.dart';

class ProgressReportsView extends GetView<ProgressReportsController> {
  const ProgressReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Progress Reports',
        actions: [
          IconButton(icon: const Icon(Icons.ios_share), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Text(
                            controller.studentName.value,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Obx(
                          () => Text(
                            controller.studentClass.value,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.expand_more),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Term selector
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:
                    ['Term 2', 'Term 1', 'Monthly Tests', 'Assignments']
                        .asMap()
                        .map(
                          (index, term) => MapEntry(
                            index,
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Obx(
                                () => ChoiceChip(
                                  label: Text(term),
                                  selected:
                                      controller.selectedTerm.value == index,
                                  onSelected: (selected) {
                                    if (selected) controller.setTerm(index);
                                  },
                                  selectedColor: AppColors.primary,
                                  labelStyle: TextStyle(
                                    color:
                                        controller.selectedTerm.value == index
                                            ? Colors.white
                                            : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .values
                        .toList(),
              ),
            ),
            const SizedBox(height: 24),
            // GPA and Attendance
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'GPA',
                    '${controller.gpa.value}',
                    controller.gpaChange.value,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Attendance',
                    '${controller.attendance.value}%',
                    null,
                    status: controller.attendanceStatus.value,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Subject performance
            const Text(
              'Subject Performance',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Column(
                children:
                    controller.subjects.map((subj) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(subj['name']! as String),
                                Text(
                                  '${subj['score']}% / 100',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Stack(
                              children: [
                                Container(
                                  height: 8,
                                  width: double.infinity,
                                  color: Colors.grey[300],
                                ),
                                Container(
                                  height: 8,
                                  width: (subj['score'] as int).toDouble(),
                                  color: AppColors.primary,
                                ),
                                // Class avg marker
                                Positioned(
                                  left: (subj['avg'] as int).toDouble(),
                                  child: Container(
                                    height: 8,
                                    width: 2,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Current',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  'Class Avg',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: controller.viewFullMarksheet,
                child: const Text('View Full Marksheet'),
              ),
            ),
            const SizedBox(height: 24),
            // Attendance distribution
            const Text(
              'Attendance Distribution',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: 0.94,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.primary,
                        ),
                      ),
                      const Center(
                        child: Text(
                          '94%',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      _buildLegendRow(
                        'Present',
                        controller.attendanceDistribution['present'].toString(),
                        Colors.green,
                      ),
                      _buildLegendRow(
                        'Late',
                        controller.attendanceDistribution['late'].toString(),
                        Colors.orange,
                      ),
                      _buildLegendRow(
                        'Absent',
                        controller.attendanceDistribution['absent'].toString(),
                        Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Fee payment history
            const Text(
              'Fee Payment History',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Status of current term installments',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children:
                  ['SEP', 'OCT', 'NOV', 'DEC', 'JAN']
                      .asMap()
                      .map(
                        (index, month) => MapEntry(
                          index,
                          Column(
                            children: [
                              Container(
                                width: 20,
                                height: 80,
                                color: Colors.grey[300],
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    height:
                                        controller.feeHistory[index].toDouble(),
                                    width: 20,
                                    color:
                                        index == 3
                                            ? AppColors.primary.withOpacity(0.5)
                                            : AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(month),
                            ],
                          ),
                        ),
                      )
                      .values
                      .toList(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'PENDING AMOUNT',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    Text(
                      '\$1,250.00',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: controller.payNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Pay Now'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: const ParentBottomNavBar(
        currentIndex: 0,
      ), // Reports from home
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    double? change, {
    String? status,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            Theme.of(Get.context!).brightness == Brightness.dark
                ? AppColors.surfaceDark
                : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              Theme.of(Get.context!).brightness == Brightness.dark
                  ? AppColors.borderDark
                  : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (change != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    '${change > 0 ? '+' : ''}$change',
                    style: TextStyle(
                      color: change > 0 ? Colors.green : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              if (status != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
