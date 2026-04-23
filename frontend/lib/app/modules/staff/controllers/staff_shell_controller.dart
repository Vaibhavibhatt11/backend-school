import 'package:get/get.dart';

class StaffShellController extends GetxController {
  final RxInt currentIndex = 0.obs;

  static int resolveIndex({dynamic arguments}) {
    final args = arguments;
    if (args is Map) {
      final rawIndex = args['tabIndex'];
      if (rawIndex is int && rawIndex >= 0 && rawIndex <= 4) {
        return rawIndex;
      }
      if (rawIndex is num) {
        final index = rawIndex.toInt();
        if (index >= 0 && index <= 4) {
          return index;
        }
      }
    }
    return 0;
  }

  void setTab(int index) {
    if (index < 0 || index > 4 || currentIndex.value == index) return;
    currentIndex.value = index;
  }
}
