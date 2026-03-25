import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';

class ParentAiService {
  ParentAiService(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> ask({
    required String prompt,
    String? childId,
    String? context,
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.parentAiAsk,
      data: {
        'prompt': prompt,
        if (childId != null && childId.isNotEmpty) 'childId': childId,
        if (context != null && context.isNotEmpty) 'context': context,
      },
    );
    final body = res.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid AI ask response.');
    }
    return body;
  }

  Future<Map<String, dynamic>> getCareerSuggestions() async {
    final res = await _apiClient.get(ApiEndpoints.parentAiCareer);
    final body = res.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid AI career response.');
    }
    return body;
  }
}

