import 'package:get/get.dart';
import '../data/providers/api_provider.dart';
import '../data/repositories/user_repository.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ApiProvider(), permanent: true);
    Get.put(UserRepository(), permanent: true);
  }
}