import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/exam_timetable_controller.dart';

class ExamTimetableView extends GetView<ExamTimetableController> {
  const ExamTimetableView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: CustomAppBar(title: 'Exam Timetable', showBack: true),
      body: Obx(() {
        final m = controller.month.value;
        final monthLabel = '${m.year}-${m.month.toString().padLeft(2, '0')}';
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Row(
                children: [
                  IconButton(onPressed: () => controller.shiftMonth(-1), icon: const Icon(Icons.chevron_left)),
                  Expanded(
                    child: Text(monthLabel, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  IconButton(onPressed: () => controller.shiftMonth(1), icon: const Icon(Icons.chevron_right)),
                ],
              ),
            ),
            Expanded(
              child: controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : controller.errorMessage.value.isNotEmpty
                      ? Center(child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(controller.errorMessage.value, textAlign: TextAlign.center),
                        ))
                      : controller.exams.isEmpty
                          ? const Center(child: Text('No exam timetable available.'))
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: controller.exams.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (_, i) {
                                final e = controller.exams[i];
                                return Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.surfaceDark : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text((e['subject'] ?? e['title'] ?? 'Exam').toString(),
                                          style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 6),
                                      Text('Date: ${(e['date'] ?? e['examDate'] ?? '-').toString()}'),
                                      Text('Time: ${(e['time'] ?? e['startTime'] ?? '-').toString()}'),
                                      Text('Room: ${(e['room'] ?? e['location'] ?? '-').toString()}'),
                                    ],
                                  ),
                                );
                              },
                            ),
            ),
          ],
        );
      }),
    );
  }
}
