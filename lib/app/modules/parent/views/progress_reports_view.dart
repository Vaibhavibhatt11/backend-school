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
      body: Obx(() {
        if (controller.isLoading.value && controller.subjects.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value.isNotEmpty &&
            controller.subjects.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(controller.errorMessage.value, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: controller.loadProgressReport,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        return SingleChildScrollView(
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
              child: Obx(() {
                final terms = controller.terms;
                if (terms.isEmpty) return const SizedBox.shrink();
                return ListView(
                  scrollDirection: Axis.horizontal,
                  children: terms
                      .map(
                        (term) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(term),
                            selected: controller.selectedTerm.value == term,
                            onSelected: (selected) {
                              if (selected) controller.setTerm(term);
                            },
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: controller.selectedTerm.value == term
                                  ? Colors.white
                                  : null,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              }),
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
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final score = (subj['score'] is num)
                                    ? (subj['score'] as num).toDouble().clamp(0, 100)
                                    : (double.tryParse('${subj['score']}') ?? 0).clamp(0, 100);
                                final avg = (subj['avg'] is num)
                                    ? (subj['avg'] as num).toDouble().clamp(0, 100)
                                    : (double.tryParse('${subj['avg']}') ?? 0).clamp(0, 100);
                                final totalWidth = constraints.maxWidth;
                                final scoreWidth = (score / 100) * totalWidth;
                                final avgOffset = (avg / 100) * totalWidth;
                                return Stack(
                                  children: [
                                    Container(
                                      height: 8,
                                      width: double.infinity,
                                      color: Colors.grey[300],
                                    ),
                                    Container(
                                      height: 8,
                                      width: scoreWidth,
                                      color: AppColors.primary,
                                    ),
                                    Positioned(
                                      left: avgOffset,
                                      child: Container(
                                        height: 8,
                                        width: 2,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                );
                              },
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
                      Obx(
                        () {
                          final present = controller.attendanceDistribution['present'] ?? 0;
                          final late = controller.attendanceDistribution['late'] ?? 0;
                          final absent = controller.attendanceDistribution['absent'] ?? 0;
                          final total = present + late + absent;
                          final pct = total > 0 ? ((present + late) / total) : 0.0;
                          return CircularProgressIndicator(
                            value: pct,
                            strokeWidth: 8,
                            backgroundColor: Colors.grey[300],
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.primary,
                            ),
                          );
                        },
                      ),
                      Obx(
                        () {
                          final present = controller.attendanceDistribution['present'] ?? 0;
                          final late = controller.attendanceDistribution['late'] ?? 0;
                          final absent = controller.attendanceDistribution['absent'] ?? 0;
                          final total = present + late + absent;
                          final pct = total > 0 ? (((present + late) / total) * 100).round() : 0;
                          return Center(
                            child: Text(
                              '$pct%',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          );
                        },
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
              children: List.generate(
                controller.feeHistory.length,
                (index) {
                  final amount = controller.feeHistory[index].toDouble();
                  final normalized = amount.clamp(0, 100);
                  return Column(
                    children: [
                      Container(
                        width: 20,
                        height: 80,
                        color: Colors.grey[300],
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: normalized * 0.8,
                            width: 20,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('M${index + 1}'),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PENDING AMOUNT',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    Text(
                      '\$${controller.feeHistory.fold<int>(0, (sum, v) => sum + v).toString()}',
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
      );
      }),
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
