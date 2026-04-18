import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_staff_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminStaffView extends GetView<AdminStaffController> {
  const AdminStaffView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('Staff Management'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All Staff'),
              Tab(text: 'Teachers'),
              Tab(text: 'Support'),
            ],
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
          ),
        ),
        body: Column(
          children: [
            _buildSearchHeader(context),
            Expanded(
              child: TabBarView(
                children: [
                  _buildStaffList(context, 'ALL'),
                  _buildStaffList(context, 'TEACHERS'),
                  _buildStaffList(context, 'SUPPORT'),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.openAddStaff,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Staff'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Column(
        children: [
          TextField(
            controller: controller.searchController,
            onChanged: controller.onSearch,
            decoration: InputDecoration(
              hintText: 'Search by name, code or department...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  controller.searchController.clear();
                  controller.onSearch('');
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => Row(
            children: [
              _StatBadge(
                label: 'Total',
                value: controller.totalItems.value.toString(),
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              _StatBadge(
                label: 'Teachers',
                value: controller.staffMembers.where((s) => s.isTeacher).length.toString(),
                color: Colors.green,
              ),
              const SizedBox(width: 8),
              _StatBadge(
                label: 'Active',
                value: controller.staffMembers.where((s) => s.isActive).length.toString(),
                color: Colors.orange,
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildStaffList(BuildContext context, String filter) {
    return Obx(() {
      if (controller.isLoading.value && controller.staffMembers.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      var list = controller.staffMembers.toList();
      if (filter == 'TEACHERS') {
        list = list.where((s) => s.isTeacher).toList();
      } else if (filter == 'SUPPORT') {
        list = list.where((s) => !s.isTeacher).toList();
      }

      if (list.isEmpty) {
        return _buildEmptyState(context);
      }

      return RefreshIndicator(
        onRefresh: controller.loadInitialData,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: list.length,
          itemBuilder: (context, index) {
            return _StaffCard(item: list[index], controller: controller);
          },
        ),
      );
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No staff members found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching for something else or add a new record.',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class _StaffCard extends StatelessWidget {
  const _StaffCard({required this.item, required this.controller});
  final AdminStaffRecord item;
  final AdminStaffController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => controller.viewDetails(item),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: (item.isTeacher ? Colors.blue : Colors.purple).withValues(alpha: 0.1),
                      child: Text(
                        item.fullName[0].toUpperCase(),
                        style: TextStyle(
                          color: item.isTeacher ? Colors.blue : Colors.purple,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                item.fullName,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                              const SizedBox(width: 8),
                              _StatusDot(isActive: item.isActive),
                            ],
                          ),
                          Text(
                            item.designation,
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'EDIT', child: Text('Edit Profile')),
                        const PopupMenuItem(value: 'STATUS', child: Text('Toggle Status')),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'DELETE',
                          child: Text('Remove Staff', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'EDIT') controller.openEditStaff(item);
                        if (value == 'STATUS') controller.toggleStatus(item);
                        if (value == 'DELETE') controller.deleteStaff(item);
                      },
                      child: const Icon(Icons.more_vert_rounded, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.grey.withValues(alpha: 0.02),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _MetaInfo(Icons.badge_outlined, item.employeeCode),
                    _MetaInfo(Icons.business_outlined, item.department.isEmpty ? 'General' : item.department),
                    _MetaInfo(Icons.calendar_month_outlined, item.joinDate.split('T').first),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.red,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (isActive ? Colors.green : Colors.red).withValues(alpha: 0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class _MetaInfo extends StatelessWidget {
  const _MetaInfo(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[700]),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
