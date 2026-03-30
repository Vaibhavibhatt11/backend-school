import 'package:get/get.dart';
import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';

class ApprovalRequest {
  final String id;
  final String name;
  final String type;
  final String description;
  final String? dateRange;
  final String? grade;
  final String? oldAddress;
  final String? newAddress;
  final double? amount;
  final String? waiverCategory;
  ApprovalRequest({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    this.dateRange,
    this.grade,
    this.oldAddress,
    this.newAddress,
    this.amount,
    this.waiverCategory,
  });
}

class AdminApprovalsController extends GetxController {
  AdminApprovalsController(this._adminService);

  final AdminService _adminService;
  final isLoading = false.obs;
  final requests = <ApprovalRequest>[].obs;
  final loadError = RxnString();
  final selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadPendingApprovals();
  }

  Future<void> loadPendingApprovals() async {
    isLoading.value = true;
    loadError.value = null;
    try {
      final data = await _adminService.getPendingApprovalsSummary();
      final topItems =
          (data['topItems'] as List<dynamic>? ?? const <dynamic>[])
              .cast<Map<String, dynamic>>();
      final mapped = topItems
          .map(
            (item) => ApprovalRequest(
              id: item['id']?.toString() ?? '',
              name: item['title']?.toString() ?? 'Pending Request',
              type: item['type']?.toString() ?? 'REQUEST',
              description: 'Submitted ${item['submittedAt'] ?? ''}',
            ),
          )
          .toList();
      requests.assignAll(mapped);
    } catch (e) {
      loadError.value = dioOrApiErrorMessage(e);
      requests.clear();
      AppToast.show(loadError.value ?? 'Approvals unavailable.');
    } finally {
      isLoading.value = false;
    }
  }

  String _mapApprovalType(String type) {
    final t = type.trim().toUpperCase();
    if (t == 'STAFF_LEAVE') return 'staff-leave';
    if (t == 'STUDENT_LEAVE') return 'student-leave';
    if (t == 'FACE_CHECKIN') return 'face-checkin';
    return 'staff-leave';
  }

  Future<void> _decide(ApprovalRequest request, bool approve) async {
    if (request.id.isEmpty) return;
    try {
      await _adminService.decideApproval(
        approvalType: _mapApprovalType(request.type),
        id: request.id,
        approve: approve,
      );
      requests.removeWhere((r) => r.id == request.id);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> onReject(ApprovalRequest request) => _decide(request, false);

  Future<void> onApprove(ApprovalRequest request) => _decide(request, true);

  void onTabChanged(int index) {
    selectedTab.value = index;
  }

  void onFloatingAction() {
    loadPendingApprovals();
  }
}
