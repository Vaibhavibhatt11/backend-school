/// Week-level attendance report.
class WeekReport {
  const WeekReport({
    required this.weekStart,
    required this.weekEnd,
    required this.workingDays,
    required this.presentDays,
    required this.absentDays,
    required this.holidays,
    required this.lateEntries,
    this.dayRecords = const [],
  });

  final DateTime weekStart;
  final DateTime weekEnd;
  final int workingDays;
  final int presentDays;
  final int absentDays;
  final int holidays;
  final int lateEntries;
  final List<DayRecord> dayRecords;

  int get totalDays => workingDays + holidays;
  double get attendancePercent => workingDays > 0 ? (presentDays / workingDays * 100) : 0.0;
}

/// Month-level attendance report.
class MonthReport {
  const MonthReport({
    required this.year,
    required this.month,
    required this.workingDays,
    required this.presentDays,
    required this.absentDays,
    required this.holidays,
    required this.lateEntries,
    this.weekSummaries = const [],
  });

  final int year;
  final int month;
  final int workingDays;
  final int presentDays;
  final int absentDays;
  final int holidays;
  final int lateEntries;
  final List<WeekReport> weekSummaries;

  int get totalDays => workingDays + holidays;
  double get attendancePercent => workingDays > 0 ? (presentDays / workingDays * 100) : 0.0;
  String get monthName {
    const names = ['January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];
    return names[month - 1];
  }
}

/// Year-level attendance report (aggregate + per month).
class YearReport {
  const YearReport({
    required this.year,
    required this.totalWorkingDays,
    required this.totalPresentDays,
    required this.totalAbsentDays,
    required this.totalHolidays,
    required this.totalLateEntries,
    required this.months,
  });

  final int year;
  final int totalWorkingDays;
  final int totalPresentDays;
  final int totalAbsentDays;
  final int totalHolidays;
  final int totalLateEntries;
  final List<MonthReport> months;

  double get attendancePercent =>
      totalWorkingDays > 0 ? (totalPresentDays / totalWorkingDays * 100) : 0.0;
}

/// Single day record (for week zoom).
class DayRecord {
  const DayRecord({
    required this.date,
    required this.isPresent,
    required this.isHoliday,
    this.isLate = false,
  });

  final DateTime date;
  final bool isPresent;
  final bool isHoliday;
  final bool isLate;
}

/// Leave request record for the student.
class LeaveApplication {
  const LeaveApplication({
    required this.id,
    required this.type,
    required this.reason,
    required this.fromDate,
    required this.toDate,
    required this.status,
    required this.appliedAt,
  });

  final String id;
  final String type; // e.g. Sick, Casual
  final String reason;
  final DateTime fromDate;
  final DateTime toDate;
  final String status; // Pending, Approved, Rejected
  final DateTime appliedAt;
}
