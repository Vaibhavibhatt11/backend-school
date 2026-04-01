import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_approvals_controller.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_attendance_controller.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_audit_logs_controller.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_dashboard_controller.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_fee_snapshot_controller.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_notice_board_controller.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_profile_controller.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_reports_controller.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_settings_controller.dart';
import 'package:erp_frontend/app/modules/admin/models/admin_module_catalog.dart';
import 'package:erp_frontend/app/modules/admin/utils/admin_portal_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminModuleDetailView extends StatelessWidget {
  const AdminModuleDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final rawArgs = Get.arguments as Map?;
    final args = rawArgs?.cast<String, dynamic>() ?? const {};
    final moduleId = (args['moduleId'] ?? '').toString();
    final module = kAdminModules.firstWhereOrNull(
      (item) => item.id == moduleId,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (module == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (moduleId.isNotEmpty) {
          AdminPortalNavigation.openFromCatalog(
            moduleId: moduleId,
            feature: args['feature']?.toString() ?? moduleId,
          );
        } else {
          Get.back();
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screens = AdminPortalNavigation.screensForModule(module.id);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(module.title),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        actions: [
          IconButton(
            onPressed: () => _refreshModule(module.id),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshModule(module.id),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _AdminModuleHeader(module: module),
            const SizedBox(height: 16),
            _SectionTitle(title: _snapshotTitle(module.id)),
            const SizedBox(height: 10),
            Obx(
              () => Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _buildModuleMetrics(
                  module.id,
                ).map((metric) => _MetricCard(metric: metric)).toList(),
              ),
            ),
            const SizedBox(height: 20),
            _SectionTitle(title: 'Available Screens'),
            const SizedBox(height: 10),
            ...screens.map(
              (screen) => _ScreenTile(
                title: screen.title,
                description: screen.description,
                onTap: () => AdminPortalNavigation.openScreen(screen),
              ),
            ),
            const SizedBox(height: 20),
            _SectionTitle(title: 'Module Coverage'),
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

class AdminFeatureDetailView extends StatelessWidget {
  const AdminFeatureDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final rawArgs = Get.arguments as Map?;
    final args = rawArgs?.cast<String, dynamic>() ?? const {};
    final moduleId = (args['moduleId'] ?? '').toString();
    final feature = (args['feature'] ?? 'Workflow').toString();
    final module = kAdminModules.firstWhereOrNull(
      (item) => item.id == moduleId,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screens = AdminPortalNavigation.screensForModule(moduleId);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(feature),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshModule(moduleId),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
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
                    module?.title ?? 'Admin Module',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    feature,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This workflow opens through real admin screens backed by live data.',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => AdminPortalNavigation.openFromCatalog(
                        moduleId: moduleId,
                        feature: feature,
                      ),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('Open Linked Screen'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionTitle(title: _snapshotTitle(moduleId)),
            const SizedBox(height: 10),
            Obx(
              () => Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _buildModuleMetrics(
                  moduleId,
                ).map((metric) => _MetricCard(metric: metric)).toList(),
              ),
            ),
            if (screens.isNotEmpty) ...[
              const SizedBox(height: 20),
              const _SectionTitle(title: 'Related Screens'),
              const SizedBox(height: 10),
              ...screens.map(
                (screen) => _ScreenTile(
                  title: screen.title,
                  description: screen.description,
                  onTap: () => AdminPortalNavigation.openScreen(screen),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AdminModuleHeader extends StatelessWidget {
  const _AdminModuleHeader({required this.module});

  final AdminModuleItem module;

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
                  module.description,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

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

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final _AdminMetric metric;

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

class _ScreenTile extends StatelessWidget {
  const _ScreenTile({
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

class _AdminMetric {
  const _AdminMetric({
    required this.label,
    required this.value,
    required this.caption,
  });

  final String label;
  final String value;
  final String caption;
}

Future<void> _refreshModule(String moduleId) async {
  final dashboard = Get.find<AdminDashboardController>();
  final approvals = Get.find<AdminApprovalsController>();
  final attendance = Get.find<AdminAttendanceController>();
  final fees = Get.find<AdminFeeSnapshotController>();
  final reports = Get.find<AdminReportsController>();
  final notices = Get.find<AdminNoticeBoardController>();
  final audit = Get.find<AdminAuditLogsController>();
  final profile = Get.find<AdminProfileController>();
  final settings = Get.find<AdminSettingsController>();

  switch (moduleId) {
    case 'dashboard':
      await Future.wait([
        dashboard.loadDashboard(),
        attendance.loadAttendance(),
        fees.loadFeeSnapshot(),
      ]);
      return;
    case 'admissions':
      await Future.wait([
        approvals.loadPendingApprovals(),
        notices.loadAnnouncements(),
        reports.loadReports(),
      ]);
      return;
    case 'attendance':
      await Future.wait([
        attendance.loadAttendance(),
        reports.loadReports(),
        audit.loadLogs(),
      ]);
      return;
    case 'fees':
      await Future.wait([
        fees.loadFeeSnapshot(),
        reports.loadReports(),
        notices.loadAnnouncements(),
      ]);
      return;
    case 'communication':
    case 'events':
      await Future.wait([notices.loadAnnouncements(), audit.loadLogs()]);
      return;
    case 'security':
      await Future.wait([audit.loadLogs(), settings.loadSettings()]);
      return;
    case 'settings':
      await Future.wait([settings.loadSettings(), profile.loadProfile()]);
      return;
    default:
      await Future.wait([
        dashboard.loadDashboard(),
        reports.loadReports(),
        notices.loadAnnouncements(),
        audit.loadLogs(),
      ]);
  }
}

String _snapshotTitle(String moduleId) {
  switch (moduleId) {
    case 'dashboard':
    case 'attendance':
    case 'fees':
    case 'reports':
    case 'communication':
    case 'security':
    case 'settings':
      return 'Live Module Snapshot';
    default:
      return 'Live School Snapshot';
  }
}

List<_AdminMetric> _buildModuleMetrics(String moduleId) {
  final dashboard = Get.find<AdminDashboardController>();
  final approvals = Get.find<AdminApprovalsController>();
  final attendance = Get.find<AdminAttendanceController>();
  final fees = Get.find<AdminFeeSnapshotController>();
  final reports = Get.find<AdminReportsController>();
  final notices = Get.find<AdminNoticeBoardController>();
  final audit = Get.find<AdminAuditLogsController>();
  final profile = Get.find<AdminProfileController>();
  final settings = Get.find<AdminSettingsController>();

  final totalClasses = (reports.classOptions.length - 1).clamp(0, 9999);
  final recentLogs = audit.logsToday.length + audit.logsYesterday.length;

  switch (moduleId) {
    case 'dashboard':
      return [
        _AdminMetric(
          label: 'Students',
          value: '${dashboard.totalStudents.value}',
          caption: 'Live student count',
        ),
        _AdminMetric(
          label: 'Teacher Presence',
          value: '${dashboard.teacherPresence.value.toStringAsFixed(1)}%',
          caption:
              '${dashboard.teacherPresent.value}/${dashboard.teacherTotal.value} present',
        ),
        _AdminMetric(
          label: 'Pending Approvals',
          value: '${dashboard.pendingApprovals.value}',
          caption: 'Needs admin review',
        ),
        _AdminMetric(
          label: 'Fee Today',
          value: '\$${dashboard.feeToday.value.toStringAsFixed(0)}',
          caption: 'Today collection',
        ),
      ];
    case 'admissions':
      return [
        _AdminMetric(
          label: 'Queue Items',
          value: '${approvals.requests.length}',
          caption: 'Pending approval requests',
        ),
        _AdminMetric(
          label: 'Students',
          value: '${dashboard.totalStudents.value}',
          caption: 'Current enrolled base',
        ),
        _AdminMetric(
          label: 'Notices',
          value: '${notices.notices.length}',
          caption: 'Communication ready',
        ),
        _AdminMetric(
          label: 'Classes',
          value: '$totalClasses',
          caption: 'Configured class list',
        ),
      ];
    case 'students':
      return [
        _AdminMetric(
          label: 'Students',
          value: '${dashboard.totalStudents.value}',
          caption: 'Live student directory size',
        ),
        _AdminMetric(
          label: 'Attendance',
          value: '${attendance.studentPercent.value}%',
          caption:
              '${attendance.studentPresent.value}/${attendance.studentTotal.value} present',
        ),
        _AdminMetric(
          label: 'Classes',
          value: '$totalClasses',
          caption: 'Class groups in reports',
        ),
        _AdminMetric(
          label: 'Pending Approvals',
          value: '${approvals.requests.length}',
          caption: 'Student-related requests in queue',
        ),
      ];
    case 'staff':
      return [
        _AdminMetric(
          label: 'Teacher Presence',
          value: '${dashboard.teacherPresence.value.toStringAsFixed(1)}%',
          caption:
              '${dashboard.teacherPresent.value}/${dashboard.teacherTotal.value} present',
        ),
        _AdminMetric(
          label: 'Staff Attendance',
          value: '${attendance.staffPercent.value}%',
          caption:
              '${attendance.staffPresent.value}/${attendance.staffTotal.value} present',
        ),
        _AdminMetric(
          label: 'Recent Logs',
          value: '$recentLogs',
          caption: 'Today and yesterday activity',
        ),
        _AdminMetric(
          label: 'Admin',
          value: profile.name.value.isEmpty ? 'Admin' : profile.name.value,
          caption: 'Current operator profile',
        ),
      ];
    case 'academics':
      return [
        _AdminMetric(
          label: 'Classes',
          value: '$totalClasses',
          caption: 'Configured class list',
        ),
        _AdminMetric(
          label: 'Students',
          value: '${dashboard.totalStudents.value}',
          caption: 'School-wide learner count',
        ),
        _AdminMetric(
          label: 'Attendance',
          value: reports.attendanceBadge.value,
          caption: 'Current report range',
        ),
        _AdminMetric(
          label: 'Notices',
          value: '${notices.notices.length}',
          caption: 'Academic communication items',
        ),
      ];
    case 'attendance':
      return [
        _AdminMetric(
          label: 'Student Attendance',
          value: '${attendance.studentPercent.value}%',
          caption:
              '${attendance.studentPresent.value}/${attendance.studentTotal.value} present',
        ),
        _AdminMetric(
          label: 'Staff Attendance',
          value: '${attendance.staffPercent.value}%',
          caption:
              '${attendance.staffPresent.value}/${attendance.staffTotal.value} present',
        ),
        _AdminMetric(
          label: 'Tracked Days',
          value: '${attendance.classes.length}',
          caption: 'Trend points loaded',
        ),
        _AdminMetric(
          label: 'Recent Logs',
          value: '$recentLogs',
          caption: 'Attendance-linked admin activity',
        ),
      ];
    case 'fees':
      return [
        _AdminMetric(
          label: 'Collected',
          value: '\$${fees.collected.value.toStringAsFixed(0)}',
          caption: 'Today fee collection',
        ),
        _AdminMetric(
          label: 'Pending',
          value: '\$${fees.pending.value.toStringAsFixed(0)}',
          caption: 'Outstanding amount',
        ),
        _AdminMetric(
          label: 'Collection Rate',
          value: '${fees.overallPercent.value.toStringAsFixed(1)}%',
          caption: 'Snapshot completion',
        ),
        _AdminMetric(
          label: 'Fee Report',
          value: '\$${reports.feeOutstanding.value.toStringAsFixed(0)}',
          caption: 'Current report outstanding',
        ),
      ];
    case 'communication':
      return [
        _AdminMetric(
          label: 'Notices',
          value: '${notices.notices.length}',
          caption: 'Current notice records',
        ),
        _AdminMetric(
          label: 'Recent Logs',
          value: '$recentLogs',
          caption: 'Communication-related system activity',
        ),
        _AdminMetric(
          label: 'Pending Approvals',
          value: '${approvals.requests.length}',
          caption: 'Items that may need follow-up',
        ),
        _AdminMetric(
          label: 'Admin',
          value: settings.adminInitials.value,
          caption: 'Active school admin session',
        ),
      ];
    case 'events':
      return [
        _AdminMetric(
          label: 'Notices',
          value: '${notices.notices.length}',
          caption: 'Event and activity communication',
        ),
        _AdminMetric(
          label: 'Attendance',
          value: reports.attendanceBadge.value,
          caption: 'Operational attendance context',
        ),
        _AdminMetric(
          label: 'Students',
          value: '${dashboard.totalStudents.value}',
          caption: 'Event audience size',
        ),
        _AdminMetric(
          label: 'Classes',
          value: '$totalClasses',
          caption: 'Available class groups',
        ),
      ];
    case 'reports':
      return [
        _AdminMetric(
          label: 'Attendance',
          value: reports.attendanceBadge.value,
          caption: 'Current report filter',
        ),
        _AdminMetric(
          label: 'Outstanding Fees',
          value: '\$${reports.feeOutstanding.value.toStringAsFixed(0)}',
          caption: 'Report-range pending amount',
        ),
        _AdminMetric(
          label: 'Classes',
          value: '$totalClasses',
          caption: 'Available class filters',
        ),
        _AdminMetric(
          label: 'Collection Total',
          value: '\$${reports.collectionTotal.value.toStringAsFixed(0)}',
          caption: 'Current report-range collections',
        ),
      ];
    case 'security':
      return [
        _AdminMetric(
          label: 'Recent Logs',
          value: '$recentLogs',
          caption: 'Today and yesterday audit items',
        ),
        _AdminMetric(
          label: 'Branch Code',
          value: profile.branchCode.value,
          caption: 'Current school branch',
        ),
        _AdminMetric(
          label: 'Session',
          value: settings.appVersion.value,
          caption: settings.sessionInfo.value.isEmpty
              ? 'Admin settings session'
              : settings.sessionInfo.value,
        ),
        _AdminMetric(
          label: 'Pending Approvals',
          value: '${profile.pendingApprovals.value}',
          caption: 'Security-sensitive reviews still pending',
        ),
      ];
    case 'settings':
      return [
        _AdminMetric(
          label: 'Admin',
          value: settings.adminInitials.value,
          caption: settings.adminName.value,
        ),
        _AdminMetric(
          label: 'Profile',
          value: profile.branchName.value,
          caption: 'Live school profile name',
        ),
        _AdminMetric(
          label: 'Session',
          value: settings.appVersion.value,
          caption: settings.sessionInfo.value.isEmpty
              ? 'Current session information'
              : settings.sessionInfo.value,
        ),
        _AdminMetric(
          label: 'Notifications',
          value: profile.emailNotificationsEnabled.value
              ? 'Enabled'
              : 'Disabled',
          caption: 'Email notification preference',
        ),
      ];
    default:
      return [
        _AdminMetric(
          label: 'Students',
          value: '${dashboard.totalStudents.value}',
          caption: 'Live school student count',
        ),
        _AdminMetric(
          label: 'Classes',
          value: '$totalClasses',
          caption: 'Configured class list',
        ),
        _AdminMetric(
          label: 'Notices',
          value: '${notices.notices.length}',
          caption: 'Current communication records',
        ),
        _AdminMetric(
          label: 'Recent Logs',
          value: '$recentLogs',
          caption: 'Latest admin activity',
        ),
      ];
  }
}
