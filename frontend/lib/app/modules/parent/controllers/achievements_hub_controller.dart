import 'package:get/get.dart';

class AchievementsHubController extends GetxController {
  final selectedTab = 'academic'.obs;

  final academicAchievements = <Map<String, String>>[
    {'title': 'Top 5 in Mathematics', 'date': 'Jan 2026', 'by': 'Class Teacher'},
    {'title': 'Excellent Attendance Award', 'date': 'Dec 2025', 'by': 'School Admin'},
  ].obs;

  final competitionCertificates = <Map<String, String>>[
    {'title': 'Science Model Contest - Runner Up', 'date': 'Feb 2026', 'file': 'science-certificate.pdf'},
    {'title': 'Debate Competition - Winner', 'date': 'Nov 2025', 'file': 'debate-certificate.pdf'},
  ].obs;

  final activityRecords = <Map<String, String>>[
    {'title': 'Eco Club Participation', 'date': 'Jan 2026', 'remarks': 'Active participation'},
    {'title': 'Sports Practice Camp', 'date': 'Dec 2025', 'remarks': 'Good consistency'},
  ].obs;

  final digitalCertificates = <Map<String, String>>[
    {'title': 'Coding Bootcamp Completion', 'issuedBy': 'School LMS', 'id': 'CERT-22031'},
    {'title': 'Reading Marathon', 'issuedBy': 'Library Dept', 'id': 'CERT-19812'},
  ].obs;

  void changeTab(String tab) => selectedTab.value = tab;
}
