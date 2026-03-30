import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import 'package:get/get.dart';
import 'parent_api_utils.dart';
import 'parent_context_service.dart';

class ParentFinanceService {
  ParentFinanceService(this._apiClient);

  final ApiClient _apiClient;
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  Future<Map<String, dynamic>> getFees({String? childId}) async {
    final scopedChildId = (childId == null || childId.isEmpty)
        ? await _parentContext.ensureSelectedChildId()
        : childId;
    final query = <String, dynamic>{
      if (scopedChildId != null && scopedChildId.isNotEmpty) 'childId': scopedChildId,
    };
    final res = await _apiClient.get(
      ApiEndpoints.parentFees,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'fees');
  }

  Future<Map<String, dynamic>> getInvoiceById(String invoiceId) async {
    final res = await _apiClient.get(ApiEndpoints.parentInvoiceById(invoiceId));
    return extractApiData(res.data, context: 'invoice');
  }
}

