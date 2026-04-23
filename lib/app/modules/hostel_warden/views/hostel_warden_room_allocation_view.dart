import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/hostel_warden/controllers/hostel_warden_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HostelWardenRoomAllocationView extends GetView<HostelWardenController> {
  const HostelWardenRoomAllocationView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Room Allocation'),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => controller.operations.openRoomDialog(),
                  icon: const Icon(Icons.meeting_room_rounded),
                  label: const Text('Add Room'),
                ),
                OutlinedButton.icon(
                  onPressed: () =>
                      controller.operations.openHostelAllocationDialog(),
                  icon: const Icon(Icons.bed_rounded),
                  label: const Text('Allocate Student'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _Title(text: 'Rooms'),
            const SizedBox(height: 10),
            Obx(
              () => Column(
                children: controller.operations.hostelRooms
                    .map(
                      (item) => _Card(
                        title: item.label,
                        subtitle: 'Capacity: ${item.capacity}',
                        isDark: isDark,
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            const _Title(text: 'Allocations'),
            const SizedBox(height: 10),
            Obx(
              () => Column(
                children: controller.operations.hostelAllocations
                    .map(
                      (item) => _Card(
                        title: item.studentLabel,
                        subtitle: item.roomLabel,
                        isDark: isDark,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.w700));
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.title,
    required this.subtitle,
    required this.isDark,
  });
  final String title;
  final String subtitle;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(subtitle),
        ],
      ),
    );
  }
}
