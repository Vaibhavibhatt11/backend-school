import 'package:get/get.dart';

class StudentHealthController extends GetxController {
  final RxString bloodGroup = 'B+'.obs;
  final RxString allergy = 'Dust allergy'.obs;
  final RxString chronicCondition = 'None'.obs;
  final RxString emergencyContact = '+91 98111 22233'.obs;
  final RxString preferredHospital = 'City Care Hospital'.obs;

  final RxList<Map<String, String>> records = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    records.assignAll([
      {
        'title': 'Annual Health Checkup',
        'date': '12 Jan 2026',
        'doctor': 'Dr. R. Shah',
        'summary': 'General checkup normal. Advised hydration and regular sleep.',
        'vitals': 'Height 152 cm • Weight 44 kg • BMI 19.0',
      },
      {
        'title': 'Eye Screening',
        'date': '08 Nov 2025',
        'doctor': 'Dr. M. Patel',
        'summary': 'Mild eye strain observed. Recommended screen break every 30 mins.',
        'vitals': 'Vision 6/6 (L), 6/9 (R)',
      },
      {
        'title': 'Sports Fitness Test',
        'date': '22 Aug 2025',
        'doctor': 'School Medical Team',
        'summary': 'Fit for all school sports activities.',
        'vitals': 'Pulse 78 bpm • BP 108/70',
      },
    ]);
  }
}
