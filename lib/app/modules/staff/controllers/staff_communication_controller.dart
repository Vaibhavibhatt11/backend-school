import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';

class StaffCommunicationController extends GetxController {
  final chats = <Map<String, String>>[
    {'to': 'Parent - Aarav', 'last': 'Meeting scheduled for Friday.'},
    {'to': 'Student - Riya', 'last': 'Submit notebook by tomorrow.'},
  ].obs;

  final announcements = <String>[
    'Unit test timetable published',
    'Science fair registration open',
  ].obs;

  final meetings = <Map<String, String>>[
    {'title': 'PTM - Grade 8', 'time': 'Fri 4:30 PM'},
    {'title': 'Mentoring session', 'time': 'Mon 11:00 AM'},
  ].obs;

  void sendMessage() => AppToast.show('Message sent (demo).');
  void addMeetingNote() => AppToast.show('Meeting note saved (demo).');
}

