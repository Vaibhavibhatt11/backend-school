import 'package:get/get.dart';

class StudentProfileController extends GetxController {
  final RxString selectedTab = 'Personal'.obs;

  void setTab(String tab) => selectedTab.value = tab;
}
