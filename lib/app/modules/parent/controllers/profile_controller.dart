import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final studentName = 'Arjun Malhotra'.obs;
  final studentClass = 'Class 10-B • Roll 2024082'.obs;
  final academicYear = 'Academic Year 2023-24'.obs;
  final dob = '14 May 2008'.obs;
  final bloodGroup = 'O Positive (O+)'.obs;
  final fatherName = 'Rajesh Malhotra'.obs;
  final motherName = 'Suman Malhotra'.obs;
  final currentTermGrade = 'A+'.obs;
  final currentTermPercentage = 92.4.obs;
  final classAvg = 78.0.obs;

  final documents =
      [
        {
          'name': 'Aadhar Card',
          'status': 'Verified',
          'size': '1.2 MB',
          'icon': 'description',
        },
        {
          'name': 'Birth Certificate',
          'status': 'Verified',
          'size': '0.8 MB',
          'icon': 'badge',
        },
      ].obs;

  void editPersonal() => Get.snackbar('Edit', 'Edit personal info');
  void editGuardian() => Get.snackbar('Edit', 'Edit guardian info');
  void viewAllDocuments() => Get.snackbar('Documents', 'All documents list');
  void downloadDocument(String docName) =>
      Get.snackbar('Download', 'Downloading $docName');
  void openSettings() => Get.toNamed(AppRoutes.PARENT_SETTINGS);
  void goToLibrary() => Get.toNamed(AppRoutes.PARENT_LIBRARY);

  void viewDocument(String docName) => Get.toNamed(
    AppRoutes.PARENT_DOCUMENT_VIEWER,
    arguments: {'document': docName},
  );
}
