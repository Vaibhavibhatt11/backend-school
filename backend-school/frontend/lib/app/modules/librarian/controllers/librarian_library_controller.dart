import 'package:erp_frontend/app/modules/admin/controllers/admin_resources_controller.dart';
import 'package:get/get.dart';

class LibrarianLibraryController extends GetxController {
  AdminResourcesController get resources => Get.find<AdminResourcesController>();

  @override
  void onInit() {
    super.onInit();
    _ensureLibraryLoaded();
  }

  Future<void> _ensureLibraryLoaded() async {
    if (resources.currentTab.value != 0) {
      resources.currentTab.value = 0;
    }
    await resources.loadCurrentTab(force: true);
  }

  Future<void> refreshLibrary() async {
    resources.currentTab.value = 0;
    await resources.refreshCurrentTab();
  }

  Future<void> openBookForm() => resources.openBookDialog();

  Future<void> openIssueFlow() => resources.issueBook();

  Future<void> openCategoryForm() => resources.openLibraryCategoryDialog();

  Future<void> openLibraryCardForm() => resources.openLibraryCardDialog();

  Future<void> openFineRuleForm() => resources.openLateFineRuleDialog();
}
