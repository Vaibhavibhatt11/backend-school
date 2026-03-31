import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../navbar/parent_bottom_nav_bar.dart';
import '../controllers/timetable_controller.dart';

class DailyTimetableView extends GetView<TimetableController> {
  const DailyTimetableView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Daily Timetable',
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => controller.toggleView(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and view toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => Text(
                    '${controller.selectedDate.value.year}-${controller.selectedDate.value.month.toString().padLeft(2, '0')}-${controller.selectedDate.value.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      _buildToggleOption('DAY', 0),
                      _buildToggleOption('WEEK', 1),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Weekday selectors
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (context, index) {
                  final now = controller.selectedDate.value;
                  final mondayOffset = now.weekday - 1;
                  final monday = DateTime(now.year, now.month, now.day - mondayOffset);
                  final d = DateTime(monday.year, monday.month, monday.day + index);
                  final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  final dayNumber = d.day;
                  return GestureDetector(
                    onTap: () => controller.changeDate(d),
                    child: Obx(
                      () => Container(
                        width: 60,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color:
                              controller.selectedDay.value == dayNumber
                                  ? AppColors.primary
                                  : (isDark
                                      ? AppColors.surfaceDark
                                      : Colors.white),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                controller.selectedDay.value ==
                                        dayNumber
                                    ? AppColors.primary
                                    : (isDark
                                        ? AppColors.borderDark
                                        : AppColors.borderLight),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dayNames[index],
                              style: TextStyle(
                                color:
                                    controller.selectedDay.value ==
                                            dayNumber
                                        ? Colors.white
                                        : (isDark
                                            ? Colors.white
                                            : Colors.black),
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dayNumber.toString(),
                              style: TextStyle(
                                color:
                                    controller.selectedDay.value ==
                                            dayNumber
                                        ? Colors.white
                                        : (isDark
                                            ? Colors.white
                                            : Colors.black),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // Timetable list
            Obx(
              () {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (controller.errorMessage.value.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        controller.errorMessage.value,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                if (controller.timetable.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text('No timetable classes scheduled for this day.'),
                    ),
                  );
                }
                return Column(
                  children: controller.timetable.map((item) {
                    return _buildClassCard(
                      time: (item['time'] ?? '').toString(),
                      subject: (item['subject'] ?? '').toString(),
                      teacher: (item['teacher'] ?? '').toString(),
                      room: (item['room'] ?? '').toString(),
                      period: (item['period'] ?? '').toString(),
                      isLive: item['isLive'] == true,
                      progress: item['progress'] is num
                          ? (item['progress'] as num).toDouble()
                          : null,
                      remaining: item['remaining']?.toString(),
                      onJoin: item['isLive'] == true
                          ? () => controller.joinLiveClass(
                                (item['subject'] ?? '').toString(),
                              )
                          : null,
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: const ParentBottomNavBar(currentIndex: 3),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.toggleView,
        child: const Icon(Icons.grid_view),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildToggleOption(String label, int index) {
    return Obx(
      () => GestureDetector(
        onTap: () => controller.dayView.value = index == 0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color:
                (index == 0 && controller.dayView.value) ||
                        (index == 1 && !controller.dayView.value)
                    ? (Theme.of(Get.context!).brightness == Brightness.dark
                        ? AppColors.surfaceDark
                        : Colors.white)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color:
                  (index == 0 && controller.dayView.value) ||
                          (index == 1 && !controller.dayView.value)
                      ? AppColors.primary
                      : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClassCard({
    required String time,
    required String subject,
    required String teacher,
    required String room,
    required String period,
    required bool isLive,
    double? progress,
    String? remaining,
    VoidCallback? onJoin,
  }) {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isLive
                  ? AppColors.primary
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: isLive ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  subject,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (isLive)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.fiber_manual_record,
                        color: Colors.red,
                        size: 12,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Live Now',
                        style: TextStyle(color: Colors.red, fontSize: 10),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(period, style: const TextStyle(fontSize: 10)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.person, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(teacher)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.meeting_room, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(room)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(time, style: const TextStyle(color: Colors.grey)),
              if (isLive && progress != null && remaining != null)
                Row(
                  children: [
                    Text(
                      '$remaining remaining',
                      style: const TextStyle(color: AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 50,
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (isLive && onJoin != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onJoin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Join Classroom'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
