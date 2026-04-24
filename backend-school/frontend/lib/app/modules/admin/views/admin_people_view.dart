import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_people_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminPeopleView extends GetView<AdminPeopleController> {
  const AdminPeopleView({super.key});

  @override
  Widget build(BuildContext context) {
    final rawArgs = Get.arguments as Map?;
    final args = rawArgs?.cast<String, dynamic>() ?? const {};
    final initialTab = _tabFromArgs(args);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      initialIndex: initialTab,
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('People Center'),
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Parents'),
              Tab(text: 'Staff'),
            ],
          ),
          actions: [
            IconButton(
              onPressed: controller.loadInitialData,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _ParentsTab(controller: controller),
            _StaffTab(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _ParentsTab extends StatelessWidget {
  const _ParentsTab({required this.controller});

  final AdminPeopleController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isParentsLoading.value && controller.parents.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.parentsError.value.isNotEmpty &&
          controller.parents.isEmpty) {
        return _ErrorState(
          message: controller.parentsError.value,
          onRetry: () => controller.loadParents(),
        );
      }
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                TextField(
                  controller: controller.parentSearchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search parents by name, email, or phone',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: IconButton(
                      onPressed: () => controller.searchParents(
                        controller.parentSearchController.text,
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded),
                    ),
                  ),
                  onSubmitted: controller.searchParents,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SummaryChip(
                      label: 'Parents',
                      value: '${controller.parentsTotalItems.value}',
                    ),
                    _SummaryChip(
                      label: 'Students',
                      value: '${controller.studentOptions.length}',
                    ),
                    FilledButton.icon(
                      onPressed: controller.inviteParent,
                      icon: const Icon(Icons.mark_email_unread_rounded),
                      label: const Text('Invite Parent'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => controller.openParentDialog(),
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      label: const Text('Add Parent'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.loadInitialData,
              child: controller.parents.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: const [
                        _EmptyState(
                          icon: Icons.family_restroom_rounded,
                          title: 'No parents found',
                          message:
                              'Parent records and invitations will appear here with live data.',
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: controller.parents.length + 1,
                      itemBuilder: (context, index) {
                        if (index == controller.parents.length) {
                          return _PaginationBar(
                            page: controller.parentsPage.value,
                            totalPages: controller.parentsTotalPages.value,
                            onPrevious: controller.parentsPage.value > 1
                                ? () => controller.loadParents(
                                    nextPage: controller.parentsPage.value - 1,
                                  )
                                : null,
                            onNext:
                                controller.parentsPage.value <
                                    controller.parentsTotalPages.value
                                ? () => controller.loadParents(
                                    nextPage: controller.parentsPage.value + 1,
                                  )
                                : null,
                          );
                        }
                        final item = controller.parents[index];
                        return _ParentCard(item: item, controller: controller);
                      },
                    ),
            ),
          ),
        ],
      );
    });
  }
}

class _StaffTab extends StatelessWidget {
  const _StaffTab({required this.controller});

  final AdminPeopleController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isStaffLoading.value && controller.staffMembers.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.staffError.value.isNotEmpty &&
          controller.staffMembers.isEmpty) {
        return _ErrorState(
          message: controller.staffError.value,
          onRetry: () => controller.loadStaff(),
        );
      }
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                TextField(
                  controller: controller.staffSearchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search staff by code, name, or email',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: IconButton(
                      onPressed: () => controller.searchStaff(
                        controller.staffSearchController.text,
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded),
                    ),
                  ),
                  onSubmitted: controller.searchStaff,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SummaryChip(
                      label: 'Staff',
                      value: '${controller.staffTotalItems.value}',
                    ),
                    FilledButton.icon(
                      onPressed: () => controller.openStaffDialog(),
                      icon: const Icon(Icons.badge_rounded),
                      label: const Text('Add Staff'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.loadInitialData,
              child: controller.staffMembers.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: const [
                        _EmptyState(
                          icon: Icons.groups_rounded,
                          title: 'No staff found',
                          message:
                              'Teacher and staff records will appear here with live data.',
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: controller.staffMembers.length + 1,
                      itemBuilder: (context, index) {
                        if (index == controller.staffMembers.length) {
                          return _PaginationBar(
                            page: controller.staffPage.value,
                            totalPages: controller.staffTotalPages.value,
                            onPrevious: controller.staffPage.value > 1
                                ? () => controller.loadStaff(
                                    nextPage: controller.staffPage.value - 1,
                                  )
                                : null,
                            onNext:
                                controller.staffPage.value <
                                    controller.staffTotalPages.value
                                ? () => controller.loadStaff(
                                    nextPage: controller.staffPage.value + 1,
                                  )
                                : null,
                          );
                        }
                        final item = controller.staffMembers[index];
                        return _StaffCard(item: item, controller: controller);
                      },
                    ),
            ),
          ),
        ],
      );
    });
  }
}

class _ParentCard extends StatelessWidget {
  const _ParentCard({required this.item, required this.controller});

  final AdminParentRecord item;
  final AdminPeopleController controller;

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.fullName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.textDark
                            : AppColors.textLight,
                      ),
                    ),
                    if (item.email.isNotEmpty) const SizedBox(height: 4),
                    if (item.email.isNotEmpty)
                      Text(
                        item.email,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                  ],
                ),
              ),
              _StatusChip(
                label: item.isActive ? 'ACTIVE' : 'INACTIVE',
                active: item.isActive,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (item.phone.isNotEmpty)
                _MetaText(label: 'Phone', value: item.phone),
              _MetaText(
                label: 'Linked Students',
                value: '${item.studentsCount}',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => controller.openParentDetails(item),
                child: const Text('View'),
              ),
              OutlinedButton(
                onPressed: () => controller.openParentDialog(existing: item),
                child: const Text('Edit'),
              ),
              FilledButton.tonal(
                onPressed: () => controller.resendParentOtp(item),
                child: const Text('Resend OTP'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StaffCard extends StatelessWidget {
  const _StaffCard({required this.item, required this.controller});

  final AdminStaffRecord item;
  final AdminPeopleController controller;

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.fullName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.textDark
                            : AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.employeeCode,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(
                label: item.isActive ? 'ACTIVE' : 'INACTIVE',
                active: item.isActive,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (item.designation.isNotEmpty)
                _MetaText(label: 'Designation', value: item.designation),
              if (item.department.isNotEmpty)
                _MetaText(label: 'Department', value: item.department),
              if (item.userRole.isNotEmpty)
                _MetaText(label: 'Role', value: item.userRole),
              if (item.joinDate.length >= 10)
                _MetaText(
                  label: 'Joined',
                  value: item.joinDate.substring(0, 10),
                ),
            ],
          ),
          if (item.email.isNotEmpty || item.phone.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              [
                item.email,
                item.phone,
              ].where((value) => value.trim().isNotEmpty).join(' | '),
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => controller.openStaffDetails(item),
                child: const Text('View'),
              ),
              OutlinedButton(
                onPressed: () => controller.openStaffDialog(existing: item),
                child: const Text('Edit'),
              ),
              OutlinedButton(
                onPressed: () => controller.toggleStaffActive(item),
                child: Text(item.isActive ? 'Deactivate' : 'Activate'),
              ),
              FilledButton.tonal(
                onPressed: () => controller.deleteStaff(item),
                child: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.value});

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

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.page,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
  });

  final int page;
  final int totalPages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 360) {
            return Column(
              children: [
                Text('Page $page of $totalPages'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: onPrevious,
                      child: const Text('Previous'),
                    ),
                    OutlinedButton(
                      onPressed: onNext,
                      child: const Text('Next'),
                    ),
                  ],
                ),
              ],
            );
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: onPrevious,
                child: const Text('Previous'),
              ),
              Text('Page $page of $totalPages'),
              OutlinedButton(onPressed: onNext, child: const Text('Next')),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 36,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

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

int _tabFromArgs(Map<String, dynamic> args) {
  final value = (args['initialTab'] as num?)?.toInt() ?? 0;
  if (value < 0) return 0;
  if (value > 1) return 1;
  return value;
}
