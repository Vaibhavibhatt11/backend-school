import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import 'parent_api_utils.dart';

class ParentContextService extends GetxService {
  static const _selectedChildKey = 'parent_selected_child_id';
  final _box = GetStorage();
  final ApiClient _apiClient = Get.find<ApiClient>();

  final selectedChildId = RxnString();
  Future<String?>? _pendingResolve;

  @override
  void onInit() {
    super.onInit();
    selectedChildId.value = _box.read<String>(_selectedChildKey);
  }

  void setSelectedChildId(String? childId) {
    selectedChildId.value = childId;
    if (childId == null || childId.isEmpty) {
      _box.remove(_selectedChildKey);
    } else {
      _box.write(_selectedChildKey, childId);
    }
  }

  Future<String?> ensureSelectedChildId() async {
    final existing = selectedChildId.value;
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final pending = _pendingResolve;
    if (pending != null) return pending;

    _pendingResolve = _resolveAndCacheFirstChildId();
    try {
      return await _pendingResolve;
    } finally {
      _pendingResolve = null;
    }
  }

  Future<String?> _resolveAndCacheFirstChildId() async {
    try {
      final res = await _apiClient.get(ApiEndpoints.parentChildren);
      final data = extractApiData(res.data, context: 'children');
      final children = data['children'];
      if (children is List && children.isNotEmpty) {
        final first = children.first;
        if (first is Map) {
          final id = first['id']?.toString();
          if (id != null && id.isNotEmpty) {
            setSelectedChildId(id);
            return id;
          }
        }
      }
    } catch (_) {}
    return null;
  }
}
