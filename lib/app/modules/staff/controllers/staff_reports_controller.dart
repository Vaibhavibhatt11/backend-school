import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/services/staff/staff_service.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';

class StaffReportsController extends GetxController {
  StaffReportsController(this._staffService);

  final StaffService _staffService;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final reportTiles = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadReports();
  }

  Future<void> loadReports() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _staffService.getReports();
      final raw = data['reportTiles'];
      if (raw is List) {
        reportTiles.assignAll(
          raw
              .whereType<Map>()
              .map((e) => {
                    'title': (e['title'] ?? '').toString(),
                    'value': (e['value'] ?? '').toString(),
                  })
              .toList(),
        );
      } else {
        reportTiles.clear();
      }
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      AppToast.show(errorMessage.value);
      reportTiles.clear();
    } finally {
      isLoading.value = false;
    }
  }
}

