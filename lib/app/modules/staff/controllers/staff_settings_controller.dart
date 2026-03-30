import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/services/staff/staff_service.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';

class StaffSettingsController extends GetxController {
  StaffSettingsController(this._staffService);

  final StaffService _staffService;
  final isLoading = false.obs;
  final notificationsEnabled = true.obs;
  final privacyMode = false.obs;
  final compactView = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    isLoading.value = true;
    try {
      final data = await _staffService.getSettings();
      final settings = data['settings'] as Map<String, dynamic>? ?? const {};
      notificationsEnabled.value = settings['notificationsEnabled'] != false;
      privacyMode.value = settings['privacyMode'] == true;
      compactView.value = settings['compactView'] == true;
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSettings({
    bool? notifications,
    bool? privacy,
    bool? compact,
  }) async {
    final nextNotifications = notifications ?? notificationsEnabled.value;
    final nextPrivacy = privacy ?? privacyMode.value;
    final nextCompact = compact ?? compactView.value;
    try {
      await _staffService.updateSettings(
        notificationsEnabled: nextNotifications,
        privacyMode: nextPrivacy,
        compactView: nextCompact,
      );
      notificationsEnabled.value = nextNotifications;
      privacyMode.value = nextPrivacy;
      compactView.value = nextCompact;
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }
}
