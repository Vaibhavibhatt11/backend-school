import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_shell_controller.dart';
import 'package:erp_frontend/app/navbar/admin_bottom_nav_bar.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_notice_board_controller.dart';

class AdminNoticeBoardView extends GetView<AdminNoticeBoardController> {
  final bool embedded;
  const AdminNoticeBoardView({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final content = SafeArea(
      child: Column(
          children: [
            // Header with search/tune
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (embedded && Get.isRegistered<AdminShellController>()) {
                            Get.find<AdminShellController>().setTab(0);
                            return;
                          }
                          if (Get.key.currentState?.canPop() ?? false) {
                            Get.back();
                          }
                        },
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Notice Board',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Manage school communications',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.search,
                            color: AppColors.primary,
                          ),
                          onPressed:
                              () => AppToast.show('Search notices'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: controller.goToSystemAuditLogs,
                        icon: const Icon(
                          Icons.history,
                          color: AppColors.primary,
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.tune,
                            color: AppColors.primary,
                          ),
                          onPressed:
                              () => AppToast.show('Filter notices'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Segmented control
            Obx(
              () => Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    _buildSegment('All', 0, controller.selectedTab.value),
                    _buildSegment('Recent', 1, controller.selectedTab.value),
                    _buildSegment('Drafts', 2, controller.selectedTab.value),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Notice list
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                List<Notice> filtered =
                    controller.notices.where((n) {
                      if (controller.selectedTab.value == 0) return true;
                      if (controller.selectedTab.value == 1) {
                        return n.status == 'PUBLISHED' ||
                            n.status == 'SCHEDULED';
                      }
                      return n.status == 'DRAFT';
                    }).toList();
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final notice = filtered[index];
                    return GestureDetector(
                      onTap: () => controller.onNoticeTap(notice),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (notice.imageUrl != null)
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child: Image.network(
                                  notice.imageUrl!,
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(
                                            notice.status,
                                          ).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          notice.status,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: _getStatusColor(
                                              notice.status,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        notice.time,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    notice.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notice.description,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    children:
                                        notice.audiences
                                            .map(
                                              (aud) => Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary
                                                      .withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  aud,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
      ),
    );
    if (embedded) {
      return Scaffold(
        body: content,
        floatingActionButton: FloatingActionButton(
          heroTag: 'admin_notices_fab_embedded',
          onPressed: controller.onAddNotice,
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      );
    }
    return Scaffold(
      body: content,
      floatingActionButton: FloatingActionButton(
        heroTag: 'admin_notices_fab',
        onPressed: controller.onAddNotice,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: AdminBottomNavBar(currentIndex: 3), // Notices tab
    );
  }

  Widget _buildSegment(String label, int index, int selectedIndex) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.onTabChanged(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selectedIndex == index ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight:
                    selectedIndex == index
                        ? FontWeight.bold
                        : FontWeight.normal,
                color: selectedIndex == index ? AppColors.primary : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PUBLISHED':
        return Colors.green;
      case 'SCHEDULED':
        return Colors.amber;
      case 'DRAFT':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
