import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_admissions_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminAdmissionsView extends GetView<AdminAdmissionsController> {
  const AdminAdmissionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('Admission Management'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Applications'),
              Tab(text: 'Waitlist'),
              Tab(text: 'Fees'),
            ],
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
          ),
        ),
        body: TabBarView(
          children: [
            RefreshIndicator(
              onRefresh: controller.loadInitialData,
              child: _buildApplicationsTab(context),
            ),
            RefreshIndicator(
              onRefresh: controller.loadInitialData,
              child: _buildWaitingListTab(context),
            ),
            RefreshIndicator(
              onRefresh: controller.loadInitialData,
              child: _buildFeesTab(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationsTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Obx(() => Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: AdminAdmissionsController.statusOptions.map((status) {
                    final isSelected = controller.selectedStatus.value == status;
                    final label = switch (status) {
                      'ALL' => 'All',
                      'UNDER_REVIEW' => 'Pending',
                      'APPROVED' => 'Approved',
                      'REJECTED' => 'Rejected',
                      'WAITING' => 'Waiting',
                      _ => status,
                    };

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          if (selected) {
                            controller.changeStatusFilter(status);
                          }
                        },
                        selectedColor: AppColors.primary,
                        showCheckmark: false,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            )),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.applications.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.errorMessage.value.isNotEmpty && controller.applications.isEmpty) {
              return _buildErrorState(context);
            }
            return _buildApplicationList(context, controller.applications);
          }),
        ),
      ],
    );
  }

  Widget _buildWaitingListTab(BuildContext context) {
    return Obx(() {
      final waitingList = controller.applications
          .where((app) => app.status == 'WAITING')
          .toList();

      if (controller.isLoading.value && controller.applications.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (waitingList.isEmpty) {
        return const _EmptyState(
          title: 'No one in waiting list',
          message: 'Students put on "Wait" status will appear here.',
        );
      }

      return _buildApplicationList(context, waitingList);
    });
  }

  Widget _buildApplicationList(BuildContext context, List<AdminAdmissionApplication> list) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _AdmissionCard(item: list[index], controller: controller);
      },
    );
  }

  Widget _buildFeesTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Admission Fees Management',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Set and manage the fees required for new admission applications.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Current Admission Fee', style: TextStyle(fontSize: 14, color: Colors.grey)),
                          SizedBox(height: 4),
                          Text('General Admission', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Obx(() => Text(
                            '₹ ${controller.currentAdmissionFee.value}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primary),
                          )),
                    ],
                  ),
                  const Divider(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: controller.openSetFeesDialog,
                      icon: const Icon(Icons.edit_rounded, size: 20),
                      label: const Text('Update Fees'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Recent Settings',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildFeeHistoryItem('Updated by Admin', 'Today', '₹ 5000'),
          _buildFeeHistoryItem('Session 2024-25 Init', '15 Apr 2024', '₹ 4500'),
        ],
      ),
    );
  }

  Widget _buildFeeHistoryItem(String title, String date, String amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
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
}

class _AdmissionCard extends StatelessWidget {
  const _AdmissionCard({required this.item, required this.controller});

  final AdminAdmissionApplication item;
  final AdminAdmissionsController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: InkWell(
        onTap: () => controller.openDetails(item),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      item.firstName.isNotEmpty ? item.firstName[0].toUpperCase() : '?',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.fullName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textDark : AppColors.textLight,
                          ),
                        ),
                        Text(
                          item.applicationNo.isEmpty ? 'Pending App No' : item.applicationNo,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  _StatusPill(label: item.status),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MetaInfo(icon: Icons.school_rounded, label: item.classLabel),
                  _MetaInfo(icon: Icons.calendar_today_rounded, label: _shortDate(item.createdAt)),
                ],
              ),
              if (item.registrationNo.isNotEmpty) ...[
                const SizedBox(height: 8),
                _MetaInfo(
                  icon: Icons.badge_rounded,
                  label: 'Reg No: ${item.registrationNo}',
                  color: AppColors.primary,
                ),
              ],
              const SizedBox(height: 16),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => controller.openDetails(item),
                      icon: const Icon(Icons.visibility_rounded, size: 18),
                      label: const Text('View Details'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => controller.addDocument(item),
                      icon: const Icon(Icons.cloud_upload_rounded, size: 18),
                      label: const Text('Upload Document'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                ],
              ),
              if (item.canReview || item.canOnboard) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (item.canReview)
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => controller.reviewApplication(item, 'APPROVED'),
                          icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                          label: const Text('Approve'),
                          style: FilledButton.styleFrom(backgroundColor: Colors.green),
                        ),
                      ),
                    if (item.canOnboard)
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => controller.onboardApplication(item),
                          icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                          label: const Text('Onboard'),
                        ),
                      ),
                    if (item.canReview) ...[
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'REJECTED', child: Text('Reject')),
                          const PopupMenuItem(value: 'WAITING', child: Text('Move to Waitlist')),
                          const PopupMenuDivider(),
                          const PopupMenuItem(
                            value: 'DELETE',
                            child: Text('Delete Application', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'DELETE') {
                            controller.deleteApplication(item);
                          } else {
                            controller.reviewApplication(item, value);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.more_vert, color: AppColors.primary, size: 20),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaInfo extends StatelessWidget {
  const _MetaInfo({required this.icon, required this.label, this.color});
  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color ?? Colors.grey),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color ?? Colors.grey,
            fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = switch (label) {
      'APPROVED' => Colors.green,
      'REJECTED' => Colors.red,
      'ONBOARDED' => Colors.blue,
      'WAITING' => Colors.orange,
      _ => Colors.orange,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label == 'UNDER_REVIEW' ? 'PENDING' : label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_empty_rounded, size: 64, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

String _shortDate(String value) {
  if (value.length >= 10) return value.substring(0, 10);
  return value;
}
