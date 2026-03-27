import 'package:get/get.dart';

class AdminShellController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void setTab(int index) {
    if (index == currentIndex.value) return;
    currentIndex.value = index;
  }
}

