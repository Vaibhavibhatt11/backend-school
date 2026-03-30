import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import 'package:get/get.dart';
import 'parent_api_utils.dart';
import 'parent_context_service.dart';

class ParentAiService {
  ParentAiService(this._apiClient);

  final ApiClient _apiClient;
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  Future<Map<String, dynamic>> ask({
    required String prompt,
    String? childId,
    String? context,
  }) async {
    final scopedChildId = (childId == null || childId.isEmpty)
        ? await _parentContext.ensureSelectedChildId()
        : childId;
    final res = await _apiClient.post(
      ApiEndpoints.parentAiAsk,
      data: {
        'question': prompt,
        'prompt': prompt,
        if (scopedChildId != null && scopedChildId.isNotEmpty) 'childId': scopedChildId,
        if (context != null && context.isNotEmpty) 'context': context,
      },
    );
    return extractApiData(res.data, context: 'ai ask');
  }

  Future<Map<String, dynamic>> getCareerSuggestions({String? childId}) async {
    final scopedChildId = (childId == null || childId.isEmpty)
        ? await _parentContext.ensureSelectedChildId()
        : childId;
    final query = <String, dynamic>{
      if (scopedChildId != null && scopedChildId.isNotEmpty) 'childId': scopedChildId,
    };
    final res = await _apiClient.get(
      ApiEndpoints.parentAiCareer,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'ai career');
  }
}

