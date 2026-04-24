import 'package:get/get.dart';
import 'models/exam_models.dart';

class StudentExamsController extends GetxController {
  final RxList<UpcomingExam> upcomingExams = <UpcomingExam>[].obs;
  final RxList<PastExam> pastExams = <PastExam>[].obs;
  final RxList<ReportCardItem> reportCards = <ReportCardItem>[].obs;
  final RxList<SubjectPerformanceItem> subjectPerformance = <SubjectPerformanceItem>[].obs;
  final selectedTab = 0.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _seedData();
  }

  void setTab(int index) => selectedTab.value = index;
  void setSearchQuery(String value) => searchQuery.value = value.trim().toLowerCase();

  List<UpcomingExam> get filteredUpcoming {
    if (searchQuery.value.isEmpty) return upcomingExams;
    return upcomingExams
        .where((e) => ('${e.subject} ${e.time ?? ''} ${e.syllabus ?? ''}')
            .toLowerCase()
            .contains(searchQuery.value))
        .toList();
  }

  List<PastExam> get filteredPast {
    if (searchQuery.value.isEmpty) return pastExams;
    return pastExams
        .where((e) => ('${e.subject} ${e.examName} ${e.grade ?? ''}')
            .toLowerCase()
            .contains(searchQuery.value))
        .toList();
  }

  List<PastExam> get gradeHistory {
    final list = pastExams.toList()..sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  void _seedData() {
    final now = DateTime.now();
    upcomingExams.assignAll([
      UpcomingExam(
        id: 'u1',
        subject: 'Mathematics',
        date: DateTime(now.year, now.month, now.day + 3),
        time: '09:00 AM - 11:00 AM',
        syllabus: 'Ch 5, 6, 7',
      ),
      UpcomingExam(
        id: 'u2',
        subject: 'Science',
        date: DateTime(now.year, now.month, now.day + 5),
        time: '11:30 AM - 01:30 PM',
        syllabus: 'Physics Unit 2, Chemistry Unit 1',
      ),
      UpcomingExam(
        id: 'u3',
        subject: 'English',
        date: DateTime(now.year, now.month, now.day + 8),
        time: '09:00 AM - 10:30 AM',
        syllabus: 'Grammar + Writing',
      ),
    ]);

    pastExams.assignAll([
      PastExam(
        id: 'p1',
        subject: 'Mathematics',
        examName: 'Unit Test 1',
        date: DateTime(now.year, now.month - 2, 12),
        marksObtained: 42,
        maxMarks: 50,
        grade: 'A',
      ),
      PastExam(
        id: 'p2',
        subject: 'Science',
        examName: 'Unit Test 1',
        date: DateTime(now.year, now.month - 2, 15),
        marksObtained: 39,
        maxMarks: 50,
        grade: 'B+',
      ),
      PastExam(
        id: 'p3',
        subject: 'English',
        examName: 'Unit Test 1',
        date: DateTime(now.year, now.month - 2, 18),
        marksObtained: 44,
        maxMarks: 50,
        grade: 'A',
      ),
      PastExam(
        id: 'p4',
        subject: 'Mathematics',
        examName: 'Term 1',
        date: DateTime(now.year, now.month - 1, 10),
        marksObtained: 86,
        maxMarks: 100,
        grade: 'A',
      ),
      PastExam(
        id: 'p5',
        subject: 'Science',
        examName: 'Term 1',
        date: DateTime(now.year, now.month - 1, 12),
        marksObtained: 79,
        maxMarks: 100,
        grade: 'B+',
      ),
    ]);

    reportCards.assignAll([
      ReportCardItem(
        id: 'r1',
        term: 'Term 1',
        academicYear: '2025-26',
        overallPercentage: 82.4,
        overallGrade: 'A',
        publishedOn: DateTime(now.year, now.month - 1, 25),
        pdfName: 'term1_report_card.pdf',
      ),
      ReportCardItem(
        id: 'r2',
        term: 'Unit Test 1',
        academicYear: '2025-26',
        overallPercentage: 84.8,
        overallGrade: 'A',
        publishedOn: DateTime(now.year, now.month - 2, 22),
        pdfName: 'ut1_report_card.pdf',
      ),
    ]);

    final bySubject = <String, List<PastExam>>{};
    for (final p in pastExams) {
      bySubject.putIfAbsent(p.subject, () => []).add(p);
    }
    subjectPerformance.assignAll(
      bySubject.entries.map((e) {
        final exams = e.value;
        final avg = exams.isEmpty
            ? 0.0
            : exams.map((x) => x.percentage).reduce((a, b) => a + b) / exams.length;
        final grade = avg >= 90
            ? 'A+'
            : avg >= 80
                ? 'A'
                : avg >= 70
                    ? 'B'
                    : avg >= 60
                        ? 'C'
                        : 'D';
        return SubjectPerformanceItem(
          subject: e.key,
          averagePercentage: avg,
          currentGrade: grade,
          examsTaken: exams.length,
        );
      }),
    );
  }
}
