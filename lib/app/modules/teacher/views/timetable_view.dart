import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/teacher/models/teacher_models.dart';
import 'package:erp_frontend/app/navbar/teacher_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/timetable_controller.dart';

class TimetableView extends GetView<TimetableController> {
  const TimetableView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 12),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => Text(
                        'Week of ${controller.selectedDay.value.day}/${controller.selectedDay.value.month}/${controller.selectedDay.value.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    const Text(
                      'Weekly Timetable',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Day selector
          SizedBox(
            height: 70,
            child: Obx(
              () => ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: controller.days.length,
                itemBuilder: (context, index) {
                  final day = controller.days[index];
                  final isSelected =
                      day.day == controller.selectedDay.value.day;
                  return GestureDetector(
                    onTap: () => controller.selectDay(day),
                    child: Container(
                      width: 60,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected
                                  ? AppColors.primary
                                  : Colors.grey.shade300,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            controller.weekDays[index],
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isSelected
                                      ? Colors.white
                                      : Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            day.day.toString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black,
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
          const SizedBox(height: 16),
          // Time line and sessions
          Expanded(
            child: Obx(() {
              // If there is a current time indicator
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: controller.sessions.length,
                itemBuilder: (context, index) {
                  final session = controller.sessions[index];
                  final startHour =
                      session.startTime.hour + session.startTime.minute / 60.0;
                  final endHour =
                      session.endTime.hour + session.endTime.minute / 60.0;
                  final height = (endHour - startHour) * 80; // 80px per hour

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    height: height,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: _getSessionColor(session),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    session.isLive
                                        ? AppColors.primary
                                        : Colors.grey.shade300,
                                width: session.isLive ? 2 : 1,
                              ),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    color: _getLeftBarColor(session),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (session.title.isNotEmpty)
                                        Text(
                                          session.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      if (session.grade.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.room, size: 12),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${session.room} • ${session.grade}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${controller.formatTime(session.startTime)}-${controller.formatTime(session.endTime)}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    if (session.isLive)
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Text(
                                          'LIVE',
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    if (session.isCompleted)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Current time indicator
                        if (session.isLive)
                          Positioned(
                            left: 0,
                            right: 0,
                            top: height * 0.3,
                            child: Container(
                              height: 2,
                              color: AppColors.primary,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: const TeacherBottomNavBar(currentIndex: 3),
    );
  }

  Color _getSessionColor(ClassSession session) {
    if (session.isLive) return AppColors.primary.withValues(alpha: 0.05);
    if (session.isCompleted) return Colors.grey.shade100;
    if (session.title == 'Free Period') return Colors.transparent;
    return Colors.white;
  }

  Color _getLeftBarColor(ClassSession session) {
    if (session.isLive) return AppColors.primary;
    if (session.isCompleted) return Colors.green;
    if (session.title == 'Free Period') return Colors.grey;
    return AppColors.primary.withValues(alpha: 0.5);
  }
}
