import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_academics_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminAcademicsView extends GetView<AdminAcademicsController> {
  const AdminAcademicsView({super.key});

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
          title: const Text('Academic Setup'),
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Classes'),
              Tab(text: 'Subjects'),
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
            _ClassesTab(controller: controller),
            _SubjectsTab(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _ClassesTab extends StatelessWidget {
  const _ClassesTab({required this.controller});

  final AdminAcademicsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isClassesLoading.value && controller.classes.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.classesError.value.isNotEmpty &&
          controller.classes.isEmpty) {
        return _ErrorState(
          message: controller.classesError.value,
          onRetry: () => controller.loadClasses(),
        );
      }
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                TextField(
                  controller: controller.classesSearchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search classes by name or section',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: IconButton(
                      onPressed: () => controller.searchClasses(
                        controller.classesSearchController.text,
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded),
                    ),
                  ),
                  onSubmitted: controller.searchClasses,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SummaryChip(
                      label: 'Classes',
                      value: '${controller.classesTotalItems.value}',
                    ),
                    _SummaryChip(
                      label: 'Teachers',
                      value: '${controller.staffOptions.length}',
                    ),
                    FilledButton.icon(
                      onPressed: () => controller.openClassDialog(),
                      icon: const Icon(Icons.add_business_rounded),
                      label: const Text('Add Class'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.loadInitialData,
              child: controller.classes.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: const [
                        _EmptyState(
                          icon: Icons.meeting_room_rounded,
                          title: 'No classes found',
                          message:
                              'Class records will appear here with real teacher and student counts.',
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: controller.classes.length + 1,
                      itemBuilder: (context, index) {
                        if (index == controller.classes.length) {
                          return _PaginationBar(
                            page: controller.classesPage.value,
                            totalPages: controller.classesTotalPages.value,
                            onPrevious: controller.classesPage.value > 1
                                ? () => controller.loadClasses(
                                    nextPage: controller.classesPage.value - 1,
                                  )
                                : null,
                            onNext:
                                controller.classesPage.value <
                                    controller.classesTotalPages.value
                                ? () => controller.loadClasses(
                                    nextPage: controller.classesPage.value + 1,
                                  )
                                : null,
                          );
                        }
                        final item = controller.classes[index];
                        return _ClassCard(item: item, controller: controller);
                      },
                    ),
            ),
          ),
        ],
      );
    });
  }
}

class _SubjectsTab extends StatelessWidget {
  const _SubjectsTab({required this.controller});

  final AdminAcademicsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isSubjectsLoading.value && controller.subjects.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.subjectsError.value.isNotEmpty &&
          controller.subjects.isEmpty) {
        return _ErrorState(
          message: controller.subjectsError.value,
          onRetry: () => controller.loadSubjects(),
        );
      }
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                TextField(
                  controller: controller.subjectsSearchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search subjects by name or code',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: IconButton(
                      onPressed: () => controller.searchSubjects(
                        controller.subjectsSearchController.text,
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded),
                    ),
                  ),
                  onSubmitted: controller.searchSubjects,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SummaryChip(
                      label: 'Subjects',
                      value: '${controller.subjectsTotalItems.value}',
                    ),
                    FilledButton.icon(
                      onPressed: () => controller.openSubjectDialog(),
                      icon: const Icon(Icons.menu_book_rounded),
                      label: const Text('Add Subject'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.loadInitialData,
              child: controller.subjects.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: const [
                        _EmptyState(
                          icon: Icons.library_books_rounded,
                          title: 'No subjects found',
                          message:
                              'Subject masters will appear here with real active status.',
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: controller.subjects.length + 1,
                      itemBuilder: (context, index) {
                        if (index == controller.subjects.length) {
                          return _PaginationBar(
                            page: controller.subjectsPage.value,
                            totalPages: controller.subjectsTotalPages.value,
                            onPrevious: controller.subjectsPage.value > 1
                                ? () => controller.loadSubjects(
                                    nextPage: controller.subjectsPage.value - 1,
                                  )
                                : null,
                            onNext:
                                controller.subjectsPage.value <
                                    controller.subjectsTotalPages.value
                                ? () => controller.loadSubjects(
                                    nextPage: controller.subjectsPage.value + 1,
                                  )
                                : null,
                          );
                        }
                        final item = controller.subjects[index];
                        return _SubjectCard(item: item, controller: controller);
                      },
                    ),
            ),
          ),
        ],
      );
    });
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.item, required this.controller});

  final AdminClassRecord item;
  final AdminAcademicsController controller;

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
            item.label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _MetaText(label: 'Students', value: '${item.studentsCount}'),
              if (item.capacity != null)
                _MetaText(label: 'Capacity', value: '${item.capacity}'),
              if (item.classTeacherName.isNotEmpty)
                _MetaText(label: 'Teacher', value: item.classTeacherName),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => controller.openClassDialog(existing: item),
                child: const Text('Edit'),
              ),
              FilledButton.tonal(
                onPressed: () => controller.deleteClass(item),
                child: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({required this.item, required this.controller});

  final AdminSubjectRecord item;
  final AdminAcademicsController controller;

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
                      item.name,
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
                      item.code,
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
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => controller.openSubjectDialog(existing: item),
                child: const Text('Edit'),
              ),
              OutlinedButton(
                onPressed: () => controller.toggleSubjectActive(item),
                child: Text(item.isActive ? 'Deactivate' : 'Activate'),
              ),
              FilledButton.tonal(
                onPressed: () => controller.deleteSubject(item),
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
