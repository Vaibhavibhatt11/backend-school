import 'package:get/get.dart';

class StaffShellController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void setTab(int index) {
    if (currentIndex.value == index) return;
    currentIndex.value = index;
  }
}

