import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_students_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminStudentsView extends GetView<AdminStudentsController> {
  const AdminStudentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Student Management'),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        actions: [
          IconButton(
            onPressed: controller.loadInitialData,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.openCreateDialog,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Add Student'),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.students.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value.isNotEmpty &&
            controller.students.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: controller.loadInitialData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        final classFilterItems = <String>[
          'ALL_CLASSES',
          ...controller.classOptions.map((item) => item.label),
        ];
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                children: [
                  TextField(
                    controller: controller.searchController,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search by student name or admission number',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: IconButton(
                        onPressed: () =>
                            controller.search(controller.searchController.text),
                        icon: const Icon(Icons.arrow_forward_rounded),
                      ),
                    ),
                    onSubmitted: controller.search,
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: AdminStudentsController.statusOptions
                          .map(
                            (status) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(status == 'ALL' ? 'All' : status),
                                selected:
                                    controller.selectedStatus.value == status,
                                onSelected: (_) =>
                                    controller.changeStatusFilter(status),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                    child: DropdownButton<String>(
                      value: controller.selectedClassFilter.value,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      items: classFilterItems
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item == 'ALL_CLASSES' ? 'All Classes' : item,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.changeClassFilter(value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _SummaryChip(
                        label: 'Students',
                        value: '${controller.totalItems.value}',
                      ),
                      _SummaryChip(
                        label: 'Classes',
                        value: '${controller.classOptions.length}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.loadInitialData,
                child: controller.students.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        children: const [
                          _EmptyState(
                            title: 'No students found',
                            message:
                                'Create real student records and they will appear here with live actions.',
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: controller.students.length + 1,
                        itemBuilder: (context, index) {
                          if (index == controller.students.length) {
                            return _PaginationBar(
                              page: controller.page.value,
                              totalPages: controller.totalPages.value,
                              onPrevious: controller.page.value > 1
                                  ? () => controller.loadStudents(
                                      nextPage: controller.page.value - 1,
                                    )
                                  : null,
                              onNext:
                                  controller.page.value <
                                      controller.totalPages.value
                                  ? () => controller.loadStudents(
                                      nextPage: controller.page.value + 1,
                                    )
                                  : null,
                            );
                          }
                          final item = controller.students[index];
                          return _StudentCard(
                            item: item,
                            controller: controller,
                          );
                        },
                      ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.item, required this.controller});

  final AdminStudentRecord item;
  final AdminStudentsController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = item.status == 'ACTIVE' ? Colors.green : Colors.red;
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
                      item.admissionNo,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _StudentMeta(label: 'Class', value: item.classLabel),
              if (item.rollNo != null)
                _StudentMeta(label: 'Roll No', value: '${item.rollNo}'),
              if (item.guardianPhone.isNotEmpty)
                _StudentMeta(label: 'Guardian', value: item.guardianPhone),
              if (item.gender.isNotEmpty)
                _StudentMeta(label: 'Gender', value: item.gender),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => controller.openDetails(item),
                child: const Text('View'),
              ),
              OutlinedButton(
                onPressed: () => controller.openCreateDialog(existing: item),
                child: const Text('Edit'),
              ),
              OutlinedButton(
                onPressed: () => controller.addDocument(item),
                child: const Text('Add Document'),
              ),
              OutlinedButton(
                onPressed: () => controller.moveClass(item),
                child: const Text('Move Class'),
              ),
              OutlinedButton(
                onPressed: () => controller.toggleStatus(item),
                child: Text(
                  item.status == 'ACTIVE' ? 'Deactivate' : 'Activate',
                ),
              ),
              FilledButton.tonal(
                onPressed: () => controller.deleteStudent(item),
                child: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StudentMeta extends StatelessWidget {
  const _StudentMeta({required this.label, required this.value});

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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.message});

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
            Icons.groups_rounded,
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
