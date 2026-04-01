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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      initialIndex: initialTab,
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('Operations'),
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          bottom: TabBar(
            onTap: (value) => controller.changeTab(value),
            tabs: const [
              Tab(text: 'Transport'),
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
          children: [
            _TransportTab(controller: controller),
            _HostelTab(controller: controller),
            _EventsTab(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _TransportTab extends StatelessWidget {
  const _TransportTab({required this.controller});

  final AdminOperationsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value &&
          controller.transportRoutes.isEmpty &&
          controller.transportAllocations.isEmpty &&
          controller.transportDrivers.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.errorMessage.value.isNotEmpty &&
          controller.transportRoutes.isEmpty &&
          controller.transportAllocations.isEmpty &&
          controller.transportDrivers.isEmpty) {
        return _OpsError(
          message: controller.errorMessage.value,
          onRetry: controller.refreshCurrentTab,
        );
      }
      return RefreshIndicator(
        onRefresh: controller.refreshCurrentTab,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _OpsChip(
                  label: 'Routes',
                  value: '${controller.transportRoutes.length}',
                ),
                _OpsChip(
                  label: 'Drivers',
                  value: '${controller.transportDrivers.length}',
                ),
                _OpsChip(
                  label: 'Allocations',
                  value: '${controller.transportAllocations.length}',
                ),
                FilledButton.icon(
                  onPressed: () => controller.openRouteDialog(),
                  icon: const Icon(Icons.route_rounded),
                  label: const Text('Add Route'),
                ),
                OutlinedButton.icon(
                  onPressed: controller.openDriverDialog,
                  icon: const Icon(Icons.drive_eta_rounded),
                  label: const Text('Add Driver'),
                ),
                OutlinedButton.icon(
                  onPressed: () => controller.openTransportAllocationDialog(),
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: const Text('Allocate'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const _OpsTitle(title: 'Routes'),
            const SizedBox(height: 12),
            ...controller.transportRoutes.map(
              (item) => _OpsCard(
                title: item.name,
                subtitle: item.routeCode,
                details: ['Status: ${item.isActive ? 'ACTIVE' : 'INACTIVE'}'],
                actions: [
                  OutlinedButton(
                    onPressed: () => controller.openRouteDialog(existing: item),
                    child: const Text('Edit'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => controller.deleteRoute(item),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const _OpsTitle(title: 'Drivers'),
            const SizedBox(height: 12),
            ...controller.transportDrivers.map(
              (item) => _OpsCard(
                title: item.fullName,
                subtitle: item.licenseNo,
                details: [
                  if (item.phone.isNotEmpty) 'Phone: ${item.phone}',
                  'Status: ${item.isActive ? 'ACTIVE' : 'INACTIVE'}',
                ],
                actions: const [],
              ),
            ),
            const SizedBox(height: 18),
            const _OpsTitle(title: 'Allocations'),
            const SizedBox(height: 12),
            ...controller.transportAllocations.map(
              (item) => _OpsCard(
                title: item.studentLabel,
                subtitle: item.routeLabel,
                details: [
                  if (item.stopName.isNotEmpty) 'Stop: ${item.stopName}',
                  if (item.feeAmount != null) 'Fee: ${item.feeAmount}',
                ],
                actions: [
                  OutlinedButton(
                    onPressed: () => controller.openTransportAllocationDialog(
                      existing: item,
                    ),
                    child: const Text('Edit'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => controller.deleteTransportAllocation(item),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _HostelTab extends StatelessWidget {
  const _HostelTab({required this.controller});

  final AdminOperationsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
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
      return RefreshIndicator(
        onRefresh: controller.refreshCurrentTab,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _OpsChip(
                  label: 'Rooms',
                  value: '${controller.hostelRooms.length}',
                ),
                _OpsChip(
                  label: 'Allocations',
                  value: '${controller.hostelAllocations.length}',
                ),
                _OpsChip(
                  label: 'Visitors',
                  value: '${controller.hostelVisitors.length}',
                ),
                FilledButton.icon(
                  onPressed: () => controller.openRoomDialog(),
                  icon: const Icon(Icons.meeting_room_rounded),
                  label: const Text('Add Room'),
                ),
                OutlinedButton.icon(
                  onPressed: controller.openHostelAllocationDialog,
                  icon: const Icon(Icons.bed_rounded),
                  label: const Text('Allocate'),
                ),
                OutlinedButton.icon(
                  onPressed: controller.markHostelAttendance,
                  icon: const Icon(Icons.fact_check_rounded),
                  label: const Text('Attendance'),
                ),
                OutlinedButton.icon(
                  onPressed: controller.openVisitorDialog,
                  icon: const Icon(Icons.how_to_reg_rounded),
                  label: const Text('Visitor'),
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
            const _OpsTitle(title: 'Allocations'),
            const SizedBox(height: 12),
            ...controller.hostelAllocations.map(
              (item) => _OpsCard(
                title: item.studentLabel,
                subtitle: item.roomLabel,
                details: [
                  'From: ${_opsDate(item.fromDate)}',
                  if (item.toDate != null) 'To: ${_opsDate(item.toDate)}',
                ],
                actions: const [],
              ),
            ),
            const SizedBox(height: 18),
            const _OpsTitle(title: 'Attendance & Visitors'),
            const SizedBox(height: 12),
            ...controller.hostelAttendance.map(
              (item) => _OpsCard(
                title: item.studentId,
                subtitle: item.status,
                details: [if (item.remark.isNotEmpty) item.remark],
                actions: const [],
              ),
            ),
            ...controller.hostelVisitors.map(
              (item) => _OpsCard(
                title: item.visitorName,
                subtitle: _opsDate(item.inTime),
                details: [
                  if (item.studentId.isNotEmpty) 'Student: ${item.studentId}',
                  if (item.purpose.isNotEmpty) 'Purpose: ${item.purpose}',
                ],
                actions: const [],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _EventsTab extends StatelessWidget {
  const _EventsTab({required this.controller});

  final AdminOperationsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
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
            const SizedBox(height: 18),
            ...controller.events.map(
              (item) => _OpsCard(
                title: item.title,
                subtitle: '${item.eventType} | ${_opsDate(item.startDate)}',
                details: [
                  if (item.location.isNotEmpty) 'Location: ${item.location}',
                  'Registrations: ${item.registrationsCount}',
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
                  OutlinedButton(
                    onPressed: () => controller.registerForEvent(item),
                    child: const Text('Register'),
                  ),
                  OutlinedButton(
                    onPressed: () => controller.addEventGallery(item),
                    child: const Text('Gallery'),
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
    });
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
  if (value > 2) return 2;
  return value;
}
