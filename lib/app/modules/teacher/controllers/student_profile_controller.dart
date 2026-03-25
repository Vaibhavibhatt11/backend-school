import 'package:erp_frontend/app/modules/teacher/models/teacher_models.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentProfileController extends GetxController {
  late Student student;

  @override
  void onInit() {
    super.onInit();
    student = Get.arguments as Student;
  }

  void callParent(String phone) async {
    final Uri telUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      Get.snackbar('Error', 'Could not launch phone');
    }
  }

  void messageParent(String phone) async {
    final Uri smsUri = Uri(scheme: 'sms', path: phone);
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      Get.snackbar('Error', 'Could not launch SMS');
    }
  }

  void uploadDocument() {
    Get.to(AppRoutes.TEACHER_UPLOAD, arguments: student);
  }
}
