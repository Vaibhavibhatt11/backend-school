import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../navbar/parent_bottom_nav_bar.dart';
import '../controllers/announcements_controller.dart';

class SchoolAnnouncementsView extends GetView<AnnouncementsController> {
  const SchoolAnnouncementsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Announcements',
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.tune), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:
                    ['All', 'School', 'Class 4B', 'Sports']
                        .map(
                          (filter) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Obx(
                              () => ChoiceChip(
                                label: Text(filter),
                                selected:
                                    controller.selectedFilter.value == filter,
                                onSelected: (selected) {
                                  if (selected) controller.setFilter(filter);
                                },
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color:
                                      controller.selectedFilter.value == filter
                                          ? Colors.white
                                          : null,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
            const SizedBox(height: 20),
            // Announcements list
            Obx(
              () => Column(
                children:
                    controller.announcements.map((ann) {
                      if (ann['type'] == 'urgent') {
                        return _buildUrgentCard(ann);
                      } else if (ann['type'] == 'teacher') {
                        return _buildTeacherCard(ann);
                      } else {
                        return _buildGeneralCard(ann);
                      }
                    }).toList(),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: const ParentBottomNavBar(
        currentIndex: 0,
      ), // Announcements from home
    );
  }

  Widget _buildUrgentCard(Map<String, dynamic> ann) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ann['title']!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Posted ${ann['time']} by ${ann['postedBy']}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(ann['description']!),
        ],
      ),
    );
  }

  Widget _buildTeacherCard(Map<String, dynamic> ann) {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage('https://via.placeholder.com/40'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ann['teacherName']!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${ann['teacherClass']} • ${ann['time']}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ann['title']!,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(ann['description']!),
          if (ann['attachment'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.description, size: 16),
                  const SizedBox(width: 4),
                  Text(ann['attachment']!),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGeneralCard(Map<String, dynamic> ann) {
    // Similar to teacher but without image
    return Container();
  }
}
