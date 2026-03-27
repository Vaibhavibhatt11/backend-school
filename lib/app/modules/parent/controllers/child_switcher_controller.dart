import 'package:get/get.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import '../../../../common/services/parent/parent_context_service.dart';
import '../../../../common/services/parent/parent_dashboard_service.dart';

class ChildSwitcherController extends GetxController {
  final ParentDashboardService _dashboardService = Get.find<ParentDashboardService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final isLoading = false.obs;
  final children = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadChildren();
  }

  Future<void> loadChildren() async {
    isLoading.value = true;
    try {
      final data = await _dashboardService.getChildren();
      final items = data['children'];
      if (items is List) {
        final selectedId = _parentContext.selectedChildId.value;
        children.assignAll(
          items.whereType<Map>().map((item) {
            final map = Map<String, dynamic>.from(item);
            final id = map['id']?.toString() ?? '';
            map['active'] = selectedId != null ? id == selectedId : (map['active'] == true);
            return map;
          }),
        );
        if (children.isNotEmpty && (selectedId == null || selectedId.isEmpty)) {
          _parentContext.setSelectedChildId(children.first['id']?.toString());
          children[0]['active'] = true;
          children.refresh();
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  void selectChild(int index) {
    for (int i = 0; i < children.length; i++) {
      children[i]['active'] = i == index;
    }
    children.refresh();
    _parentContext.setSelectedChildId(children[index]['id']?.toString());
    Get.back();
    AppToast.show('Now viewing ${children[index]['name']}');
  }

  void linkAnotherChild() {
    AppToast.show('Link-child endpoint is not configured yet.');
  }
}
