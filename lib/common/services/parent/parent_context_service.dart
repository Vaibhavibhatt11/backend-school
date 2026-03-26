import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ParentContextService extends GetxService {
  static const _selectedChildKey = 'parent_selected_child_id';
  final _box = GetStorage();

  final selectedChildId = RxnString();

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
}
