import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';

class ApprovalRequest {
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
  final requests = <ApprovalRequest>[
    ApprovalRequest(
      name: 'Marcus Thompson',
      type: 'Leave',
      description: 'Family emergency trip to visit grandparents.',
      dateRange: 'Oct 24 - 26',
      grade: 'Grade 10-B',
    ),
    ApprovalRequest(
      name: 'Elena Rodriguez',
      type: 'Fee Waiver',
      description: 'Requested Waiver Category',
      amount: 450.00,
      waiverCategory: 'Academic Excellence',
    ),
    ApprovalRequest(
      name: 'Sarah Jenkins',
      type: 'Profile Edit',
      description: 'Requesting change of address',
      oldAddress: '124 Oak Street, Apt 4B...',
      newAddress: '889 Maple Ave, Suite 210',
    ),
    ApprovalRequest(
      name: 'Leo G. Vance',
      type: 'Leave',
      description: 'Medical checkup & dentist appointment.',
      dateRange: 'Today, 1:00 PM',
    ),
  ];

  void onReject(ApprovalRequest request) {
    Get.dialog(
      AlertDialog(
        title: Text('Reject Request'),
        content: Text(
          'Are you sure you want to reject ${request.name}\'s request?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              requests.remove(request);
              Get.back();
              AppToast.show('Request rejected');
            },
            child: Text('Reject', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void onApprove(ApprovalRequest request) {
    Get.dialog(
      AlertDialog(
        title: Text('Approve Request'),
        content: Text('Approve ${request.name}\'s request?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              requests.remove(request);
              Get.back();
              AppToast.show('Request approved');
            },
            child: Text('Approve'),
          ),
        ],
      ),
    );
  }

  void onFloatingAction() {
    AppToast.show('Quick approval filters');
  }
}
