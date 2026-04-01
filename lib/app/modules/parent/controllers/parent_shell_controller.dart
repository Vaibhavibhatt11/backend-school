import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';

class ParentShellController extends GetxController {
  final RxInt currentIndex = 0.obs;

  static const Map<String, int> _routeIndexMap = {
    AppRoutes.PARENT_HOME: 0,
    AppRoutes.PARENT_ATTENDANCE: 1,
    AppRoutes.PARENT_FEES: 2,
    AppRoutes.PARENT_TIMETABLE: 3,
    AppRoutes.PARENT_PROFILE: 4,
  };

  static int resolveIndex(String route, {dynamic arguments}) {
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

    return _routeIndexMap[route] ?? 0;
  }

  void setTab(int index) {
    if (index < 0 || index > 4 || currentIndex.value == index) {
      return;
    }
    currentIndex.value = index;
  }
}
