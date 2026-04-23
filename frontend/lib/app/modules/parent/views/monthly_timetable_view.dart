import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/monthly_timetable_controller.dart';

class MonthlyTimetableView extends GetView<MonthlyTimetableController> {
  const MonthlyTimetableView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: CustomAppBar(title: 'Monthly Timetable', showBack: true),
      body: Obx(() {
        final month = controller.selectedMonth.value;
        final first = DateTime(month.year, month.month, 1);
        final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
        final startWeekday = first.weekday;
        final selected = controller.selectedDate.value;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => controller.changeMonth(DateTime(month.year, month.month - 1)),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Text(
                      '${month.year}-${month.month.toString().padLeft(2, '0')}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => controller.changeMonth(DateTime(month.year, month.month + 1)),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: startWeekday - 1 + daysInMonth,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (_, index) {
                  if (index < startWeekday - 1) return const SizedBox.shrink();
                  final day = index - (startWeekday - 1) + 1;
                  final isSelected =
                      selected.year == month.year && selected.month == month.month && selected.day == day;
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => controller.selectDate(DateTime(month.year, month.month, day)),
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : (isDark ? AppColors.surfaceDark : Colors.white),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.borderLight),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$day',
                          style: TextStyle(
                            color: isSelected ? Colors.white : null,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : controller.errorMessage.value.isNotEmpty
                      ? Center(child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(controller.errorMessage.value, textAlign: TextAlign.center),
                        ))
                      : controller.dayItems.isEmpty
                          ? const Center(child: Text('No classes for selected date.'))
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: controller.dayItems.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (_, i) {
                                final item = controller.dayItems[i];
                                return Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.surfaceDark : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text((item['subject'] ?? '').toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 6),
                                      Text('Time: ${(item['time'] ?? '-').toString()}'),
                                      Text('Teacher: ${(item['teacher'] ?? '-').toString()}'),
                                      Text('Room: ${(item['room'] ?? '-').toString()}'),
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
