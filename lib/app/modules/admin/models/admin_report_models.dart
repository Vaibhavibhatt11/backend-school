enum AdminReportKind {
  attendance,
  fees,
  academic,
  staff,
  transport,
  productivity,
  progress,
  all,
}

extension AdminReportKindLabel on AdminReportKind {
  String get title {
    switch (this) {
      case AdminReportKind.attendance:
        return 'Attendance Report';
      case AdminReportKind.fees:
        return 'Fee Collections';
      case AdminReportKind.academic:
        return 'Academic Report';
      case AdminReportKind.staff:
        return 'Staff Directory';
      case AdminReportKind.transport:
        return 'Transport Report';
      case AdminReportKind.productivity:
        return 'Staff Productivity';
      case AdminReportKind.progress:
        return 'Student Progress';
      case AdminReportKind.all:
        return 'All Reports Dashboard';
    }
  }

  String get fileStem {
    switch (this) {
      case AdminReportKind.attendance:
        return 'attendance-report';
      case AdminReportKind.fees:
        return 'fee-report';
      case AdminReportKind.academic:
        return 'academic-report';
      case AdminReportKind.staff:
        return 'staff-report';
      case AdminReportKind.transport:
        return 'transport-report';
      case AdminReportKind.productivity:
        return 'staff-productivity';
      case AdminReportKind.progress:
        return 'student-progress';
      case AdminReportKind.all:
        return 'all-reports-dashboard';
    }
  }
}

class AdminReportMetric {
  const AdminReportMetric({
    required this.label,
    required this.value,
    this.helper,
  });

  final String label;
  final String value;
  final String? helper;
}

class AdminReportSection {
  const AdminReportSection({
    required this.title,
    required this.columns,
    required this.rows,
  });

  final String title;
  final List<String> columns;
  final List<List<String>> rows;
}

class AdminReportPayload {
  const AdminReportPayload({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.generatedAt,
    required this.metrics,
    required this.sections,
    this.emptyMessage = 'No records found for the selected filters.',
  });

  final AdminReportKind kind;
  final String title;
  final String subtitle;
  final DateTime generatedAt;
  final List<AdminReportMetric> metrics;
  final List<AdminReportSection> sections;
  final String emptyMessage;

  bool get hasContent =>
      metrics.isNotEmpty || sections.any((section) => section.rows.isNotEmpty);
}
