import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import 'parent_api_utils.dart';

class ParentFinanceService {
  ParentFinanceService(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getFees({String? childId}) async {
    final query = <String, dynamic>{
      if (childId != null && childId.isNotEmpty) 'childId': childId,
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

