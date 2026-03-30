import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Notice {
  final String id;
  final String title;
  final String description;
  final String status; // PUBLISHED, SCHEDULED, DRAFT
  final String time;
  final List<String> audiences;
  final String? imageUrl;
  Notice({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.time,
    required this.audiences,
    this.imageUrl,
  });
}

class AdminNoticeBoardController extends GetxController {
  AdminNoticeBoardController(this._adminService);

  final AdminService _adminService;
  final selectedTab = 0.obs; // 0: All, 1: Recent, 2: Drafts
  final isLoading = false.obs;

  final notices = <Notice>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAnnouncements();
  }

  Future<void> loadAnnouncements() async {
    isLoading.value = true;
    try {
      final data = await _adminService.getAnnouncements(page: 1, limit: 50);
      final items = (data['items'] as List<dynamic>? ?? const <dynamic>[])
          .cast<Map<String, dynamic>>();
      final mapped = items
          .map(
            (item) => Notice(
              id: item['id']?.toString() ?? '',
              title: item['title']?.toString() ?? '',
              description: item['content']?.toString() ?? '',
              status: item['status']?.toString() ?? 'DRAFT',
              time: item['updatedAt']?.toString() ?? item['createdAt']?.toString() ?? '',
              audiences:
                  (item['audience']?.toString() ?? '')
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList(),
            ),
          )
          .toList();
      notices.assignAll(mapped);
    } catch (e) {
      notices.clear();
      AppToast.show(dioOrApiErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  void onTabChanged(int index) {
    selectedTab.value = index;
  }

  void onAddNotice() {
    _openAddNoticeDialog();
  }

  void onNoticeTap(Notice notice) {
    _openNoticeActionDialog(notice);
  }

  void goToSystemAuditLogs() {
    Get.toNamed(AppRoutes.ADMIN_AUDIT_LOGS);
  }

  Future<void> _openAddNoticeDialog() async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final audienceController = TextEditingController(text: 'ALL');
    final sendNow = false.obs;

    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Create Notice'),
        content: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: contentController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Content'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: audienceController,
                decoration: const InputDecoration(labelText: 'Audience (e.g. ALL, PARENT, STUDENT)'),
              ),
              CheckboxListTile(
                value: sendNow.value,
                contentPadding: EdgeInsets.zero,
                title: const Text('Send immediately'),
                onChanged: (v) => sendNow.value = v == true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Get.back(result: true), child: const Text('Save')),
        ],
      ),
    );

    if (ok != true) return;
    try {
      final created = await _adminService.createAnnouncement(
        title: titleController.text.trim(),
        content: contentController.text.trim(),
        audience: audienceController.text.trim(),
        status: sendNow.value ? 'SENT' : 'DRAFT',
      );
      if (sendNow.value) {
        final announcement = created['announcement'] as Map<String, dynamic>?;
        final id = announcement?['id']?.toString();
        if (id != null && id.isNotEmpty) {
          await _adminService.sendAnnouncement(id);
        }
      }
      await loadAnnouncements();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> _openNoticeActionDialog(Notice notice) async {
    if (notice.id.isEmpty) return;
    final action = await Get.dialog<String>(
      AlertDialog(
        title: Text(notice.title),
        content: const Text('Select action'),
        actions: [
          TextButton(onPressed: () => Get.back(result: 'close'), child: const Text('Close')),
          FilledButton(onPressed: () => Get.back(result: 'send'), child: const Text('Send Now')),
        ],
      ),
    );
    if (action == 'send') {
      try {
        await _adminService.sendAnnouncement(notice.id);
        await loadAnnouncements();
      } catch (e) {
        AppToast.show(dioOrApiErrorMessage(e));
      }
    }
  }
}
