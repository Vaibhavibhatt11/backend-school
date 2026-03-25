import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../navbar/parent_bottom_nav_bar.dart';
import '../controllers/live_class_controller.dart';

class LiveClassroomPortalView extends GetView<LiveClassController> {
  const LiveClassroomPortalView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Live Classes',
        actions: [
          IconButton(icon: const Icon(Icons.calendar_today), onPressed: () {}),
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage('https://via.placeholder.com/32'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weekday selector
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (context, index) {
                  final days = [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun',
                  ];
                  final dates = [12, 13, 14, 15, 16, 17, 18];
                  return GestureDetector(
                    onTap: () {
                      // change selected date
                    },
                    child: Container(
                      width: 60,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color:
                            dates[index] == 12
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.surfaceDark
                                    : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              dates[index] == 12
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
                            days[index],
                            style: TextStyle(
                              color:
                                  dates[index] == 12
                                      ? Colors.white
                                      : (isDark ? Colors.white : Colors.black),
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dates[index].toString(),
                            style: TextStyle(
                              color:
                                  dates[index] == 12
                                      ? Colors.white
                                      : (isDark ? Colors.white : Colors.black),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // Live now section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.fiber_manual_record,
                      color: Colors.red,
                      size: 12,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Live Now',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: NetworkImage(
                        'https://via.placeholder.com/24',
                      ),
                    ),
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: NetworkImage(
                        'https://via.placeholder.com/24',
                      ),
                    ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '+24',
                          style: TextStyle(fontSize: 8, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Physics',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.fiber_manual_record,
                              color: Colors.red,
                              size: 10,
                            ),
                            SizedBox(width: 4),
                            Text('Active', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Text(
                      controller.liveClass['title']! as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          'https://via.placeholder.com/40',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(controller.liveClass['teacher']! as String),
                          Text(
                            controller.liveClass['time']! as String,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.joinClass,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text('Join Classroom'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Upcoming today
            const Text(
              'Upcoming Today',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Obx(
              () => Column(
                children:
                    controller.upcomingClasses.map((cls) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight,
                          ),
                        ),
                        child: Row(
                          children: [
                            Column(
                              children: [
                                Text(
                                  cls['time']!.split(' ')[0],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  cls['time']!.split(' ')[1],
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cls['subject']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${cls['teacher']} • ${cls['room']}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () {},
                              child: const Text('Join Soon'),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: const ParentBottomNavBar(
        currentIndex: 3,
      ), // Timetable, but live class is from timetable
    );
  }
}
