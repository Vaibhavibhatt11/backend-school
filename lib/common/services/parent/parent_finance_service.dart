import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';

class ParentFinanceService {
  ParentFinanceService(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getFees() async {
    final res = await _apiClient.get(ApiEndpoints.parentFees);
    final body = res.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid fees response.');
    }
    return body;
  }

  Future<Map<String, dynamic>> getInvoiceById(String invoiceId) async {
    final res = await _apiClient.get(ApiEndpoints.parentInvoiceById(invoiceId));
    final body = res.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid invoice response.');
    }
    return body;
  }
}

