import 'package:get/get.dart';

class DocumentViewerController extends GetxController {
  final documentTitle = 'Term 1 Report Card'.obs;
  final studentName = 'Arjun Sharma'.obs;
  final studentClass = 'Grade 10-B'.obs;
  final currentPage = 1.obs;
  final totalPages = 2.obs;

  void nextPage() {
    if (currentPage.value < totalPages.value) currentPage.value++;
  }

  void prevPage() {
    if (currentPage.value > 1) currentPage.value--;
  }

  void download() => Get.snackbar('Download', 'Downloading document...');
  void share() => Get.snackbar('Share', 'Sharing document...');
  void print() => Get.snackbar('Print', 'Printing document...');
}
