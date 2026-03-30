import 'package:get/get.dart';
import 'models/attendance_report_models.dart';

class StudentAttendanceController extends GetxController {
  final RxBool todayPresent = false.obs;
  final RxInt lateEntries = 0.obs;

  // Report period: daily | week | month | year
  final RxString reportPeriod = 'daily'.obs;

  // Pinch zoom level: 0=Today, 1=Week, 2=Month, 3=Year
  final RxInt zoomLevel = 0.obs;

  final Rx<DateTime> selectedWeekStart = Rx<DateTime>(_startOfWeek(DateTime.now()));
  final Rx<DateTime> selectedMonth = Rx<DateTime>(DateTime(DateTime.now().year, DateTime.now().month));
  final RxInt selectedYear = RxInt(DateTime.now().year);

  final Rx<WeekReport?> weekReport = Rx<WeekReport?>(null);
  final Rx<MonthReport?> monthReport = Rx<MonthReport?>(null);
  final Rx<YearReport?> yearReport = Rx<YearReport?>(null);

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
    leaveApplications.clear();
  }

  void setReportPeriod(String period) {
    reportPeriod.value = period;
    final index = ['daily', 'week', 'month', 'year'].indexOf(period);
    if (index >= 0) zoomLevel.value = index;
  }

  void zoomOut() {
    if (zoomLevel.value < 3) {
      zoomLevel.value++;
      reportPeriod.value = ['daily', 'week', 'month', 'year'][zoomLevel.value];
    }
  }

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
    final days = <DayRecord>[];
    for (int i = 0; i < 7; i++) {
      final d = start.add(Duration(days: i));
      final isWeekend = d.weekday == 6 || d.weekday == 7;
      days.add(
        DayRecord(
          date: d,
          isPresent: false,
          isHoliday: isWeekend,
          isLate: false,
        ),
      );
    }
    weekReport.value = WeekReport(
      weekStart: start,
      weekEnd: end,
      workingDays: 0,
      presentDays: 0,
      absentDays: 0,
      holidays: days.where((d) => d.isHoliday).length,
      lateEntries: 0,
      dayRecords: days,
    );
  }

  void loadMonthReport() {
    final y = selectedMonth.value.year;
    final m = selectedMonth.value.month;
    monthReport.value = MonthReport(
      year: y,
      month: m,
      workingDays: 0,
      presentDays: 0,
      absentDays: 0,
      holidays: 0,
      lateEntries: 0,
    );
  }

  void loadYearReport() {
    final y = selectedYear.value;
    final months = <MonthReport>[];
    for (int m = 1; m <= 12; m++) {
      months.add(
        MonthReport(
          year: y,
          month: m,
          workingDays: 0,
          presentDays: 0,
          absentDays: 0,
          holidays: 0,
          lateEntries: 0,
        ),
      );
    }
    yearReport.value = YearReport(
      year: y,
      totalWorkingDays: 0,
      totalPresentDays: 0,
      totalAbsentDays: 0,
      totalHolidays: 0,
      totalLateEntries: 0,
      months: months,
    );
  }

  void previousWeek() => setSelectedWeek(selectedWeekStart.value.subtract(const Duration(days: 7)));
  void nextWeek() => setSelectedWeek(selectedWeekStart.value.add(const Duration(days: 7)));

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

  void goToMonthView(int year, int month) {
    setSelectedMonth(DateTime(year, month));
    setReportPeriod('month');
  }

  void goToWeekView(DateTime date) {
    setSelectedWeek(_startOfWeek(date));
    setReportPeriod('week');
  }

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
      isPresent: false,
      isHoliday: isWeekend,
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
