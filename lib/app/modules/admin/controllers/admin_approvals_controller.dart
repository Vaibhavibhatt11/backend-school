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

  void onReject(ApprovalRequest request) {
    loadPendingApprovals();
  }

  void onApprove(ApprovalRequest request) {
    loadPendingApprovals();
  }

  void onFloatingAction() {
    loadPendingApprovals();
  }
}
