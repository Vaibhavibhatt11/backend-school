import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_communication_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffCommunicationView extends GetView<StaffCommunicationController> {
  const StaffCommunicationView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Obx(() {
        if (controller.isLoading.value && controller.chats.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Communication Center + AI',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text('Message parents/students, post announcements, and save meeting notes in one flow.'),
          ),
          const SizedBox(height: 12),
          _card(
            isDark,
            'Chats',
            Obx(
              () => Column(
                children: controller.chats
                    .map((c) => ListTile(
                          title: Text(c['to'] ?? ''),
                          subtitle: Text(c['last'] ?? ''),
                          trailing: const Icon(Icons.chevron_right_rounded),
                        ))
                    .toList(),
              ),
            ),
          ),
          _card(
            isDark,
            'Announcements',
            Obx(
              () => Column(
                children: controller.announcements.map((a) => ListTile(title: Text(a))).toList(),
              ),
            ),
          ),
          _card(
            isDark,
            'Meetings & Notes',
            Obx(
              () => Column(
                children: controller.meetings
                    .map((m) => ListTile(
                          title: Text(m['title'] ?? ''),
                          subtitle: Text(m['time'] ?? ''),
                        ))
                    .toList(),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(child: ElevatedButton(onPressed: controller.sendMessage, child: const Text('Send Message'))),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton(onPressed: controller.addMeetingNote, child: const Text('Save Note'))),
            ],
          ),
        ],
      );
      }),
    );
  }

  Widget _card(bool isDark, String title, Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 8), child],
      ),
    );
  }
}

