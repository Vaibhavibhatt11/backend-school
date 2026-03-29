import 'package:get/get.dart';

class StaffProfileController extends GetxController {
  final name = 'Neha Sharma'.obs;
  final department = 'Science'.obs;
  final qualification = 'M.Sc, B.Ed'.obs;
  final experience = '8 years'.obs;
  final contact = '+91 98xxxxxx12'.obs;
  final email = 'staff@gmail.com'.obs;
  final documents = <String>[
    'Joining Letter.pdf',
    'Education Certificates.pdf',
    'ID Card.png',
  ].obs;
}

