import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/core/widgets/custom_app_bar.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_events_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AdminEventsRegistrationsView extends GetView<AdminEventsController> {
  const AdminEventsRegistrationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: const CustomAppBar(title: 'Event Registrations'),
      body: Obx(() {
        if (controller.isLoading.value && controller.events.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final selected = controller.selectedEventId.value;

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: selected.isEmpty ? null : selected,
                      decoration: InputDecoration(
                        labelText: 'Select an Event',
                        filled: true,
                        fillColor: isDark
                            ? AppColors.backgroundDark
                            : AppColors.backgroundLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: controller.events
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item.id,
                              child: Text(item.title),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null && value.isNotEmpty) {
                          controller.loadEventInsights(value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    onPressed: selected.isEmpty
                        ? null
                        : () {
                            final event = controller.events.firstWhereOrNull(
                              (e) => e.id == selected,
                            );
                            if (event != null) {
                              controller.registerForEvent(event);
                            }
                          },
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    label: const Text('Register Participant'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.loadEventInsights(selected),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    if (controller.eventRegistrations.isEmpty)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 60),
                            Icon(
                              Icons.how_to_reg_rounded,
                              size: 64,
                              color: AppColors.primary.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No registrations found for this event.',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.eventRegistrations.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final reg = controller.eventRegistrations[index];
                            final formattedDate = reg.createdAt.isNotEmpty
                                ? DateFormat('MMM dd, yyyy - hh:mm a').format(
                                    DateTime.tryParse(reg.createdAt) ??
                                        DateTime.now(),
                                  )
                                : 'Unknown';
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary.withValues(
                                  alpha: 0.1,
                                ),
                                child: Text(
                                  reg.participantLabel.isNotEmpty
                                      ? reg.participantLabel[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                reg.participantLabel,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(reg.email),
                              trailing: Text(
                                formattedDate,
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
