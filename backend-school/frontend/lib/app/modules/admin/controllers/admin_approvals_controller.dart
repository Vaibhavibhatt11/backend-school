import 'package:get/get.dart';
import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';

class ApprovalRequest {
  const ApprovalRequest({
    required this.id,
    required this.name,
    required this.type,
    required this.approvalType,
    required this.description,
    required this.status,
    this.dateRange,
    this.grade,
    this.oldAddress,
    this.newAddress,
    this.amount,
    this.waiverCategory,
  });

  ApprovalRequest copyWith({
    String? status,
  }) {
    return ApprovalRequest(
      id: id,
      name: name,
      type: type,
      approvalType: approvalType,
      description: description,
      status: status ?? this.status,
      dateRange: dateRange,
      grade: grade,
      oldAddress: oldAddress,
      newAddress: newAddress,
      amount: amount,
      waiverCategory: waiverCategory,
    );
  }

  final String id;
  final String name;
  final String type;
  final String approvalType;
  final String description;
  final String status;
  final String? dateRange;
  final String? grade;
  final String? oldAddress;
  final String? newAddress;
  final double? amount;
  final String? waiverCategory;
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

  List<ApprovalRequest> get visibleRequests {
    return requests.where((request) {
      final status = request.status.toUpperCase();
      switch (selectedTab.value) {
        case 1:
          return status == 'APPROVED';
        case 2:
          return status == 'REJECTED';
        default:
          return status == 'PENDING';
      }
    }).toList();
  }

  int countForTab(int index) {
    switch (index) {
      case 1:
        return requests.where((request) => request.status.toUpperCase() == 'APPROVED').length;
      case 2:
        return requests.where((request) => request.status.toUpperCase() == 'REJECTED').length;
      default:
        return requests.where((request) => request.status.toUpperCase() == 'PENDING').length;
    }
  }

  Future<void> loadPendingApprovals() async {
    isLoading.value = true;
    loadError.value = null;
    try {
      final data = await _adminService.getPendingApprovalsSummary();
      final topItems =
          (data['topItems'] as List<dynamic>? ?? const <dynamic>[])
              .cast<Map<String, dynamic>>();
      final mapped = topItems.map(_mapApprovalRequest).toList();
      requests.assignAll(mapped);
    } catch (e) {
      loadError.value = dioOrApiErrorMessage(e);
      requests.clear();
      AppToast.show(loadError.value ?? 'Approvals unavailable.');
    } finally {
      isLoading.value = false;
    }
  }

  ApprovalRequest _mapApprovalRequest(Map<String, dynamic> item) {
    final approvalType = _resolveApprovalType(item);
    final typeLabel = _humanize(item['type'] ?? item['approvalType'] ?? approvalType);
    final submittedAt = item['submittedAt']?.toString() ?? item['createdAt']?.toString() ?? '';
    return ApprovalRequest(
      id: item['id']?.toString() ?? '',
      name:
          item['title']?.toString() ??
          item['name']?.toString() ??
          item['studentName']?.toString() ??
          'Pending Request',
      type: typeLabel,
      approvalType: approvalType,
      description:
          item['description']?.toString() ??
          item['reason']?.toString() ??
          (submittedAt.isEmpty ? 'Pending approval' : 'Submitted $submittedAt'),
      status: item['status']?.toString().toUpperCase() == 'REJECTED'
          ? 'REJECTED'
          : item['status']?.toString().toUpperCase() == 'APPROVED'
              ? 'APPROVED'
              : 'PENDING',
      dateRange: _dateRangeText(item),
      grade: item['grade']?.toString() ??
          item['className']?.toString() ??
          item['appliedClass']?.toString(),
      oldAddress: item['oldAddress']?.toString(),
      newAddress: item['newAddress']?.toString(),
      amount: (item['amount'] as num?)?.toDouble() ??
          (item['requestedAmount'] as num?)?.toDouble() ??
          (item['waiverAmount'] as num?)?.toDouble(),
      waiverCategory: item['waiverCategory']?.toString() ?? item['category']?.toString(),
    );
  }

  String _resolveApprovalType(Map<String, dynamic> item) {
    final raw =
        item['approvalType']?.toString() ??
        item['typeSlug']?.toString() ??
        item['type']?.toString() ??
        '';
    final normalized = raw.trim().toLowerCase().replaceAll('_', '-');
    if (normalized.isNotEmpty) return normalized;
    return 'staff-leave';
  }

  String _dateRangeText(Map<String, dynamic> item) {
    final from = item['fromDate']?.toString() ?? item['startDate']?.toString() ?? '';
    final to = item['toDate']?.toString() ?? item['endDate']?.toString() ?? '';
    if (from.isEmpty && to.isEmpty) return '';
    if (from.isNotEmpty && to.isNotEmpty) return '$from - $to';
    return from.isNotEmpty ? from : to;
  }

  String _humanize(Object? value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) return 'Request';
    return text
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}')
        .join(' ');
  }

  Future<void> _decide(ApprovalRequest request, bool approve) async {
    if (request.id.isEmpty) return;
    try {
      await _adminService.decideApproval(
        approvalType: request.approvalType,
        id: request.id,
        approve: approve,
      );
      final index = requests.indexWhere((item) => item.id == request.id);
      if (index != -1) {
        requests[index] = request.copyWith(
          status: approve ? 'APPROVED' : 'REJECTED',
        );
        requests.refresh();
      }
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
