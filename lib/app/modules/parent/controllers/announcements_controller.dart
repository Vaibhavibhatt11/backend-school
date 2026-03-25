import 'package:get/get.dart';

class AnnouncementsController extends GetxController {
  final selectedFilter = 'All'.obs;

  final announcements =
      [
        {
          'type': 'urgent',
          'title': 'Emergency Water Main Repair',
          'description':
              'Main entrance will be closed for the next 2 hours. Please use the South Gate for student pickup...',
          'postedBy': 'Admin',
          'time': '12m ago',
          'urgent': true,
        },
        {
          'type': 'teacher',
          'teacherName': 'Mrs. Henderson',
          'teacherClass': 'Grade 4B',
          'time': '2h ago',
          'title': 'Weekly Science Project Materials',
          'description':
              'Friendly reminder that we need cardboard boxes and plastic caps for Friday\'s robot building session. Looking forward to seeing the creations!',
          'attachment': 'Project_Guide.pdf',
        },
        // ... more
      ].obs;

  void setFilter(String filter) => selectedFilter.value = filter;
}
