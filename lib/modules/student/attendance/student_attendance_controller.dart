import 'package:get/get.dart';
import 'models/attendance_report_models.dart';

class StudentAttendanceController extends GetxController {
  // Daily
  final RxBool todayPresent = true.obs;
  final RxInt lateEntries = 2.obs;

  // Report period: daily | week | month | year
  final RxString reportPeriod = 'daily'.obs;

  // Pinch zoom level: 0=Today, 1=Week, 2=Month, 3=Year (synced with reportPeriod)
  final RxInt zoomLevel = 0.obs;

  // Selected period for reports
  final Rx<DateTime> selectedWeekStart = Rx<DateTime>(_startOfWeek(DateTime.now()));
  final Rx<DateTime> selectedMonth = Rx<DateTime>(DateTime(DateTime.now().year, DateTime.now().month));
  final RxInt selectedYear = RxInt(DateTime.now().year);

  // Reports (reactive)
  final Rx<WeekReport?> weekReport = Rx<WeekReport?>(null);
  final Rx<MonthReport?> monthReport = Rx<MonthReport?>(null);
  final Rx<YearReport?> yearReport = Rx<YearReport?>(null);

  // Leave applications
  final RxList<LeaveApplication> leaveApplications = <LeaveApplication>[].obs;

  static DateTime _startOfWeek(DateTime d) {
    final weekday = d.weekday;
    return DateTime(d.year, d.month, d.day - (weekday - 1));
  }

  @override
  void onInit() {
    super.onInit();
    loadWeekReport();
    loadMonthReport();
    loadYearReport();
    _seedLeaveApplications();
  }

  void _seedLeaveApplications() {
    leaveApplications.assignAll([
      LeaveApplication(
        id: 'L1',
        type: 'Sick',
        reason: 'Fever and doctor advised rest.',
        fromDate: DateTime.now().subtract(const Duration(days: 12)),
        toDate: DateTime.now().subtract(const Duration(days: 10)),
        status: 'Approved',
        appliedAt: DateTime.now().subtract(const Duration(days: 13)),
      ),
      LeaveApplication(
        id: 'L2',
        type: 'Casual',
        reason: 'Family function out of town.',
        fromDate: DateTime.now().add(const Duration(days: 5)),
        toDate: DateTime.now().add(const Duration(days: 6)),
        status: 'Pending',
        appliedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);
  }

  void setReportPeriod(String period) {
    reportPeriod.value = period;
    final index = ['daily', 'week', 'month', 'year'].indexOf(period);
    if (index >= 0) zoomLevel.value = index;
  }

  /// Pinch out: go to wider view (Today → Week → Month → Year).
  void zoomOut() {
    if (zoomLevel.value < 3) {
      zoomLevel.value++;
      reportPeriod.value = ['daily', 'week', 'month', 'year'][zoomLevel.value];
    }
  }

  /// Pinch in: go to narrower view (Year → Month → Week → Today).
  void zoomIn() {
    if (zoomLevel.value > 0) {
      zoomLevel.value--;
      reportPeriod.value = ['daily', 'week', 'month', 'year'][zoomLevel.value];
    }
  }

  void setSelectedWeek(DateTime weekStart) {
    selectedWeekStart.value = weekStart;
    loadWeekReport();
  }

  void setSelectedMonth(DateTime month) {
    selectedMonth.value = DateTime(month.year, month.month);
    loadMonthReport();
  }

  void setSelectedYear(int year) {
    selectedYear.value = year;
    loadYearReport();
  }

  void loadWeekReport() {
    final start = selectedWeekStart.value;
    final end = start.add(const Duration(days: 6));
    // Mock: 5 working days, 4 present, 1 absent, 0 holidays, 1 late
    final days = <DayRecord>[];
    for (int i = 0; i < 7; i++) {
      final d = start.add(Duration(days: i));
      final isWeekend = d.weekday == 6 || d.weekday == 7;
      days.add(DayRecord(
        date: d,
        isPresent: !isWeekend && i < 4,
        isHoliday: false,
        isLate: i == 2,
      ));
    }
    weekReport.value = WeekReport(
      weekStart: start,
      weekEnd: end,
      workingDays: 5,
      presentDays: 4,
      absentDays: 1,
      holidays: 0,
      lateEntries: 1,
      dayRecords: days,
    );
  }

  void loadMonthReport() {
    final y = selectedMonth.value.year;
    final m = selectedMonth.value.month;
    // Mock: 22 working days, 18 present, 2 absent, 2 holidays, 2 late
    monthReport.value = MonthReport(
      year: y,
      month: m,
      workingDays: 22,
      presentDays: 18,
      absentDays: 2,
      holidays: 2,
      lateEntries: 2,
    );
  }

  void loadYearReport() {
    final y = selectedYear.value;
    final months = <MonthReport>[];
    int tw = 0, tp = 0, ta = 0, th = 0, tl = 0;
    for (int m = 1; m <= 12; m++) {
      final w = 20 + (m % 3);
      final p = w - (m % 2);
      final a = (m % 2);
      final hol = (m % 4 == 0 ? 1 : 0);
      months.add(MonthReport(
        year: y,
        month: m,
        workingDays: w,
        presentDays: p,
        absentDays: a,
        holidays: hol,
        lateEntries: m % 3,
      ));
      tw += w;
      tp += p;
      ta += a;
      th += hol;
      tl += m % 3;
    }
    yearReport.value = YearReport(
      year: y,
      totalWorkingDays: tw,
      totalPresentDays: tp,
      totalAbsentDays: ta,
      totalHolidays: th,
      totalLateEntries: tl,
      months: months,
    );
  }

  /// Previous/next week (move by 7 days).
  void previousWeek() => setSelectedWeek(selectedWeekStart.value.subtract(const Duration(days: 7)));
  void nextWeek() => setSelectedWeek(selectedWeekStart.value.add(const Duration(days: 7)));

  /// Previous/next month.
  void previousMonth() {
    final d = selectedMonth.value;
    if (d.month == 1) {
      setSelectedMonth(DateTime(d.year - 1, 12));
    } else {
      setSelectedMonth(DateTime(d.year, d.month - 1));
    }
  }

  void nextMonth() {
    final d = selectedMonth.value;
    if (d.month == 12) {
      setSelectedMonth(DateTime(d.year + 1, 1));
    } else {
      setSelectedMonth(DateTime(d.year, d.month + 1));
    }
  }

  void previousYear() => setSelectedYear(selectedYear.value - 1);
  void nextYear() => setSelectedYear(selectedYear.value + 1);

  /// Navigate to month view for the given month (e.g. when user taps a month in year view).
  void goToMonthView(int year, int month) {
    setSelectedMonth(DateTime(year, month));
    setReportPeriod('month');
  }

  /// Navigate to week view for the week containing the given date.
  void goToWeekView(DateTime date) {
    setSelectedWeek(_startOfWeek(date));
    setReportPeriod('week');
  }

  /// Get day record for any date. Uses current week report if date is in that week, else mock.
  DayRecord getDayRecordForDate(DateTime date) {
    final week = weekReport.value;
    if (week != null) {
      for (final r in week.dayRecords) {
        if (_isSameDay(r.date, date)) return r;
      }
    }
    final isWeekend = date.weekday == 6 || date.weekday == 7;
    return DayRecord(
      date: date,
      isPresent: !isWeekend,
      isHoliday: false,
      isLate: false,
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String? validateLeave({
    required String type,
    required String reason,
    required DateTime? fromDate,
    required DateTime? toDate,
  }) {
    if (type.trim().isEmpty) return 'Please select leave type.';
    if (fromDate == null || toDate == null) return 'Please select date range.';
    if (toDate.isBefore(fromDate)) return 'To date cannot be before from date.';
    if (reason.trim().length < 6) return 'Please enter a valid reason.';
    return null;
  }

  void applyLeave({
    required String type,
    required String reason,
    required DateTime fromDate,
    required DateTime toDate,
  }) {
    final app = LeaveApplication(
      id: 'L${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      reason: reason.trim(),
      fromDate: fromDate,
      toDate: toDate,
      status: 'Pending',
      appliedAt: DateTime.now(),
    );
    leaveApplications.insert(0, app);
  }
}
