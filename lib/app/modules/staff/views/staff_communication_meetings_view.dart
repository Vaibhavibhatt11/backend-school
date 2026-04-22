import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/core/widgets/custom_app_bar.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_communication_controller.dart';
import 'package:erp_frontend/app/modules/staff/models/staff_communication_models.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffCommunicationMeetingsView extends StatefulWidget {
  const StaffCommunicationMeetingsView({super.key});

  @override
  State<StaffCommunicationMeetingsView> createState() =>
      _StaffCommunicationMeetingsViewState();
}

class _StaffCommunicationMeetingsViewState
    extends State<StaffCommunicationMeetingsView> {
  late final StaffCommunicationController controller;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    controller = Get.find<StaffCommunicationController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadRecipients(StaffMessageAudience.parent, showErrors: false);
      controller.loadRecipients(StaffMessageAudience.student, showErrors: false);
      controller.loadCommunication();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: CustomAppBar(
        title: 'Parent-Teacher Meetings',
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: controller.loadCommunication,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openScheduler,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_alert_rounded),
        label: const Text('Schedule PTM'),
      ),
      body: Obx(() {
        final items = controller.meetingResults(
          query: _searchController.text,
          filter: _selectedFilter,
        );
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meeting Planner',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Schedule meetings, send invitations, and keep a visible PTM timeline for staff follow-up.',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search parent, student, or purpose',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor:
                          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const ['ALL', 'UPCOMING', 'SCHEDULED', 'COMPLETED']
                        .map((filter) {
                      return _MeetingFilterChip._internal(filter);
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (items.isEmpty)
              _EmptyMeetingState(
                label: 'No meetings found for this filter.',
                onTap: _openScheduler,
              )
            else
              ...items.map((item) => _MeetingCard(item: item)),
          ],
        );
      }),
    );
  }

  Future<void> _openScheduler() async {
    if (controller.parentRecipients.isEmpty) {
      await controller.loadRecipients(
        StaffMessageAudience.parent,
        showErrors: true,
      );
    }
    if (controller.studentRecipients.isEmpty) {
      await controller.loadRecipients(
        StaffMessageAudience.student,
        showErrors: false,
      );
    }
    if (controller.parentRecipients.isEmpty) {
      AppToast.show('Parent contacts are not available yet.');
      return;
    }

    String? parentId = controller.parentRecipients.isEmpty
        ? null
        : controller.parentRecipients.first.id;
    String? studentId;
    final purposeController = TextEditingController();
    final locationController = TextEditingController();
    final noteController = TextEditingController();
    DateTime? selectedDateTime;
    String mode = 'In person';

    Future<void> pickDateTime(StateSetter setDialogState) async {
      final now = DateTime.now();
      final pickedDate = await showDatePicker(
        context: context,
        firstDate: DateTime(now.year, now.month, now.day),
        lastDate: DateTime(now.year + 2),
        initialDate: selectedDateTime ?? now,
      );
      if (pickedDate == null || !mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime ?? now),
      );
      if (pickedTime == null) return;
      setDialogState(() {
        selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }

    final confirmed = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Schedule Parent-Teacher Meeting'),
            content: SizedBox(
              width: 560,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: parentId,
                      decoration: const InputDecoration(labelText: 'Parent'),
                      items: controller.parentRecipients
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item.id,
                              child: Text(
                                item.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setDialogState(() => parentId = value),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String?>(
                      value: studentId,
                      decoration: const InputDecoration(
                        labelText: 'Student (optional)',
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('No linked student'),
                        ),
                        ...controller.studentRecipients.map(
                          (item) => DropdownMenuItem<String?>(
                            value: item.id,
                            child: Text(
                              item.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) => setDialogState(() => studentId = value),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: purposeController,
                      decoration: const InputDecoration(
                        labelText: 'Purpose',
                        hintText: 'Academic progress review',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: mode,
                      decoration: const InputDecoration(labelText: 'Mode'),
                      items: const ['In person', 'Phone call', 'Video call']
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setDialogState(() => mode = value ?? 'In person'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location or room',
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => pickDateTime(setDialogState),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          selectedDateTime == null
                              ? 'Select date and time'
                              : _dateTimeLabel(selectedDateTime!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Topics to cover during the meeting',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton.tonalIcon(
                        onPressed: () async {
                          final prompt = noteController.text.trim().isEmpty
                              ? 'Draft a short professional note for a parent-teacher meeting about ${purposeController.text.trim().isEmpty ? 'student progress' : purposeController.text.trim()}.'
                              : 'Improve this parent-teacher meeting note: ${noteController.text.trim()}';
                          final reply =
                              await controller.generateAiDraft(prompt: prompt);
                          if (reply == null || reply.isEmpty) return;
                          noteController.text = reply;
                        },
                        icon: const Icon(Icons.auto_awesome_rounded),
                        label: const Text('AI Note'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Schedule'),
              ),
            ],
          );
        },
      ),
    );

    if (confirmed != true || parentId == null || selectedDateTime == null) {
      return;
    }

    final parent = controller.findRecipient(
      StaffMessageAudience.parent,
      parentId!,
    );
    final student = studentId == null
        ? null
        : controller.findRecipient(StaffMessageAudience.student, studentId!);
    if (parent == null) {
      return;
    }

    await controller.scheduleMeeting(
      parent: parent,
      student: student,
      dateTime: selectedDateTime!,
      purpose: purposeController.text,
      mode: mode,
      location: locationController.text,
      note: noteController.text,
    );
  }

  String _dateTimeLabel(DateTime value) {
    final months = const [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = value.hour == 0
        ? 12
        : value.hour > 12
            ? value.hour - 12
            : value.hour;
    final suffix = value.hour >= 12 ? 'PM' : 'AM';
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.day} ${months[value.month - 1]} ${value.year} | $hour:$minute $suffix';
  }
}

class _MeetingFilterChip extends StatelessWidget {
  const _MeetingFilterChip._internal(this.filter);

  final String filter;

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<
        _StaffCommunicationMeetingsViewState>();
    final selected = state?._selectedFilter == filter;
    return ChoiceChip(
      label: Text(filter),
      selected: selected,
      onSelected: (_) {
        if (state == null) return;
        state.setState(() {
          state._selectedFilter = filter;
        });
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(color: selected ? Colors.white : null),
    );
  }
}

class _MeetingCard extends StatelessWidget {
  const _MeetingCard({required this.item});

  final StaffMeetingSchedule item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.status.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(item.dateTime),
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.purpose,
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MeetingPill(label: item.mode),
              if (item.location.trim().isNotEmpty)
                _MeetingPill(label: item.location.trim()),
              if (item.studentName.trim().isNotEmpty)
                _MeetingPill(label: item.studentName.trim()),
            ],
          ),
          if (item.note.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              item.note,
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatDate(DateTime value) {
    final months = const [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final local = value.toLocal();
    final hour = local.hour == 0
        ? 12
        : local.hour > 12
            ? local.hour - 12
            : local.hour;
    final suffix = local.hour >= 12 ? 'PM' : 'AM';
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.day} ${months[local.month - 1]} ${local.year} | $hour:$minute $suffix';
  }
}

class _MeetingPill extends StatelessWidget {
  const _MeetingPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyMeetingState extends StatelessWidget {
  const _EmptyMeetingState({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: onTap,
            child: const Text('Schedule now'),
          ),
        ],
      ),
    );
  }
}
