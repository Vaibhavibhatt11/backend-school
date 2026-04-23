import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/core/widgets/custom_app_bar.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_communication_controller.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_attendance_leave_controller.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_class_teaching_controller.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_dashboard_controller.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_homework_assignment_controller.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_lesson_planning_controller.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_exam_assessment_controller.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_performance_monitoring_controller.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_profile_controller.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_reports_controller.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_settings_controller.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_study_material_controller.dart';
import 'package:erp_frontend/app/modules/staff/models/staff_module_catalog.dart';
import 'package:erp_frontend/app/modules/staff/models/staff_study_material_models.dart';
import 'package:erp_frontend/app/modules/staff/utils/staff_portal_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffModuleDetailView extends StatelessWidget {
  const StaffModuleDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final rawArgs = Get.arguments as Map?;
    final args = rawArgs?.cast<String, dynamic>() ?? const {};
    final moduleId = (args['moduleId'] ?? '').toString();
    final module = kStaffModules.firstWhereOrNull(
      (item) => item.id == moduleId,
    );

    if (module == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (moduleId.isNotEmpty) {
          StaffPortalNavigation.openModule(moduleId);
        } else {
          Get.back();
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screens = StaffPortalNavigation.screensForModule(module.id);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: CustomAppBar(
        title: module.title,
        actions: [
          IconButton(
            onPressed: () => _refreshStaffModule(module.id),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshStaffModule(module.id),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _StaffModuleHeader(module: module),
            const SizedBox(height: 16),
            _StaffSectionTitle(title: _staffSnapshotTitle(module.id)),
            const SizedBox(height: 10),
            Obx(
              () => Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _buildStaffMetrics(
                  module.id,
                ).map((metric) => _StaffMetricCard(metric: metric)).toList(),
              ),
            ),
            const SizedBox(height: 20),
            const _StaffSectionTitle(title: 'Available Screens'),
            const SizedBox(height: 10),
            ...screens.map(
              (screen) => _StaffScreenTile(
                title: screen.title,
                description: screen.description,
                onTap: () => StaffPortalNavigation.openScreen(screen),
              ),
            ),
            const SizedBox(height: 20),
            const _StaffSectionTitle(title: 'Module Coverage'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: module.features
                  .map(
                    (feature) => Chip(
                      label: Text(feature),
                      backgroundColor: isDark
                          ? AppColors.surfaceDark
                          : Colors.white,
                      side: BorderSide(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffModuleHeader extends StatelessWidget {
  const _StaffModuleHeader({required this.module});

  final StaffModuleItem module;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(module.icon, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${module.features.length} live workflows connected through staff and teacher screens.',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffSectionTitle extends StatelessWidget {
  const _StaffSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: isDark ? AppColors.textDark : AppColors.textLight,
      ),
    );
  }
}

class _StaffMetricCard extends StatelessWidget {
  const _StaffMetricCard({required this.metric});

  final _StaffMetric metric;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 170,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              metric.label,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              metric.value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              metric.caption,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffScreenTile extends StatelessWidget {
  const _StaffScreenTile({
    required this.title,
    required this.description,
    required this.onTap,
  });

  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: const Icon(
          Icons.open_in_new_rounded,
          color: AppColors.primary,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

class _StaffMetric {
  const _StaffMetric({
    required this.label,
    required this.value,
    required this.caption,
  });

  final String label;
  final String value;
  final String caption;
}

Future<void> _refreshStaffModule(String moduleId) async {
  final dashboard = Get.find<StaffDashboardController>();
  final profile = Get.find<StaffProfileController>();
  final reports = Get.find<StaffReportsController>();
  final communication = Get.find<StaffCommunicationController>();
  final settings = Get.find<StaffSettingsController>();
  final attendanceLeave = Get.find<StaffAttendanceLeaveController>();
  final classTeaching = Get.find<StaffClassTeachingController>();
  final lessonPlanning = Get.find<StaffLessonPlanningController>();
  final homeworkAssignment = Get.find<StaffHomeworkAssignmentController>();
  final examAssessment = Get.find<StaffExamAssessmentController>();
  final performanceMonitoring = Get.find<StaffPerformanceMonitoringController>();
  final studyMaterial = Get.find<StaffStudyMaterialController>();

  switch (moduleId) {
    case 'dashboard':
      await Future.wait([dashboard.loadDashboard(), reports.loadReports()]);
      return;
    case 'attendance_leave':
      attendanceLeave.setTab(0);
      await Future.wait([
        attendanceLeave.loadData(),
        dashboard.loadDashboard(),
        reports.loadReports(),
      ]);
      return;
    case 'class_teaching':
      classTeaching.setTab(0);
      await Future.wait([
        classTeaching.loadData(),
        dashboard.loadDashboard(),
        reports.loadReports(),
      ]);
      return;
    case 'lesson_planning':
      lessonPlanning.setTab(0);
      await Future.wait([
        lessonPlanning.loadData(),
        dashboard.loadDashboard(),
        reports.loadReports(),
      ]);
      return;
    case 'homework_assignment':
      homeworkAssignment.setTab(0);
      await Future.wait([
        homeworkAssignment.loadData(),
        dashboard.loadDashboard(),
        reports.loadReports(),
      ]);
      return;
    case 'exam_assessment':
      examAssessment.setTab(0);
      await Future.wait([
        examAssessment.loadData(),
        dashboard.loadDashboard(),
        reports.loadReports(),
      ]);
      return;
    case 'performance':
      performanceMonitoring.setTab(0);
      await Future.wait([
        performanceMonitoring.loadData(),
        dashboard.loadDashboard(),
        reports.loadReports(),
      ]);
      return;
    case 'study_material':
      await Future.wait([
        studyMaterial.loadInitialData(showErrors: false),
        dashboard.loadDashboard(),
        reports.loadReports(),
      ]);
      return;
    case 'profile':
    case 'payroll_hr':
      await Future.wait([profile.loadProfile(), settings.loadSettings()]);
      return;
    case 'communication_ai':
    case 'events':
    case 'transport':
    case 'hostel':
      await Future.wait([
        communication.loadCommunication(),
        dashboard.loadDashboard(),
      ]);
      return;
    case 'reports':
    case 'library':
    case 'inventory_lab':
      await Future.wait([reports.loadReports(), dashboard.loadDashboard()]);
      return;
    case 'settings':
      await Future.wait([settings.loadSettings(), profile.loadProfile()]);
      return;
    default:
      await Future.wait([
        dashboard.loadDashboard(),
        profile.loadProfile(),
        reports.loadReports(),
        communication.loadCommunication(),
      ]);
  }
}

String _staffSnapshotTitle(String moduleId) {
  switch (moduleId) {
    case 'dashboard':
    case 'profile':
    case 'communication_ai':
    case 'reports':
    case 'settings':
    case 'ai_teaching_assistant':
      return 'Live Module Snapshot';
    default:
      return 'Live Staff Snapshot';
  }
}

List<_StaffMetric> _buildStaffMetrics(String moduleId) {
  final dashboard = Get.find<StaffDashboardController>();
  final profile = Get.find<StaffProfileController>();
  final reports = Get.find<StaffReportsController>();
  final communication = Get.find<StaffCommunicationController>();
  final settings = Get.find<StaffSettingsController>();
  final attendanceLeave = Get.find<StaffAttendanceLeaveController>();
  final classTeaching = Get.find<StaffClassTeachingController>();
  final lessonPlanning = Get.find<StaffLessonPlanningController>();
  final homeworkAssignment = Get.find<StaffHomeworkAssignmentController>();
  final examAssessment = Get.find<StaffExamAssessmentController>();
  final performanceMonitoring = Get.find<StaffPerformanceMonitoringController>();
  final studyMaterial = Get.find<StaffStudyMaterialController>();

  final documentsCount = profile.documentRows.isNotEmpty
      ? profile.documentRows.length
      : profile.documents.length;

  switch (moduleId) {
    case 'dashboard':
      return [
        _StaffMetric(
          label: 'Today Schedule',
          value: '${dashboard.todayScheduleItems.length}',
          caption: 'Timetable items loaded',
        ),
        _StaffMetric(
          label: 'Pending Tasks',
          value: '${dashboard.pendingTasks.length}',
          caption: 'Current staff to-do items',
        ),
        _StaffMetric(
          label: 'Student Alerts',
          value: '${dashboard.studentAlerts.length}',
          caption: 'Live alert entries',
        ),
        _StaffMetric(
          label: 'Notifications',
          value: '${dashboard.notifications.length}',
          caption: 'Dashboard notification items',
        ),
      ];
    case 'profile':
      return [
        _StaffMetric(
          label: 'Department',
          value: profile.department.value.isEmpty
              ? '--'
              : profile.department.value,
          caption: profile.name.value.isEmpty
              ? 'Profile sync in progress'
              : profile.name.value,
        ),
        _StaffMetric(
          label: 'Documents',
          value: '$documentsCount',
          caption: 'Profile documents linked',
        ),
        _StaffMetric(
          label: 'Staff ID',
          value: profile.staffId.value.isEmpty ? '--' : profile.staffId.value,
          caption: 'Live profile identity',
        ),
        _StaffMetric(
          label: 'Experience',
          value: profile.experience.value.isEmpty
              ? '--'
              : profile.experience.value,
          caption: 'Profile experience data',
        ),
      ];
    case 'attendance_leave':
      final metrics = attendanceLeave.reportMetrics();
      return [
        _StaffMetric(
          label: 'Attendance Entries',
          value: '${metrics['total'] ?? 0}',
          caption: 'Staff attendance records',
        ),
        _StaffMetric(
          label: 'Pending Leaves',
          value: '${metrics['leavePending'] ?? 0}',
          caption: 'Applications awaiting approval',
        ),
        _StaffMetric(
          label: 'Late Arrivals',
          value: '${metrics['late'] ?? 0}',
          caption: 'Late marks captured in records',
        ),
        _StaffMetric(
          label: 'Approved Leave',
          value: '${metrics['leaveApproved'] ?? 0}',
          caption: 'Approved leave applications',
        ),
      ];
    case 'class_teaching':
      final m = classTeaching.metrics();
      return [
        _StaffMetric(
          label: 'Class List',
          value: '${m['classes'] ?? 0}',
          caption: 'Total active classes',
        ),
        _StaffMetric(
          label: 'Student List',
          value: '${m['students'] ?? 0}',
          caption: 'Students mapped to classes',
        ),
        _StaffMetric(
          label: 'Subject Assignments',
          value: '${m['assignments'] ?? 0}',
          caption: 'Subject allocation entries',
        ),
        _StaffMetric(
          label: 'Schedules',
          value: '${m['schedules'] ?? 0}',
          caption: 'Classroom schedule slots',
        ),
      ];
    case 'lesson_planning':
      final l = lessonPlanning.metrics();
      return [
        _StaffMetric(
          label: 'Lesson Plans',
          value: '${l['plans'] ?? 0}',
          caption: 'Lesson plans created',
        ),
        _StaffMetric(
          label: 'Topic Schedules',
          value: '${l['topics'] ?? 0}',
          caption: 'Scheduled lesson topics',
        ),
        _StaffMetric(
          label: 'Lesson Notes',
          value: '${l['notes'] ?? 0}',
          caption: 'Saved teaching notes',
        ),
      ];
    case 'homework_assignment':
      final h = homeworkAssignment.metrics();
      return [
        _StaffMetric(
          label: 'Assignments',
          value: '${h['assignments'] ?? 0}',
          caption: 'Created homework and assignments',
        ),
        _StaffMetric(
          label: 'Deadlines',
          value: '${h['deadlines'] ?? 0}',
          caption: 'Configured due dates',
        ),
        _StaffMetric(
          label: 'Submissions',
          value: '${h['submissions'] ?? 0}',
          caption: 'Submission records',
        ),
        _StaffMetric(
          label: 'Feedback',
          value: '${h['feedback'] ?? 0}',
          caption: 'Feedback entries shared',
        ),
      ];
    case 'exam_assessment':
      final e = examAssessment.metrics();
      return [
        _StaffMetric(
          label: 'Exams',
          value: '${e['exams'] ?? 0}',
          caption: 'Exam records created',
        ),
        _StaffMetric(
          label: 'Question Papers',
          value: '${e['papers'] ?? 0}',
          caption: 'Uploaded question papers',
        ),
        _StaffMetric(
          label: 'Marks Entries',
          value: '${e['marks'] ?? 0}',
          caption: 'Marks records captured',
        ),
        _StaffMetric(
          label: 'Results',
          value: '${e['results'] ?? 0}',
          caption: 'Published result records',
        ),
      ];
    case 'study_material':
      return [
        _StaffMetric(
          label: 'Materials',
          value: '${studyMaterial.materials.length}',
          caption: 'Published study material records',
        ),
        _StaffMetric(
          label: 'Notes',
          value:
              '${studyMaterial.countForCategory(StaffStudyMaterialCategory.notes)}',
          caption: 'Uploaded notes available',
        ),
        _StaffMetric(
          label: 'Videos & PDFs',
          value:
              '${studyMaterial.countForCategory(StaffStudyMaterialCategory.videos) + studyMaterial.countForCategory(StaffStudyMaterialCategory.pdfs)}',
          caption: 'Multimedia learning assets',
        ),
        _StaffMetric(
          label: 'Resources',
          value:
              '${studyMaterial.countForCategory(StaffStudyMaterialCategory.resources)}',
          caption: 'Reference links and resources',
        ),
      ];
    case 'performance':
      final p = performanceMonitoring.metrics();
      return [
        _StaffMetric(
          label: 'Marks Tracking',
          value: '${p['marks'] ?? 0}',
          caption: 'Student marks records',
        ),
        _StaffMetric(
          label: 'Attendance',
          value: '${p['attendance'] ?? 0}',
          caption: 'Attendance monitoring records',
        ),
        _StaffMetric(
          label: 'Progress Reports',
          value: '${p['reports'] ?? 0}',
          caption: 'Academic progress report items',
        ),
        _StaffMetric(
          label: 'Weak Students',
          value: '${p['weak'] ?? 0}',
          caption: 'Students flagged for follow-up',
        ),
      ];
    case 'communication_ai':
      return [
        _StaffMetric(
          label: 'Chats',
          value: '${communication.conversationThreads.length}',
          caption: 'Active conversation threads',
        ),
        _StaffMetric(
          label: 'Announcements',
          value: '${communication.liveAnnouncementCount}',
          caption: 'Current posted updates',
        ),
        _StaffMetric(
          label: 'Meetings',
          value: '${communication.scheduledMeetingCount}',
          caption: 'Scheduled PTM records',
        ),
        _StaffMetric(
          label: 'Notifications',
          value: '${communication.unreadNotificationsCount}',
          caption: 'Unread communication alerts',
        ),
      ];
    case 'events':
      return [
        _StaffMetric(
          label: 'Announcements',
          value: '${communication.announcements.length}',
          caption: 'Event communication records',
        ),
        _StaffMetric(
          label: 'Meetings',
          value: '${communication.meetings.length}',
          caption: 'Coordination notes and meetings',
        ),
        _StaffMetric(
          label: 'Pending Tasks',
          value: '${dashboard.pendingTasks.length}',
          caption: 'Follow-up actions on activities',
        ),
        _StaffMetric(
          label: 'Assigned Classes',
          value: '${dashboard.assignedClasses.length}',
          caption: 'Available audience groups',
        ),
      ];
    case 'reports':
      return [
        _StaffMetric(
          label: 'Report Cards',
          value: '${reports.reportTiles.length}',
          caption: 'Analytics tiles loaded',
        ),
        _StaffMetric(
          label: 'Assigned Classes',
          value: '${dashboard.assignedClasses.length}',
          caption: 'Classes contributing to reports',
        ),
        _StaffMetric(
          label: 'Student Alerts',
          value: '${dashboard.studentAlerts.length}',
          caption: 'Current report attention items',
        ),
        _StaffMetric(
          label: 'Today Schedule',
          value: '${dashboard.todayScheduleItems.length}',
          caption: 'Timetable context for reports',
        ),
      ];
    case 'ai_teaching_assistant':
      return [
        _StaffMetric(
          label: 'Pending Tasks',
          value: '${dashboard.pendingTasks.length}',
          caption: 'Tasks AI can help draft or prioritize',
        ),
        _StaffMetric(
          label: 'Notifications',
          value: '${dashboard.notifications.length}',
          caption: 'Items to respond to faster',
        ),
        _StaffMetric(
          label: 'Assigned Classes',
          value: '${dashboard.assignedClasses.length}',
          caption: 'Teaching scope for prompts',
        ),
        _StaffMetric(
          label: 'Reports',
          value: '${reports.reportTiles.length}',
          caption: 'Analytics context available to staff',
        ),
      ];
    case 'settings':
      return [
        _StaffMetric(
          label: 'Notifications',
          value: settings.notificationsEnabled.value ? 'On' : 'Off',
          caption: 'Push notification preference',
        ),
        _StaffMetric(
          label: 'Privacy',
          value: settings.privacyMode.value ? 'On' : 'Off',
          caption: 'Privacy mode status',
        ),
        _StaffMetric(
          label: 'Compact View',
          value: settings.compactView.value ? 'On' : 'Off',
          caption: 'Layout density mode',
        ),
        _StaffMetric(
          label: 'Department',
          value: profile.department.value.isEmpty
              ? '--'
              : profile.department.value,
          caption: 'Profile context for settings',
        ),
      ];
    default:
      return [
        _StaffMetric(
          label: 'Assigned Classes',
          value: '${dashboard.assignedClasses.length}',
          caption: 'Live class context',
        ),
        _StaffMetric(
          label: 'Pending Tasks',
          value: '${dashboard.pendingTasks.length}',
          caption: 'Open workload items',
        ),
        _StaffMetric(
          label: 'Reports',
          value: '${reports.reportTiles.length}',
          caption: 'Current analytics cards',
        ),
        _StaffMetric(
          label: 'Announcements',
          value: '${communication.announcements.length}',
          caption: 'Latest communication records',
        ),
      ];
  }
}
