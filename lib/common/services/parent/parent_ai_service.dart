import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import 'parent_api_utils.dart';

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
        'question': prompt,
        'prompt': prompt,
        if (childId != null && childId.isNotEmpty) 'childId': childId,
        if (context != null && context.isNotEmpty) 'context': context,
      },
    );
    return extractApiData(res.data, context: 'ai ask');
  }

  Future<Map<String, dynamic>> getCareerSuggestions({String? childId}) async {
    final query = <String, dynamic>{
      if (childId != null && childId.isNotEmpty) 'childId': childId,
    };
    final res = await _apiClient.get(
      ApiEndpoints.parentAiCareer,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'ai career');
  }
}

