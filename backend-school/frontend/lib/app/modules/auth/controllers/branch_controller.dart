import 'package:flutter/widgets.dart';
import 'package:erp_frontend/app/data/models/branch_model.dart';
import 'package:erp_frontend/app/data/repositories/user_repository.dart';
import 'package:erp_frontend/common/routes/common_routes_screens.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';

class BranchController extends GetxController {
  final UserRepository _userRepository = Get.find<UserRepository>();
  final branches = <BranchModel>[].obs;
  final selectedBranchId = RxnString();
  final searchQuery = ''.obs;
  final isLoading = false.obs;
  final loadError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadBranches();
  }

  Future<void> loadBranches() async {
    isLoading.value = true;
    loadError.value = '';
    try {
      final items = await _userRepository.fetchPublicBranches();
      branches.value = items;
      if (branches.isNotEmpty) {
        selectBranch(branches.first.id);
      } else {
        selectedBranchId.value = null;
      }
    } catch (e) {
      branches.clear();
      selectedBranchId.value = null;
      loadError.value = dioOrApiErrorMessage(e);
      AppToast.show(loadError.value);
    } finally {
      isLoading.value = false;
    }
  }

  void selectBranch(String id) {
    selectedBranchId.value = id;
    // Mark selected
    branches.value =
        branches.map((b) {
          return BranchModel(
            id: b.id,
            name: b.name,
            address: b.address,
            isSelected: b.id == id,
          );
        }).toList();
  }

  void confirmSelection() {
    if ((selectedBranchId.value ?? '').isEmpty) {
      AppToast.show('No branch available. Contact school administrator.');
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.currentRoute != CommonScreenRoutes.loginScreen) {
        Get.toNamed(CommonScreenRoutes.loginScreen);
      }
    });
  }

  List<BranchModel> get filteredBranches {
    if (searchQuery.isEmpty) return branches;
    return branches
        .where(
          (b) =>
              b.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              b.address.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();
  }
}
