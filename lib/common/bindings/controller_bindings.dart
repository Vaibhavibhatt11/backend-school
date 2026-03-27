import 'package:get/get.dart';
import '../../app/services/theme_service.dart';
import '../api/api_client.dart';
import '../services/auth_service.dart';
import '../services/session_storage_service.dart';
import '../services/system_service.dart';
import '../services/parent/parent_academics_service.dart';
import '../services/parent/parent_ai_service.dart';
import '../services/parent/parent_communication_service.dart';
import '../services/parent/parent_context_service.dart';
import '../services/parent/parent_dashboard_service.dart';
import '../services/parent/parent_finance_service.dart';
import '../services/parent/parent_profile_service.dart';
import '../services/parent/parent_settings_service.dart';
import '../services/admin/admin_service.dart';

class ControllerBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SessionStorageService>()) {
      Get.put<SessionStorageService>(SessionStorageService(), permanent: true);
    }
    if (!Get.isRegistered<ApiClient>()) {
      Get.put<ApiClient>(ApiClient(Get.find<SessionStorageService>()), permanent: true);
    }
    if (!Get.isRegistered<ThemeService>()) {
      Get.put<ThemeService>(ThemeService(), permanent: true);
    }

    // Core services
    if (!Get.isRegistered<AuthService>()) {
      Get.put<AuthService>(
        AuthService(Get.find<ApiClient>(), Get.find<SessionStorageService>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<SystemService>()) {
      Get.put<SystemService>(SystemService(Get.find<ApiClient>()), permanent: true);
    }

    // Parent module services
    if (!Get.isRegistered<ParentDashboardService>()) {
      Get.put<ParentDashboardService>(
        ParentDashboardService(Get.find<ApiClient>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<ParentContextService>()) {
      Get.put<ParentContextService>(ParentContextService(), permanent: true);
    }
    if (!Get.isRegistered<ParentCommunicationService>()) {
      Get.put<ParentCommunicationService>(
        ParentCommunicationService(Get.find<ApiClient>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<ParentAcademicsService>()) {
      Get.put<ParentAcademicsService>(
        ParentAcademicsService(Get.find<ApiClient>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<ParentFinanceService>()) {
      Get.put<ParentFinanceService>(
        ParentFinanceService(Get.find<ApiClient>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<ParentProfileService>()) {
      Get.put<ParentProfileService>(
        ParentProfileService(Get.find<ApiClient>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<ParentAiService>()) {
      Get.put<ParentAiService>(
        ParentAiService(Get.find<ApiClient>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<ParentSettingsService>()) {
      Get.put<ParentSettingsService>(
        ParentSettingsService(Get.find<ApiClient>()),
        permanent: true,
      );
    }

    // Admin module services
    if (!Get.isRegistered<AdminService>()) {
      Get.put<AdminService>(AdminService(Get.find<ApiClient>()), permanent: true);
    }
  }
}
