/// An upcoming exam (for timeline).
class UpcomingExam {
  const UpcomingExam({
    required this.id,
    required this.subject,
    required this.date,
    this.time,
    this.syllabus,
  });

  final String id;
  final String subject;
  final DateTime date;
  final String? time;
  final String? syllabus;
}

/// A past exam with marks/result.
class PastExam {
  const PastExam({
    required this.id,
    required this.subject,
    required this.examName,
    required this.date,
    required this.marksObtained,
    required this.maxMarks,
    this.grade,
  });

  final String id;
  final String subject;
  final String examName;
  final DateTime date;
  final double marksObtained;
  final double maxMarks;
  final String? grade;

  double get percentage => maxMarks > 0 ? (marksObtained / maxMarks) * 100 : 0;
}

class ReportCardItem {
  const ReportCardItem({
    required this.id,
    required this.term,
    required this.academicYear,
    required this.overallPercentage,
    required this.overallGrade,
    required this.publishedOn,
    required this.pdfName,
  });

  final String id;
  final String term;
  final String academicYear;
  final double overallPercentage;
  final String overallGrade;
  final DateTime publishedOn;
  final String pdfName;
}

class SubjectPerformanceItem {
  const SubjectPerformanceItem({
    required this.subject,
    required this.averagePercentage,
    required this.currentGrade,
    required this.examsTaken,
  });

  final String subject;
  final double averagePercentage;
  final String currentGrade;
  final int examsTaken;
}
