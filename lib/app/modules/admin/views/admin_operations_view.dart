import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_operations_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminOperationsView extends GetView<AdminOperationsController> {
  const AdminOperationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = (Get.arguments as Map?)?.cast<String, dynamic>() ?? const {};
    final initialTab = _opsInitialTab(args);
    final scope = (args['scope']?.toString() ?? '').toLowerCase();
    final isHostelOnly = scope == 'hostel';
    final isEventsOnly = scope == 'events';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tabCount = (isHostelOnly || isEventsOnly) ? 1 : 2;
    final mappedInitialIndex = tabCount == 1 ? 0 : initialTab;

    return DefaultTabController(
      length: tabCount,
      initialIndex: mappedInitialIndex,
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('Operations'),
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          bottom: tabCount == 1
              ? null
              : TabBar(
                  onTap: (value) => controller.changeTab(value),
                  tabs: const [
                    Tab(text: 'Hostel'),
                    Tab(text: 'Events'),
                  ],
                ),
          actions: [
            IconButton(
              onPressed: controller.refreshCurrentTab,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: TabBarView(
          children: isHostelOnly
              ? [_HostelTab(controller: controller)]
              : isEventsOnly
              ? [_EventsTab(controller: controller)]
              : [
                  _HostelTab(controller: controller),
                  _EventsTab(controller: controller),
                ],
        ),
      ),
    );
  }
}

class _HostelTab extends StatelessWidget {
  const _HostelTab({required this.controller});

  final AdminOperationsController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: TabBar(
              isScrollable: true,
              indicator: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              dividerColor: Colors.transparent,
              labelColor: AppColors.primary,
              unselectedLabelColor: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              tabs: const [
                Tab(text: 'Room Allocation'),
                Tab(text: 'Hostel Attendance'),
                Tab(text: 'Visitor Logs'),
                Tab(text: 'Hostel Fee'),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.hostelRooms.isEmpty &&
                  controller.hostelAllocations.isEmpty &&
                  controller.hostelVisitors.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.errorMessage.value.isNotEmpty &&
                  controller.hostelRooms.isEmpty &&
                  controller.hostelAllocations.isEmpty &&
                  controller.hostelVisitors.isEmpty) {
                return _OpsError(
                  message: controller.errorMessage.value,
                  onRetry: controller.refreshCurrentTab,
                );
              }
              return TabBarView(
                children: [
                  _HostelRoomAllocationTab(controller: controller),
                  _HostelAttendanceTab(controller: controller),
                  _HostelVisitorsTab(controller: controller),
                  _HostelFeesTab(controller: controller),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _HostelRoomAllocationTab extends StatelessWidget {
  const _HostelRoomAllocationTab({required this.controller});

  final AdminOperationsController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _OpsChip(label: 'Rooms', value: '${controller.hostelRooms.length}'),
            _OpsChip(
              label: 'Allocations',
              value: '${controller.hostelAllocations.length}',
            ),
            FilledButton.icon(
              onPressed: () => controller.openRoomDialog(),
              icon: const Icon(Icons.meeting_room_rounded),
              label: const Text('Add Room'),
            ),
            OutlinedButton.icon(
              onPressed: () => controller.openHostelAllocationDialog(),
              icon: const Icon(Icons.bed_rounded),
              label: const Text('Allocate'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const _OpsTitle(title: 'Rooms'),
        const SizedBox(height: 12),
        ...controller.hostelRooms.map(
          (item) => _OpsCard(
            title: item.label,
            subtitle: 'Capacity ${item.capacity}',
            details: ['Status: ${item.isActive ? 'ACTIVE' : 'INACTIVE'}'],
            actions: [
              OutlinedButton(
                onPressed: () => controller.openRoomDialog(existing: item),
                child: const Text('Edit'),
              ),
              FilledButton.tonal(
                onPressed: () => controller.deleteRoom(item),
                child: const Text('Delete'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const _OpsTitle(title: 'Student Allocation Workflow'),
        const SizedBox(height: 12),
        ...controller.hostelAllocations.map(
          (item) => _OpsCard(
            title: item.studentLabel,
            subtitle: item.roomLabel,
            details: [
              'From: ${_opsDate(item.fromDate)}',
              if (item.toDate != null) 'To: ${_opsDate(item.toDate)}',
              'Status: ${controller.allocationStatus(item)}',
            ],
            actions: [
              OutlinedButton(
                onPressed: () =>
                    controller.openHostelAllocationDialog(existing: item),
                child: const Text('Reassign'),
              ),
              OutlinedButton(
                onPressed: () =>
                    controller.setHostelAllocationStatus(item, 'VACATED'),
                child: const Text('Vacate'),
              ),
              OutlinedButton(
                onPressed: () =>
                    controller.setHostelAllocationStatus(item, 'ACTIVE'),
                child: const Text('Activate'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HostelAttendanceTab extends StatelessWidget {
  const _HostelAttendanceTab({required this.controller});
  final AdminOperationsController controller;

  @override
  Widget build(BuildContext context) {
    final dateController = TextEditingController(
      text: controller.hostelAttendanceDate.value,
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _OpsChip(
              label: 'Entries',
              value: '${controller.hostelAttendance.length}',
            ),
            FilledButton.icon(
              onPressed: controller.markHostelAttendance,
              icon: const Icon(Icons.fact_check_rounded),
              label: const Text('Mark Attendance'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: dateController,
          decoration: const InputDecoration(
            labelText: 'Filter date',
            helperText: 'YYYY-MM-DD',
          ),
          onSubmitted: controller.setHostelAttendanceDate,
        ),
        const SizedBox(height: 12),
        ...controller.hostelAttendance.map(
          (item) => _OpsCard(
            title: item.studentId,
            subtitle: item.status,
            details: [
              'Date: ${_opsDate(item.date)}',
              if (item.remark.isNotEmpty) item.remark,
            ],
            actions: const [],
          ),
        ),
      ],
    );
  }
}

class _HostelVisitorsTab extends StatelessWidget {
  const _HostelVisitorsTab({required this.controller});
  final AdminOperationsController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _OpsChip(
              label: 'Visitors',
              value: '${controller.hostelVisitors.length}',
            ),
            FilledButton.icon(
              onPressed: controller.openVisitorDialog,
              icon: const Icon(Icons.how_to_reg_rounded),
              label: const Text('Add Visitor'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...controller.hostelVisitors.map(
          (item) => _OpsCard(
            title: item.visitorName,
            subtitle: _opsDate(item.inTime),
            details: [
              if (item.studentId.isNotEmpty) 'Student: ${item.studentId}',
              if (item.purpose.isNotEmpty) 'Purpose: ${item.purpose}',
              'In: ${_opsDate(item.inTime)}',
              'Out: ${controller.hostelVisitorCheckoutById[item.id] ?? _opsDate(item.outTime)}',
            ],
            actions: [
              if ((controller.hostelVisitorCheckoutById[item.id] ?? '')
                      .isEmpty &&
                  item.outTime == null)
                OutlinedButton(
                  onPressed: () => controller.markVisitorCheckout(item),
                  child: const Text('Checkout'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HostelFeesTab extends StatelessWidget {
  const _HostelFeesTab({required this.controller});
  final AdminOperationsController controller;

  @override
  Widget build(BuildContext context) {
    final pendingCount = controller.hostelFeePayments
        .where((item) => item.status == 'PENDING')
        .length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _OpsChip(
              label: 'Fee Structures',
              value: '${controller.hostelFeeStructures.length}',
            ),
            _OpsChip(label: 'Pending', value: '$pendingCount'),
            FilledButton.icon(
              onPressed: () => controller.openHostelFeeStructureDialog(),
              icon: const Icon(Icons.request_quote_rounded),
              label: const Text('Add Fee'),
            ),
            OutlinedButton.icon(
              onPressed: controller.recordHostelFeePayment,
              icon: const Icon(Icons.receipt_long_rounded),
              label: const Text('Record Payment'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _OpsTitle(title: 'Fee Structure'),
        const SizedBox(height: 12),
        if (controller.hostelFeeStructures.isEmpty)
          const _OpsCard(
            title: 'No fee structures',
            subtitle: '',
            details: ['Add hostel fee setup to start fee lifecycle.'],
            actions: [],
          )
        else
          ...controller.hostelFeeStructures.map(
            (item) => _OpsCard(
              title: item.name,
              subtitle: '${item.frequency} | Due Day ${item.dueDay}',
              details: [
                'Amount: ${item.amount.toStringAsFixed(2)}',
                'Status: ${item.isActive ? 'ACTIVE' : 'INACTIVE'}',
              ],
              actions: [
                OutlinedButton(
                  onPressed: () =>
                      controller.openHostelFeeStructureDialog(existing: item),
                  child: const Text('Edit'),
                ),
                FilledButton.tonal(
                  onPressed: () => controller.deleteHostelFeeStructure(item),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        const _OpsTitle(title: 'Payment Records'),
        const SizedBox(height: 12),
        ...controller.hostelFeePayments.map(
          (item) => _OpsCard(
            title: item.studentLabel,
            subtitle: item.structureLabel,
            details: [
              'Amount: ${item.amount.toStringAsFixed(2)}',
              'Paid on: ${item.paidOn}',
              'Status: ${item.status}',
            ],
            actions: const [],
          ),
        ),
      ],
    );
  }
}

class _EventsTab extends StatelessWidget {
  const _EventsTab({required this.controller});

  final AdminOperationsController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: TabBar(
              isScrollable: true,
              indicator: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              dividerColor: Colors.transparent,
              labelColor: AppColors.primary,
              unselectedLabelColor: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              tabs: const [
                Tab(text: 'Event Calendar'),
                Tab(text: 'Registrations'),
                Tab(text: 'Competitions'),
                Tab(text: 'Photo Gallery'),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.events.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.errorMessage.value.isNotEmpty &&
                  controller.events.isEmpty) {
                return _OpsError(
                  message: controller.errorMessage.value,
                  onRetry: controller.refreshCurrentTab,
                );
              }
              return TabBarView(
                children: [
                  _EventsCalendarTab(controller: controller),
                  _EventRegistrationsTab(controller: controller),
                  _CompetitionsTab(controller: controller),
                  _EventGalleryTab(controller: controller),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _EventsCalendarTab extends StatelessWidget {
  const _EventsCalendarTab({required this.controller});
  final AdminOperationsController controller;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshCurrentTab,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _OpsChip(label: 'Events', value: '${controller.events.length}'),
              FilledButton.icon(
                onPressed: () => controller.openEventDialog(),
                icon: const Icon(Icons.event_available_rounded),
                label: const Text('Create Event'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...controller.events.map(
            (item) => _OpsCard(
              title: item.title,
              subtitle: '${item.eventType} | ${_opsDate(item.startDate)}',
              details: [
                if (item.endDate != null) 'End: ${_opsDate(item.endDate)}',
                if (item.location.isNotEmpty) 'Location: ${item.location}',
                'Published: ${item.isPublished ? 'YES' : 'NO'}',
              ],
              actions: [
                OutlinedButton(
                  onPressed: () => controller.openEventDetails(item),
                  child: const Text('View'),
                ),
                OutlinedButton(
                  onPressed: () => controller.openEventDialog(existing: item),
                  child: const Text('Edit'),
                ),
                FilledButton.tonal(
                  onPressed: () => controller.deleteEvent(item),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventRegistrationsTab extends StatelessWidget {
  const _EventRegistrationsTab({required this.controller});
  final AdminOperationsController controller;

  @override
  Widget build(BuildContext context) {
    final selected = controller.selectedEventId.value;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        DropdownButtonFormField<String>(
          value: selected.isEmpty ? null : selected,
          decoration: const InputDecoration(labelText: 'Select event'),
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
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _OpsChip(
              label: 'Registrations',
              value: '${controller.eventRegistrations.length}',
            ),
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
              icon: const Icon(Icons.how_to_reg_rounded),
              label: const Text('Register Participant'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (controller.eventRegistrations.isEmpty)
          const _OpsCard(
            title: 'No registrations',
            subtitle: '',
            details: ['Registrations will appear for selected event.'],
            actions: [],
          )
        else
          ...controller.eventRegistrations.map(
            (item) => _OpsCard(
              title: item.participantLabel,
              subtitle: item.email,
              details: [
                'Created: ${item.createdAt.isEmpty ? '-' : item.createdAt}',
              ],
              actions: const [],
            ),
          ),
      ],
    );
  }
}

class _CompetitionsTab extends StatelessWidget {
  const _CompetitionsTab({required this.controller});
  final AdminOperationsController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _OpsChip(
              label: 'Competitions',
              value: '${controller.competitions.length}',
            ),
            FilledButton.icon(
              onPressed: () => controller.openCompetitionDialog(),
              icon: const Icon(Icons.emoji_events_rounded),
              label: const Text('Add Competition'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (controller.competitions.isEmpty)
          const _OpsCard(
            title: 'No competitions',
            subtitle: '',
            details: ['Create competitions linked to events.'],
            actions: [],
          )
        else
          ...controller.competitions.map(
            (item) => _OpsCard(
              title: item.title,
              subtitle: '${item.category} | ${item.eventTitle}',
              details: [
                'Status: ${item.status}',
                'Participants: ${item.participantsCount}',
              ],
              actions: [
                OutlinedButton(
                  onPressed: () =>
                      controller.openCompetitionDialog(existing: item),
                  child: const Text('Edit'),
                ),
                FilledButton.tonal(
                  onPressed: () => controller.deleteCompetition(item),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _EventGalleryTab extends StatelessWidget {
  const _EventGalleryTab({required this.controller});
  final AdminOperationsController controller;

  @override
  Widget build(BuildContext context) {
    final selected = controller.selectedEventId.value;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        DropdownButtonFormField<String>(
          value: selected.isEmpty ? null : selected,
          decoration: const InputDecoration(labelText: 'Select event'),
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
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _OpsChip(
              label: 'Photos',
              value: '${controller.eventGallery.length}',
            ),
            FilledButton.icon(
              onPressed: selected.isEmpty
                  ? null
                  : () {
                      final event = controller.events.firstWhereOrNull(
                        (e) => e.id == selected,
                      );
                      if (event != null) {
                        controller.addEventGallery(event);
                      }
                    },
              icon: const Icon(Icons.photo_library_rounded),
              label: const Text('Add Photo'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (controller.eventGallery.isEmpty)
          const _OpsCard(
            title: 'No gallery items',
            subtitle: '',
            details: ['Add photos to selected event gallery.'],
            actions: [],
          )
        else
          ...controller.eventGallery.map(
            (item) => _OpsCard(
              title: item.caption.isEmpty ? 'Photo' : item.caption,
              subtitle: item.url,
              details: [
                'Uploaded: ${item.createdAt.isEmpty ? '-' : item.createdAt}',
              ],
              actions: const [],
            ),
          ),
      ],
    );
  }
}

class _OpsCard extends StatelessWidget {
  const _OpsCard({
    required this.title,
    required this.subtitle,
    required this.details,
    required this.actions,
  });

  final String title;
  final String subtitle;
  final List<String> details;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
          const SizedBox(height: 12),
          ...details.map(
            (detail) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(detail),
            ),
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(spacing: 8, runSpacing: 8, children: actions),
          ],
        ],
      ),
    );
  }
}

class _OpsTitle extends StatelessWidget {
  const _OpsTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }
}

class _OpsChip extends StatelessWidget {
  const _OpsChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textDark : AppColors.textLight,
        ),
      ),
    );
  }
}

class _OpsError extends StatelessWidget {
  const _OpsError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => onRetry(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

String _opsDate(DateTime? value) {
  if (value == null) return '-';
  return value.toIso8601String().substring(0, 10);
}

int _opsInitialTab(Map<String, dynamic> args) {
  final value = (args['initialTab'] as num?)?.toInt() ?? 0;
  if (value < 0) return 0;
  if (value > 1) return 1;
  return value;
}
