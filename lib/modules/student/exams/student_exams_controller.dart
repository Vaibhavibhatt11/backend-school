import 'package:get/get.dart';
import 'models/exam_models.dart';

class StudentExamsController extends GetxController {
  final RxList<UpcomingExam> upcomingExams = <UpcomingExam>[].obs;
  final RxList<PastExam> pastExams = <PastExam>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() {
    final now = DateTime.now();
    upcomingExams.assignAll([
      UpcomingExam(
        id: 'u1',
        subject: 'Mathematics',
        date: now.add(const Duration(days: 5)),
        time: '10:00 AM',
        syllabus: 'Ch 1–7',
      ),
      UpcomingExam(
        id: 'u2',
        subject: 'Science',
        date: now.add(const Duration(days: 8)),
        time: '10:00 AM',
        syllabus: 'Physics & Chemistry units',
      ),
      UpcomingExam(
        id: 'u3',
        subject: 'English',
        date: now.add(const Duration(days: 12)),
        time: '10:00 AM',
        syllabus: 'Literature & grammar',
      ),
      UpcomingExam(
        id: 'u4',
        subject: 'Social Studies',
        date: now.add(const Duration(days: 15)),
        time: '10:00 AM',
      ),
    ]);
    pastExams.assignAll([
      PastExam(
        id: 'p1',
        subject: 'Mathematics',
        examName: 'Term 1 – Unit test',
        date: now.subtract(const Duration(days: 30)),
        marksObtained: 42,
        maxMarks: 50,
        grade: 'A',
      ),
      PastExam(
        id: 'p2',
        subject: 'Science',
        examName: 'Term 1 – Half yearly',
        date: now.subtract(const Duration(days: 45)),
        marksObtained: 78,
        maxMarks: 100,
        grade: 'B+',
      ),
      PastExam(
        id: 'p3',
        subject: 'English',
        examName: 'Term 1 – Unit test',
        date: now.subtract(const Duration(days: 35)),
        marksObtained: 38,
        maxMarks: 50,
        grade: 'A',
      ),
      PastExam(
        id: 'p4',
        subject: 'Hindi',
        examName: 'Term 1 – Half yearly',
        date: now.subtract(const Duration(days: 40)),
        marksObtained: 72,
        maxMarks: 100,
        grade: 'B+',
      ),
    ]);
  }
}
