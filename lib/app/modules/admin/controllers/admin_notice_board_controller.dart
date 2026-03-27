import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';

class Notice {
  final String title;
  final String description;
  final String status; // PUBLISHED, SCHEDULED, DRAFT
  final String time;
  final List<String> audiences;
  final String? imageUrl;
  Notice({
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
    AppToast.show('Create new notice');
  }

  void onNoticeTap(Notice notice) {
    AppToast.show(notice.title);
  }

  void goToSystemAuditLogs() {
    Get.toNamed(AppRoutes.ADMIN_AUDIT_LOGS);
  }
}
