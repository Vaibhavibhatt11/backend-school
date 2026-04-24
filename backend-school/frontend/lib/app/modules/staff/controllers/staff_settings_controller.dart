import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/services/staff/staff_portal_store_service.dart';
import 'package:erp_frontend/common/services/staff/staff_service.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';

class StaffSettingsController extends GetxController {
  StaffSettingsController(this._staffService, this._store);

  final StaffService _staffService;
  final StaffPortalStoreService _store;
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
      final backup = await _store.readModule('settings');
      Map<String, dynamic> settings = Map<String, dynamic>.from(backup);
      try {
        final data = await _staffService.getSettings();
        settings.addAll(data['settings'] as Map<String, dynamic>? ?? const {});
      } catch (_) {
        // Use persisted backend store when the dedicated staff settings
        // endpoint is unavailable.
      }
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
      var syncedPrimary = false;
      try {
        await _staffService.updateSettings(
          notificationsEnabled: nextNotifications,
          privacyMode: nextPrivacy,
          compactView: nextCompact,
        );
        syncedPrimary = true;
      } catch (_) {}
      await _store.patchModule('settings', {
        'notificationsEnabled': nextNotifications,
        'privacyMode': nextPrivacy,
        'compactView': nextCompact,
      });
      notificationsEnabled.value = nextNotifications;
      privacyMode.value = nextPrivacy;
      compactView.value = nextCompact;
      AppToast.show(
        syncedPrimary
            ? 'Settings updated.'
            : 'Settings saved in staff workspace.',
      );
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }
}
