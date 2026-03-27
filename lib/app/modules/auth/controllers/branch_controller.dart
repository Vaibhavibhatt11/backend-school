import 'package:erp_frontend/app/data/models/branch_model.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';

class BranchController extends GetxController {
  final branches = <BranchModel>[].obs;
  final selectedBranchId = RxnString();
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadBranches();
  }

  void loadBranches() {
    // Dummy data
    branches.value = [
      BranchModel(
        id: '1',
        name: 'Downtown Campus',
        address: '123 Education Way, North District',
      ),
      BranchModel(
        id: '2',
        name: 'East Side Elementary',
        address: '456 Learning Blvd, East District',
      ),
      BranchModel(
        id: '3',
        name: 'International Secondary',
        address: '789 Global Road, Central City',
      ),
      BranchModel(
        id: '4',
        name: 'West Valley Prep',
        address: '321 Horizon Circle, West Hills',
      ),
      BranchModel(
        id: '5',
        name: 'Greenwood High',
        address: '101 Nature Pass, Parkside',
      ),
    ];
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
    if (selectedBranchId.value != null) {
      Get.toNamed(AppRoutes.LOGIN);
    } else {
      AppToast.show('Please select a branch');
    }
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
