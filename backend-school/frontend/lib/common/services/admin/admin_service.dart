import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import '../parent/parent_api_utils.dart';

class AdminService {
  AdminService(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, dynamic>? query,
    required String context,
  }) async {
    final res = await _apiClient.get(path, query: query);
    return extractApiData(res.data, context: context);
  }

  Future<Map<String, dynamic>> _post(
    String path, {
    Map<String, dynamic>? payload,
    required String context,
  }) async {
    final res = await _apiClient.post(path, data: payload);
    return extractApiData(res.data, context: context);
  }

  Future<Map<String, dynamic>> _put(
    String path, {
    required Map<String, dynamic> payload,
    required String context,
  }) async {
    final res = await _apiClient.put(path, data: payload);
    return extractApiData(res.data, context: context);
  }

  Future<Map<String, dynamic>> _patch(
    String path, {
    Map<String, dynamic>? payload,
    required String context,
  }) async {
    final res = await _apiClient.patch(path, data: payload);
    return extractApiData(res.data, context: context);
  }

  Future<Map<String, dynamic>> _delete(
    String path, {
    required String context,
  }) async {
    final res = await _apiClient.dio.delete(path);
    return extractApiData(res.data, context: context);
  }

  Future<Map<String, dynamic>> uploadFile({
    required String path,
    required List<int> bytes,
    required String fileName,
    Map<String, dynamic>? extraData,
    void Function(int, int)? onSendProgress,
    required String context,
  }) async {
    final res = await _apiClient.uploadFile(
      path,
      bytes: bytes,
      fileName: fileName,
      extraData: extraData,
      onSendProgress: onSendProgress,
    );
    return extractApiData(res.data, context: context);
  }

  Future<Map<String, dynamic>> getSchoolAdminDashboard() async {
    final res = await _apiClient.get(ApiEndpoints.dashboardSchoolAdmin);
    return extractApiData(res.data, context: 'admin dashboard');
  }

  Future<Map<String, dynamic>> getPendingApprovalsSummary() async {
    final res = await _apiClient.get(
      ApiEndpoints.schoolApprovalsPendingSummary,
    );
    return extractApiData(res.data, context: 'pending approvals');
  }

  Future<Map<String, dynamic>> decideApproval({
    required String approvalType,
    required String id,
    required bool approve,
    String? reason,
  }) async {
    final endpoint = ApiEndpoints.schoolApprovalDecision(approvalType, id);
    final res = await _apiClient.patch(
      endpoint,
      data: {
        'decision': approve ? 'APPROVED' : 'REJECTED',
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
    return extractApiData(res.data, context: 'approval decision');
  }

  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (status != null && status.isNotEmpty) 'status': status,
    };
    final res = await _apiClient.get(
      ApiEndpoints.schoolNotifications,
      query: query,
    );
    return extractApiData(res.data, context: 'notifications');
  }

  Future<Map<String, dynamic>> getNotificationTemplates({
    int page = 1,
    int limit = 50,
  }) {
    return _get(
      ApiEndpoints.schoolNotificationTemplates,
      query: {'page': page, 'limit': limit},
      context: 'notification templates',
    );
  }

  Future<Map<String, dynamic>> createNotificationTemplate(
    Map<String, dynamic> payload,
  ) {
    return _post(
      ApiEndpoints.schoolNotificationTemplates,
      payload: payload,
      context: 'create notification template',
    );
  }

  Future<Map<String, dynamic>> updateNotificationTemplate({
    required String id,
    required Map<String, dynamic> payload,
  }) {
    return _put(
      ApiEndpoints.schoolNotificationTemplateById(id),
      payload: payload,
      context: 'update notification template',
    );
  }

  Future<Map<String, dynamic>> deleteNotificationTemplate(String id) {
    return _delete(
      ApiEndpoints.schoolNotificationTemplateById(id),
      context: 'delete notification template',
    );
  }

  Future<Map<String, dynamic>> getNotificationLogs({
    int page = 1,
    int limit = 50,
  }) {
    return _get(
      ApiEndpoints.schoolNotificationLogs,
      query: {'page': page, 'limit': limit},
      context: 'notification logs',
    );
  }

  Future<Map<String, dynamic>> getFeeSnapshot() async {
    final res = await _apiClient.get(ApiEndpoints.schoolFeesSnapshot);
    return extractApiData(res.data, context: 'fee snapshot');
  }

  /// Optional breakdown; shape may include `breakdown`, `categories`, or `structures`.
  Future<Map<String, dynamic>> getFeesSummary() async {
    final res = await _apiClient.get(ApiEndpoints.schoolFeesSummary);
    return extractApiData(res.data, context: 'fees summary');
  }

  Future<Map<String, dynamic>> getFeeDiscountRules({
    int page = 1,
    int limit = 50,
  }) {
    return _get(
      ApiEndpoints.schoolFeeDiscountRules,
      query: {'page': page, 'limit': limit},
      context: 'fee discount rules',
    );
  }

  Future<Map<String, dynamic>> createFeeDiscountRule(
    Map<String, dynamic> payload,
  ) {
    return _post(
      ApiEndpoints.schoolFeeDiscountRules,
      payload: payload,
      context: 'create fee discount rule',
    );
  }

  Future<Map<String, dynamic>> updateFeeDiscountRule({
    required String id,
    required Map<String, dynamic> payload,
  }) {
    return _put(
      ApiEndpoints.schoolFeeDiscountRuleById(id),
      payload: payload,
      context: 'update fee discount rule',
    );
  }

  Future<Map<String, dynamic>> deleteFeeDiscountRule(String id) {
    return _delete(
      ApiEndpoints.schoolFeeDiscountRuleById(id),
      context: 'delete fee discount rule',
    );
  }

  Future<Map<String, dynamic>> getFeeStructures({
    int page = 1,
    int limit = 100,
    String? classId,
    String? className,
    String? search,
  }) async {
    final res = await _apiClient.get(
      ApiEndpoints.schoolFeeStructures,
      query: {
        'page': page,
        'limit': limit,
        if (classId != null && classId.trim().isNotEmpty)
          'classId': classId.trim(),
        if (className != null && className.trim().isNotEmpty)
          'className': className.trim(),
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    return extractApiData(res.data, context: 'fee structures');
  }

  Future<Map<String, dynamic>> createFeeStructure(
    Map<String, dynamic> payload,
  ) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolFeeStructures,
      data: payload,
    );
    return extractApiData(res.data, context: 'create fee structure');
  }

  Future<Map<String, dynamic>> updateFeeStructure({
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    final res = await _apiClient.put(
      ApiEndpoints.schoolFeeStructureById(id),
      data: payload,
    );
    return extractApiData(res.data, context: 'update fee structure');
  }

  Future<Map<String, dynamic>> deleteFeeStructure(String id) async {
    final res = await _apiClient.dio.delete(
      ApiEndpoints.schoolFeeStructureById(id),
    );
    return extractApiData(res.data, context: 'delete fee structure');
  }

  Future<Map<String, dynamic>> getFeeDueList({
    int page = 1,
    int limit = 50,
    String? classId,
    String? status,
  }) async {
    final res = await _apiClient.get(
      ApiEndpoints.schoolFeesDueList,
      query: {
        'page': page,
        'limit': limit,
        if (classId != null && classId.trim().isNotEmpty)
          'classId': classId.trim(),
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
      },
    );
    return extractApiData(res.data, context: 'fee due list');
  }

  Future<Map<String, dynamic>> getFeeCollectionReport({
    String? dateFrom,
    String? dateTo,
  }) {
    return _get(
      ApiEndpoints.schoolFeeCollectionReport,
      query: {
        if (dateFrom != null && dateFrom.trim().isNotEmpty)
          'dateFrom': dateFrom.trim(),
        if (dateTo != null && dateTo.trim().isNotEmpty) 'dateTo': dateTo.trim(),
      },
      context: 'fee collection report',
    );
  }

  Future<Map<String, dynamic>> getFeePendingDuesReport({
    String? classId,
    String? status,
  }) {
    return _get(
      ApiEndpoints.schoolFeePendingDuesReport,
      query: {
        if (classId != null && classId.trim().isNotEmpty)
          'classId': classId.trim(),
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
      },
      context: 'fee pending dues report',
    );
  }

  Future<Map<String, dynamic>> getFeeStudentLedger(String studentId) {
    return _get(
      ApiEndpoints.schoolFeeStudentLedger(studentId),
      context: 'student fee ledger',
    );
  }

  Future<Map<String, dynamic>> getPayments({
    int page = 1,
    int limit = 50,
    String? studentId,
  }) async {
    final res = await _apiClient.get(
      ApiEndpoints.schoolPayments,
      query: {
        'page': page,
        'limit': limit,
        if (studentId != null && studentId.trim().isNotEmpty)
          'studentId': studentId.trim(),
      },
    );
    return extractApiData(res.data, context: 'payments');
  }

  Future<Map<String, dynamic>> createPayment(
    Map<String, dynamic> payload,
  ) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolPayments,
      data: payload,
    );
    return extractApiData(res.data, context: 'create payment');
  }

  Future<Map<String, dynamic>> getInvoices({
    int page = 1,
    int limit = 50,
    String? studentId,
    String? status,
  }) async {
    final res = await _apiClient.get(
      ApiEndpoints.schoolInvoices,
      query: {
        'page': page,
        'limit': limit,
        if (studentId != null && studentId.trim().isNotEmpty)
          'studentId': studentId.trim(),
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
      },
    );
    return extractApiData(res.data, context: 'invoices');
  }

  Future<Map<String, dynamic>> getInvoiceById(String id) {
    return _get(ApiEndpoints.schoolInvoiceById(id), context: 'invoice');
  }

  Future<Map<String, dynamic>> createInvoice(
    Map<String, dynamic> payload,
  ) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolInvoices,
      data: payload,
    );
    return extractApiData(res.data, context: 'create invoice');
  }

  Future<Map<String, dynamic>> bulkGenerateInvoices(
    Map<String, dynamic> payload,
  ) {
    return _post(
      ApiEndpoints.schoolInvoicesBulkGenerate,
      payload: payload,
      context: 'bulk generate invoices',
    );
  }

  Future<Map<String, dynamic>> updateInvoiceStatus({
    required String id,
    required String status,
  }) async {
    final res = await _apiClient.patch(
      ApiEndpoints.schoolInvoiceStatus(id),
      data: {'status': status},
    );
    return extractApiData(res.data, context: 'update invoice status');
  }

  Future<Map<String, dynamic>> getPaymentReceipt(String id) {
    return _get(
      ApiEndpoints.schoolPaymentReceipt(id),
      context: 'payment receipt',
    );
  }

  Future<Map<String, dynamic>> getPaymentRefunds(String id) {
    return _get(
      ApiEndpoints.schoolPaymentRefunds(id),
      context: 'payment refunds',
    );
  }

  Future<Map<String, dynamic>> createPaymentRefund({
    required String id,
    required Map<String, dynamic> payload,
  }) {
    return _post(
      ApiEndpoints.schoolPaymentRefunds(id),
      payload: payload,
      context: 'create payment refund',
    );
  }

  Future<Map<String, dynamic>> getAcademicYears({
    int page = 1,
    int limit = 50,
  }) {
    return _get(
      ApiEndpoints.schoolAcademicYears,
      query: {'page': page, 'limit': limit},
      context: 'academic years',
    );
  }

  Future<Map<String, dynamic>> createAcademicYear(
    Map<String, dynamic> payload,
  ) {
    return _post(
      ApiEndpoints.schoolAcademicYears,
      payload: payload,
      context: 'create academic year',
    );
  }

  Future<Map<String, dynamic>> updateAcademicYear({
    required String id,
    required Map<String, dynamic> payload,
  }) {
    return _put(
      ApiEndpoints.schoolAcademicYearById(id),
      payload: payload,
      context: 'update academic year',
    );
  }

  Future<Map<String, dynamic>> deleteAcademicYear(String id) {
    return _delete(
      ApiEndpoints.schoolAcademicYearById(id),
      context: 'delete academic year',
    );
  }

  Future<Map<String, dynamic>> activateAcademicYear(String id) {
    return _patch(
      ApiEndpoints.schoolAcademicYearActivate(id),
      context: 'activate academic year',
    );
  }

  Future<Map<String, dynamic>> getTerms({int page = 1, int limit = 50}) {
    return _get(
      ApiEndpoints.schoolTerms,
      query: {'page': page, 'limit': limit},
      context: 'terms',
    );
  }

  Future<Map<String, dynamic>> createTerm(Map<String, dynamic> payload) {
    return _post(
      ApiEndpoints.schoolTerms,
      payload: payload,
      context: 'create term',
    );
  }

  Future<Map<String, dynamic>> updateTerm({
    required String id,
    required Map<String, dynamic> payload,
  }) {
    return _put(
      ApiEndpoints.schoolTermById(id),
      payload: payload,
      context: 'update term',
    );
  }

  Future<Map<String, dynamic>> deleteTerm(String id) {
    return _delete(ApiEndpoints.schoolTermById(id), context: 'delete term');
  }

  Future<Map<String, dynamic>> getSections({int page = 1, int limit = 50}) {
    return _get(
      ApiEndpoints.schoolSections,
      query: {'page': page, 'limit': limit},
      context: 'sections',
    );
  }

  Future<Map<String, dynamic>> createSection(Map<String, dynamic> payload) {
    return _post(
      ApiEndpoints.schoolSections,
      payload: payload,
      context: 'create section',
    );
  }

  Future<Map<String, dynamic>> updateSection({
    required String id,
    required Map<String, dynamic> payload,
  }) {
    return _put(
      ApiEndpoints.schoolSectionById(id),
      payload: payload,
      context: 'update section',
    );
  }

  Future<Map<String, dynamic>> deleteSection(String id) {
    return _delete(
      ApiEndpoints.schoolSectionById(id),
      context: 'delete section',
    );
  }

  Future<Map<String, dynamic>> getHolidays({int page = 1, int limit = 50}) {
    return _get(
      ApiEndpoints.schoolHolidays,
      query: {'page': page, 'limit': limit},
      context: 'holidays',
    );
  }

  Future<Map<String, dynamic>> createHoliday(Map<String, dynamic> payload) {
    return _post(
      ApiEndpoints.schoolHolidays,
      payload: payload,
      context: 'create holiday',
    );
  }

  Future<Map<String, dynamic>> updateHoliday({
    required String id,
    required Map<String, dynamic> payload,
  }) {
    return _put(
      ApiEndpoints.schoolHolidayById(id),
      payload: payload,
      context: 'update holiday',
    );
  }

  Future<Map<String, dynamic>> deleteHoliday(String id) {
    return _delete(
      ApiEndpoints.schoolHolidayById(id),
      context: 'delete holiday',
    );
  }

  Future<Map<String, dynamic>> getAdminUsers({int page = 1, int limit = 50}) {
    return _get(
      ApiEndpoints.schoolAdminUsers,
      query: {'page': page, 'limit': limit},
      context: 'admin users',
    );
  }

  Future<Map<String, dynamic>> createAdminUser(Map<String, dynamic> payload) {
    return _post(
      ApiEndpoints.schoolAdminUsers,
      payload: payload,
      context: 'create admin user',
    );
  }

  Future<Map<String, dynamic>> updateAdminUser({
    required String id,
    required Map<String, dynamic> payload,
  }) {
    return _put(
      ApiEndpoints.schoolAdminUserById(id),
      payload: payload,
      context: 'update admin user',
    );
  }

  Future<Map<String, dynamic>> getRoles({int page = 1, int limit = 50}) {
    return _get(
      ApiEndpoints.schoolRoles,
      query: {'page': page, 'limit': limit},
      context: 'roles',
    );
  }

  Future<Map<String, dynamic>> createRole(Map<String, dynamic> payload) {
    return _post(
      ApiEndpoints.schoolRoles,
      payload: payload,
      context: 'create role',
    );
  }

  Future<Map<String, dynamic>> updateRole({
    required String id,
    required Map<String, dynamic> payload,
  }) {
    return _put(
      ApiEndpoints.schoolRoleById(id),
      payload: payload,
      context: 'update role',
    );
  }

  Future<Map<String, dynamic>> deleteRole(String id) {
    return _delete(ApiEndpoints.schoolRoleById(id), context: 'delete role');
  }

  Future<Map<String, dynamic>> getPermissions() {
    return _get(ApiEndpoints.schoolPermissions, context: 'permissions');
  }

  Future<Map<String, dynamic>> getPermissionsMatrix() {
    return _get(
      ApiEndpoints.schoolPermissionsMatrix,
      context: 'permissions matrix',
    );
  }

  Future<Map<String, dynamic>> updatePermissionsMatrix(
    Map<String, dynamic> payload,
  ) {
    return _put(
      ApiEndpoints.schoolPermissionsMatrix,
      payload: payload,
      context: 'update permissions matrix',
    );
  }

  Future<Map<String, dynamic>> getDocumentCategories({
    int page = 1,
    int limit = 50,
  }) {
    return _get(
      ApiEndpoints.schoolDocumentCategories,
      query: {'page': page, 'limit': limit},
      context: 'document categories',
    );
  }

  Future<Map<String, dynamic>> createDocumentCategory(
    Map<String, dynamic> payload,
  ) {
    return _post(
      ApiEndpoints.schoolDocumentCategories,
      payload: payload,
      context: 'create document category',
    );
  }

  Future<Map<String, dynamic>> updateDocumentCategory({
    required String id,
    required Map<String, dynamic> payload,
  }) {
    return _put(
      ApiEndpoints.schoolDocumentCategoryById(id),
      payload: payload,
      context: 'update document category',
    );
  }

  Future<Map<String, dynamic>> deleteDocumentCategory(String id) {
    return _delete(
      ApiEndpoints.schoolDocumentCategoryById(id),
      context: 'delete document category',
    );
  }

  Future<Map<String, dynamic>> getAchievements({int page = 1, int limit = 50}) {
    return _get(
      ApiEndpoints.schoolAchievements,
      query: {'page': page, 'limit': limit},
      context: 'achievements',
    );
  }

  Future<Map<String, dynamic>> createAchievement(Map<String, dynamic> payload) {
    return _post(
      ApiEndpoints.schoolAchievements,
      payload: payload,
      context: 'create achievement',
    );
  }

  Future<Map<String, dynamic>> deleteAchievement(String id) {
    return _delete(
      ApiEndpoints.schoolAchievementById(id),
      context: 'delete achievement',
    );
  }

  Future<Map<String, dynamic>> getAiFaqs({int page = 1, int limit = 50}) {
    return _get(
      ApiEndpoints.schoolAiFaqs,
      query: {'page': page, 'limit': limit},
      context: 'AI FAQs',
    );
  }

  Future<Map<String, dynamic>> createAiFaq(Map<String, dynamic> payload) {
    return _post(
      ApiEndpoints.schoolAiFaqs,
      payload: payload,
      context: 'create AI FAQ',
    );
  }

  Future<Map<String, dynamic>> updateAiFaq({
    required String id,
    required Map<String, dynamic> payload,
  }) {
    return _put(
      ApiEndpoints.schoolAiFaqById(id),
      payload: payload,
      context: 'update AI FAQ',
    );
  }

  Future<Map<String, dynamic>> deleteAiFaq(String id) {
    return _delete(ApiEndpoints.schoolAiFaqById(id), context: 'delete AI FAQ');
  }

  Future<Map<String, dynamic>> getAttendanceTrend({
    int days = 7,
    String type = 'student',
  }) async {
    final res = await _apiClient.get(
      ApiEndpoints.schoolAttendanceTrend,
      query: {'days': days, 'type': type},
    );
    return extractApiData(res.data, context: 'attendance trend');
  }

  Future<Map<String, dynamic>> getAttendanceOverview({String? date}) async {
    final query = <String, dynamic>{
      if (date != null && date.isNotEmpty) 'date': date,
    };
    final res = await _apiClient.get(
      ApiEndpoints.schoolAttendanceOverview,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'attendance overview');
  }

  Future<Map<String, dynamic>> getAttendanceRecords({
    required String type,
    String? date,
    String? className,
    String? section,
    int page = 1,
    int limit = 200,
  }) async {
    final query = <String, dynamic>{
      'type': type,
      'page': page,
      'limit': limit,
      if (date != null && date.isNotEmpty) 'date': date,
      if (className != null && className.isNotEmpty) 'className': className,
      if (section != null && section.isNotEmpty) 'section': section,
    };
    final res = await _apiClient.get(
      ApiEndpoints.schoolAttendanceRecords,
      query: query,
    );
    return extractApiData(res.data, context: 'attendance records');
  }

  Future<Map<String, dynamic>> updateAttendanceRecord({
    required String id,
    required Map<String, dynamic> payload,
  }) {
    return _put(
      ApiEndpoints.schoolAttendanceRecordById(id),
      payload: payload,
      context: 'update attendance record',
    );
  }

  Future<Map<String, dynamic>> markAttendance(Map<String, dynamic> payload) {
    return _post(
      ApiEndpoints.schoolAttendanceMark,
      payload: payload,
      context: 'mark attendance',
    );
  }

  Future<Map<String, dynamic>> exportAttendance({
    required String type,
    String? dateFrom,
    String? dateTo,
    String? className,
    String? section,
  }) {
    return _get(
      ApiEndpoints.schoolAttendanceExport,
      query: {
        'type': type,
        if (dateFrom != null && dateFrom.trim().isNotEmpty)
          'dateFrom': dateFrom.trim(),
        if (dateTo != null && dateTo.trim().isNotEmpty) 'dateTo': dateTo.trim(),
        if (className != null && className.trim().isNotEmpty)
          'className': className.trim(),
        if (section != null && section.trim().isNotEmpty)
          'section': section.trim(),
      },
      context: 'export attendance',
    );
  }

  Future<Map<String, dynamic>> markAttendanceBulk({
    required String type,
    required String date,
    required List<Map<String, dynamic>> records,
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolAttendanceBulkMark,
      data: {'type': type, 'date': date, 'records': records},
    );
    return extractApiData(res.data, context: 'mark attendance bulk');
  }

  Future<Map<String, dynamic>> getProfileMe() async {
    final res = await _apiClient.get(ApiEndpoints.schoolProfileMe);
    return extractApiData(res.data, context: 'admin profile me');
  }

  Future<Map<String, dynamic>> getSchoolProfile() async {
    final res = await _apiClient.get(ApiEndpoints.schoolProfile);
    return extractApiData(res.data, context: 'school profile');
  }

  Future<Map<String, dynamic>> getSchoolSettings() async {
    final res = await _apiClient.get(ApiEndpoints.schoolSettings);
    return extractApiData(res.data, context: 'school settings');
  }

  Future<Map<String, dynamic>> updateSchoolSettings(
    Map<String, dynamic> payload,
  ) async {
    final res = await _apiClient.put(
      ApiEndpoints.schoolSettings,
      data: payload,
    );
    return extractApiData(res.data, context: 'update school settings');
  }

  Future<Map<String, dynamic>> patchSchoolSettings(
    Map<String, dynamic> payload,
  ) async {
    final res = await _apiClient.patch(
      ApiEndpoints.schoolSettings,
      data: payload,
    );
    return extractApiData(res.data, context: 'patch school settings');
  }

  Future<Map<String, dynamic>> getAnnouncements({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (status != null && status.isNotEmpty) 'status': status,
    };
    final res = await _apiClient.get(
      ApiEndpoints.schoolAnnouncements,
      query: query,
    );
    return extractApiData(res.data, context: 'announcements');
  }

  Future<Map<String, dynamic>> getAnnouncementById(String id) {
    return _get(
      ApiEndpoints.schoolAnnouncementById(id),
      context: 'announcement',
    );
  }

  Future<Map<String, dynamic>> createAnnouncement({
    required String title,
    required String content,
    required String audience,
    String status = 'DRAFT',
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolAnnouncements,
      data: {
        'title': title,
        'content': content,
        'audience': audience,
        'status': status,
      },
    );
    return extractApiData(res.data, context: 'create announcement');
  }

  Future<Map<String, dynamic>> updateAnnouncement({
    required String id,
    required Map<String, dynamic> payload,
  }) {
    return _put(
      ApiEndpoints.schoolAnnouncementById(id),
      payload: payload,
      context: 'update announcement',
    );
  }

  Future<Map<String, dynamic>> deleteAnnouncement(String id) {
    return _delete(
      ApiEndpoints.schoolAnnouncementById(id),
      context: 'delete announcement',
    );
  }

  Future<Map<String, dynamic>> sendAnnouncement(String id) async {
    final res = await _apiClient.post(ApiEndpoints.schoolAnnouncementSend(id));
    return extractApiData(res.data, context: 'send announcement');
  }

  Future<Map<String, dynamic>> getAuditLogs({
    int page = 1,
    int limit = 50,
  }) async {
    final res = await _apiClient.get(
      ApiEndpoints.schoolAuditLogs,
      query: {'page': page, 'limit': limit},
    );
    return extractApiData(res.data, context: 'audit logs');
  }

  Future<Map<String, dynamic>> getParents({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final res = await _apiClient.get(ApiEndpoints.schoolParents, query: query);
    return extractApiData(res.data, context: 'parents');
  }

  Future<Map<String, dynamic>> getParentById(String id) async {
    final res = await _apiClient.get(ApiEndpoints.schoolParentById(id));
    return extractApiData(res.data, context: 'parent');
  }

  Future<Map<String, dynamic>> createParent({
    required String fullName,
    String? email,
    String? phone,
    bool isActive = true,
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolParents,
      data: {
        'fullName': fullName,
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        'isActive': isActive,
      },
    );
    return extractApiData(res.data, context: 'create parent');
  }

  Future<Map<String, dynamic>> updateParent({
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    final res = await _apiClient.put(
      ApiEndpoints.schoolParentById(id),
      data: payload,
    );
    return extractApiData(res.data, context: 'update parent');
  }

  Future<Map<String, dynamic>> inviteParent({
    required String fullName,
    String? email,
    String? phone,
    String? studentId,
    String? relationType,
    bool isPrimary = false,
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolParentInvite,
      data: {
        'fullName': fullName,
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        if (studentId != null && studentId.trim().isNotEmpty)
          'studentId': studentId,
        if (relationType != null && relationType.trim().isNotEmpty)
          'relationType': relationType.trim(),
        'isPrimary': isPrimary,
      },
    );
    return extractApiData(res.data, context: 'invite parent');
  }

  Future<Map<String, dynamic>> resendParentOtp(String id) async {
    final res = await _apiClient.post(ApiEndpoints.schoolParentResendOtp(id));
    return extractApiData(res.data, context: 'resend parent otp');
  }

  Future<Map<String, dynamic>> getStaff({
    int page = 1,
    int limit = 20,
    String? search,
    String? department,
    bool? isActive,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
      if (department != null && department.isNotEmpty) 'department': department,
      if (isActive != null) 'isActive': isActive.toString(),
    };
    final res = await _apiClient.get(ApiEndpoints.schoolStaff, query: query);
    return extractApiData(res.data, context: 'staff');
  }

  Future<Map<String, dynamic>> getStaffById(String id) async {
    final res = await _apiClient.get(ApiEndpoints.schoolStaffById(id));
    return extractApiData(res.data, context: 'staff');
  }

  Future<Map<String, dynamic>> createStaff({
    required String employeeCode,
    required String fullName,
    String? email,
    String? phone,
    String? designation,
    String? department,
    bool isActive = true,
    String? joinDate,
    String? password,
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolStaff,
      data: {
        'employeeCode': employeeCode,
        'fullName': fullName,
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        if (designation != null && designation.trim().isNotEmpty)
          'designation': designation.trim(),
        if (department != null && department.trim().isNotEmpty)
          'department': department.trim(),
        if (joinDate != null && joinDate.trim().isNotEmpty)
          'joinDate': joinDate.trim(),
        if (password != null && password.isNotEmpty) 'password': password,
        'isActive': isActive,
      },
    );
    return extractApiData(res.data, context: 'create staff');
  }

  Future<Map<String, dynamic>> updateStaff({
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    final res = await _apiClient.put(
      ApiEndpoints.schoolStaffById(id),
      data: payload,
    );
    return extractApiData(res.data, context: 'update staff');
  }

  Future<Map<String, dynamic>> deleteStaff(String id) async {
    final res = await _apiClient.dio.delete(ApiEndpoints.schoolStaffById(id));
    return extractApiData(res.data, context: 'delete staff');
  }

  Future<Map<String, dynamic>> getStaffDocuments(String id) {
    return _get(
      ApiEndpoints.schoolStaffDocuments(id),
      context: 'staff documents',
    );
  }

  Future<Map<String, dynamic>> addStaffDocument({
    required String id,
    required Map<String, dynamic> payload,
  }) {
    return _post(
      ApiEndpoints.schoolStaffDocuments(id),
      payload: payload,
      context: 'add staff document',
    );
  }

  Future<Map<String, dynamic>> deleteStaffDocument({
    required String id,
    required String docId,
  }) {
    return _delete(
      ApiEndpoints.schoolStaffDocumentById(id, docId),
      context: 'delete staff document',
    );
  }

  Future<Map<String, dynamic>> getClasses({
    int page = 1,
    int limit = 100,
    String? search,
  }) async {
    final res = await _apiClient.get(
      ApiEndpoints.schoolClasses,
      query: {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    return extractApiData(res.data, context: 'classes');
  }

  Future<Map<String, dynamic>> createClass({
    required String name,
    required String section,
    String? classTeacherId,
    int? capacity,
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolClasses,
      data: {
        'name': name,
        'section': section,
        if (classTeacherId != null && classTeacherId.trim().isNotEmpty)
          'classTeacherId': classTeacherId.trim(),
        if (capacity != null) 'capacity': capacity,
      },
    );
    return extractApiData(res.data, context: 'create class');
  }

  Future<Map<String, dynamic>> updateClass({
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    final res = await _apiClient.put(
      ApiEndpoints.schoolClassById(id),
      data: payload,
    );
    return extractApiData(res.data, context: 'update class');
  }

  Future<Map<String, dynamic>> deleteClass(String id) async {
    final res = await _apiClient.dio.delete(ApiEndpoints.schoolClassById(id));
    return extractApiData(res.data, context: 'delete class');
  }

  Future<Map<String, dynamic>> getSubjects({
    int page = 1,
    int limit = 100,
    String? search,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final res = await _apiClient.get(ApiEndpoints.schoolSubjects, query: query);
    return extractApiData(res.data, context: 'subjects');
  }

  Future<Map<String, dynamic>> createSubject({
    required String name,
    required String code,
    String? classId,
    bool isActive = true,
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolSubjects,
      data: {
        'name': name,
        'code': code,
        'isActive': isActive,
        if (classId != null && classId.trim().isNotEmpty) 'classId': classId,
      },
    );
    return extractApiData(res.data, context: 'create subject');
  }

  Future<Map<String, dynamic>> updateSubject({
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    final res = await _apiClient.put(
      ApiEndpoints.schoolSubjectById(id),
      data: payload,
    );
    return extractApiData(res.data, context: 'update subject');
  }

  Future<Map<String, dynamic>> deleteSubject(String id) async {
    final res = await _apiClient.dio.delete(ApiEndpoints.schoolSubjectById(id));
    return extractApiData(res.data, context: 'delete subject');
  }
  // --- Academic Features (Curriculum, Syllabus, Lesson Plans) ---

  Future<Map<String, dynamic>> getStudyMaterials({
    int page = 1,
    int limit = 50,
    String? classId,
    String? subjectId,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (classId != null) 'classId': classId,
      if (subjectId != null) 'subjectId': subjectId,
    };
    final res = await _apiClient.get(
      ApiEndpoints.schoolStudyMaterials,
      query: query,
    );
    return extractApiData(res.data, context: 'study materials');
  }

  Future<Map<String, dynamic>> uploadStudyMaterial(
    Map<String, dynamic> payload,
  ) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolStudyMaterials,
      data: payload,
    );
    return extractApiData(res.data, context: 'upload study material');
  }

  Future<Map<String, dynamic>> getSyllabus({
    String? classId,
    String? subjectId,
  }) async {
    final res = await _apiClient.get(
      ApiEndpoints.schoolSyllabus,
      query: {
        if (classId != null) 'classId': classId,
        if (subjectId != null) 'subjectId': subjectId,
      },
    );
    return extractApiData(res.data, context: 'get syllabus');
  }

  Future<Map<String, dynamic>> getLessonPlans({
    String? classId,
    String? subjectId,
  }) async {
    final res = await _apiClient.get(
      ApiEndpoints.schoolLessonPlans,
      query: {
        if (classId != null) 'classId': classId,
        if (subjectId != null) 'subjectId': subjectId,
      },
    );
    return extractApiData(res.data, context: 'get lesson plans');
  }

  Future<Map<String, dynamic>> createSyllabus(
    Map<String, dynamic> payload,
  ) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolSyllabus,
      data: payload,
    );
    return extractApiData(res.data, context: 'create syllabus');
  }

  Future<Map<String, dynamic>> updateSyllabus(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final res = await _apiClient.put(
      ApiEndpoints.schoolSyllabusById(id),
      data: payload,
    );
    return extractApiData(res.data, context: 'update syllabus');
  }

  Future<Map<String, dynamic>> deleteSyllabus(String id) async {
    final res = await _apiClient.dio.delete(
      ApiEndpoints.schoolSyllabusById(id),
    );
    return extractApiData(res.data, context: 'delete syllabus');
  }

  Future<Map<String, dynamic>> createLessonPlan(
    Map<String, dynamic> payload,
  ) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolLessonPlans,
      data: payload,
    );
    return extractApiData(res.data, context: 'create lesson plan');
  }

  Future<Map<String, dynamic>> updateLessonPlan(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final res = await _apiClient.put(
      ApiEndpoints.schoolLessonPlanById(id),
      data: payload,
    );
    return extractApiData(res.data, context: 'update lesson plan');
  }

  Future<Map<String, dynamic>> deleteLessonPlan(String id) async {
    final res = await _apiClient.dio.delete(
      ApiEndpoints.schoolLessonPlanById(id),
    );
    return extractApiData(res.data, context: 'delete lesson plan');
  }

  Future<Map<String, dynamic>> deleteStudyMaterial(String id) async {
    final res = await _apiClient.dio.delete(
      '${ApiEndpoints.schoolStudyMaterials}/$id',
    );
    return extractApiData(res.data, context: 'delete study material');
  }

  Future<Map<String, dynamic>> getHomework({
    int page = 1,
    int limit = 50,
    String? classId,
    String? subjectId,
  }) {
    return _get(
      ApiEndpoints.schoolHomework,
      query: {
        'page': page,
        'limit': limit,
        if (classId != null && classId.trim().isNotEmpty)
          'classId': classId.trim(),
        if (subjectId != null && subjectId.trim().isNotEmpty)
          'subjectId': subjectId.trim(),
      },
      context: 'homework',
    );
  }

  Future<Map<String, dynamic>> getHomeworkById(String id) {
    return _get(ApiEndpoints.schoolHomeworkById(id), context: 'homework');
  }

  Future<Map<String, dynamic>> createHomework(Map<String, dynamic> payload) {
    return _post(
      ApiEndpoints.schoolHomework,
      payload: payload,
      context: 'create homework',
    );
  }

  Future<Map<String, dynamic>> updateHomework({
    required String id,
    required Map<String, dynamic> payload,
  }) {
    return _put(
      ApiEndpoints.schoolHomeworkById(id),
      payload: payload,
      context: 'update homework',
    );
  }

  Future<Map<String, dynamic>> deleteHomework(String id) {
    return _delete(
      ApiEndpoints.schoolHomeworkById(id),
      context: 'delete homework',
    );
  }

  Future<Map<String, dynamic>> submitHomework({
    required String id,
    required Map<String, dynamic> payload,
  }) {
    return _post(
      ApiEndpoints.schoolHomeworkSubmit(id),
      payload: payload,
      context: 'submit homework',
    );
  }

  Future<Map<String, dynamic>> getReportCardTemplates({
    int page = 1,
    int limit = 50,
  }) {
    return _get(
      ApiEndpoints.schoolReportCardTemplates,
      query: {'page': page, 'limit': limit},
      context: 'report card templates',
    );
  }

  Future<Map<String, dynamic>> createReportCardTemplate(
    Map<String, dynamic> payload,
  ) {
    return _post(
      ApiEndpoints.schoolReportCardTemplates,
      payload: payload,
      context: 'create report card template',
    );
  }

  Future<Map<String, dynamic>> updateReportCardTemplate({
    required String id,
    required Map<String, dynamic> payload,
  }) {
    return _put(
      ApiEndpoints.schoolReportCardTemplateById(id),
      payload: payload,
      context: 'update report card template',
    );
  }

  Future<Map<String, dynamic>> deleteReportCardTemplate(String id) {
    return _delete(
      ApiEndpoints.schoolReportCardTemplateById(id),
      context: 'delete report card template',
    );
  }

  Future<Map<String, dynamic>> getFaceCheckins({
    int page = 1,
    int limit = 50,
    String? status,
  }) {
    return _get(
      ApiEndpoints.schoolFaceCheckins,
      query: {
        'page': page,
        'limit': limit,
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
      },
      context: 'face check-ins',
    );
  }

  Future<Map<String, dynamic>> approveFaceCheckin(String id) {
    return _patch(
      ApiEndpoints.schoolFaceCheckinApprove(id),
      context: 'approve face check-in',
    );
  }

  Future<Map<String, dynamic>> rejectFaceCheckin({
    required String id,
    String? reason,
  }) {
    return _patch(
      ApiEndpoints.schoolFaceCheckinReject(id),
      payload: {
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
      context: 'reject face check-in',
    );
  }

  Future<Map<String, dynamic>> getBackupExports({
    int page = 1,
    int limit = 50,
  }) {
    return _get(
      ApiEndpoints.schoolBackupExports,
      query: {'page': page, 'limit': limit},
      context: 'backup exports',
    );
  }

  Future<Map<String, dynamic>> createBackupExport(
    Map<String, dynamic> payload,
  ) {
    return _post(
      ApiEndpoints.schoolBackupExports,
      payload: payload,
      context: 'create backup export',
    );
  }

  Future<Map<String, dynamic>> getOfflineSyncRecords({
    int page = 1,
    int limit = 50,
    String? status,
  }) {
    return _get(
      ApiEndpoints.schoolOfflineSyncRecords,
      query: {
        'page': page,
        'limit': limit,
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
      },
      context: 'offline sync records',
    );
  }

  Future<Map<String, dynamic>> createOfflineSyncRecord(
    Map<String, dynamic> payload,
  ) {
    return _post(
      ApiEndpoints.schoolOfflineSyncRecords,
      payload: payload,
      context: 'create offline sync record',
    );
  }

  Future<Map<String, dynamic>> patchOfflineSyncRecord({
    required String id,
    required Map<String, dynamic> payload,
  }) {
    return _patch(
      ApiEndpoints.schoolOfflineSyncRecordById(id),
      payload: payload,
      context: 'patch offline sync record',
    );
  }

  Future<Map<String, dynamic>> getAttendanceReport({
    String? dateFrom,
    String? dateTo,
    String type = 'student',
    String? className,
    String? section,
  }) async {
    final query = <String, dynamic>{
      'type': type,
      if (dateFrom != null && dateFrom.isNotEmpty) 'dateFrom': dateFrom,
      if (dateTo != null && dateTo.isNotEmpty) 'dateTo': dateTo,
      if (className != null && className.isNotEmpty) 'className': className,
      if (section != null && section.isNotEmpty) 'section': section,
    };
    final res = await _apiClient.get(
      ApiEndpoints.schoolReportAttendance,
      query: query,
    );
    final reportData = extractApiData(res.data, context: 'attendance report');

    try {
      final exportRes = await _apiClient.get(
        ApiEndpoints.schoolAttendanceExport,
        query: {
          'type': type,
          if (dateFrom != null && dateFrom.isNotEmpty) 'dateFrom': dateFrom,
          if (dateTo != null && dateTo.isNotEmpty) 'dateTo': dateTo,
          'format': 'json',
        },
      );
      final exportData = extractApiData(
        exportRes.data,
        context: 'attendance export records',
      );
      final records = exportData['records'] ?? exportData['items'];
      if (records is List) {
        return {...reportData, 'records': records};
      }
    } catch (_) {
      // Summary report is still useful even if the detailed export endpoint is unavailable.
    }

    return reportData;
  }

  Future<Map<String, dynamic>> getFeesReport({
    String? dateFrom,
    String? dateTo,
    String? className,
    String? section,
  }) async {
    final query = <String, dynamic>{
      if (dateFrom != null && dateFrom.isNotEmpty) 'dateFrom': dateFrom,
      if (dateTo != null && dateTo.isNotEmpty) 'dateTo': dateTo,
      if (className != null && className.isNotEmpty) 'className': className,
      if (section != null && section.isNotEmpty) 'section': section,
    };
    final res = await _apiClient.get(
      ApiEndpoints.schoolReportFees,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'fees report');
  }

  Future<Map<String, dynamic>> getExamPerformanceReport({
    String? examId,
    String? classId,
    String? subjectId,
  }) {
    return _get(
      ApiEndpoints.schoolReportExamPerformance,
      query: {
        if (examId != null && examId.trim().isNotEmpty) 'examId': examId.trim(),
        if (classId != null && classId.trim().isNotEmpty)
          'classId': classId.trim(),
        if (subjectId != null && subjectId.trim().isNotEmpty)
          'subjectId': subjectId.trim(),
      },
      context: 'exam performance report',
    );
  }

  Future<Map<String, dynamic>> getStudentsReport({
    String? classId,
    String? status,
  }) {
    return _get(
      ApiEndpoints.schoolReportStudents,
      query: {
        if (classId != null && classId.trim().isNotEmpty)
          'classId': classId.trim(),
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
      },
      context: 'students report',
    );
  }

  Future<Map<String, dynamic>> getReportJobs({int page = 1, int limit = 50}) {
    return _get(
      ApiEndpoints.schoolReportJobs,
      query: {'page': page, 'limit': limit},
      context: 'report jobs',
    );
  }

  Future<Map<String, dynamic>> getStaffProductivityReport({
    String? staffId,
    String? dateFrom,
    String? dateTo,
  }) {
    return _get(
      '/school/reports/staff-productivity',
      query: {
        if (staffId != null && staffId.trim().isNotEmpty)
          'staffId': staffId.trim(),
        if (dateFrom != null && dateFrom.trim().isNotEmpty)
          'dateFrom': dateFrom.trim(),
        if (dateTo != null && dateTo.trim().isNotEmpty) 'dateTo': dateTo.trim(),
      },
      context: 'staff productivity report',
    );
  }

  Future<Map<String, dynamic>> getSyllabusProgressReport({
    String? classId,
    String? subjectId,
  }) {
    return _get(
      '/school/reports/syllabus-progress',
      query: {
        if (classId != null && classId.trim().isNotEmpty)
          'classId': classId.trim(),
        if (subjectId != null && subjectId.trim().isNotEmpty)
          'subjectId': subjectId.trim(),
      },
      context: 'syllabus progress report',
    );
  }

  Future<Map<String, dynamic>> generateReport(Map<String, dynamic> payload) {
    return _post(
      ApiEndpoints.schoolReportGenerate,
      payload: payload,
      context: 'generate report',
    );
  }

  Future<Map<String, dynamic>> getAdmissionApplications({
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (status != null && status.isNotEmpty) 'status': status,
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final res = await _apiClient.get(
      ApiEndpoints.schoolAdmissionsApplications,
      query: query,
    );
    return extractApiData(res.data, context: 'admission applications');
  }

  Future<Map<String, dynamic>> getAdmissionApplicationById(String id) async {
    final res = await _apiClient.get(
      ApiEndpoints.schoolAdmissionApplicationById(id),
    );
    return extractApiData(res.data, context: 'admission application');
  }

  Future<Map<String, dynamic>> createAdmissionApplication({
    required String firstName,
    required String lastName,
    required String appliedClass,
    String? appliedSection,
    String? email,
    String? phone,
    String? gender,
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolAdmissionsApplications,
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'appliedClass': appliedClass,
        if (appliedSection != null && appliedSection.trim().isNotEmpty)
          'appliedSection': appliedSection.trim(),
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        if (gender != null && gender.trim().isNotEmpty) 'gender': gender.trim(),
      },
    );
    return extractApiData(res.data, context: 'create admission application');
  }

  Future<Map<String, dynamic>> updateAdmissionApplicationStatus({
    required String id,
    required String status,
  }) async {
    final res = await _apiClient.patch(
      ApiEndpoints.schoolAdmissionApplicationStatus(id),
      data: {'status': status},
    );
    return extractApiData(
      res.data,
      context: 'update admission application status',
    );
  }

  Future<Map<String, dynamic>> addAdmissionApplicationDocument({
    required String id,
    required String name,
    required String url,
    String? type,
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolAdmissionApplicationDocuments(id),
      data: {
        'name': name,
        'url': url,
        if (type != null && type.trim().isNotEmpty) 'type': type.trim(),
      },
    );
    return extractApiData(
      res.data,
      context: 'add admission application document',
    );
  }

  Future<Map<String, dynamic>> onboardAdmissionApplication(String id) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolAdmissionApplicationOnboard(id),
    );
    return extractApiData(res.data, context: 'onboard admission application');
  }

  Future<Map<String, dynamic>> getStudents({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? className,
    String? section,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
      if (status != null && status.isNotEmpty) 'status': status,
      if (className != null && className.isNotEmpty) 'className': className,
      if (section != null && section.isNotEmpty) 'section': section,
    };
    final res = await _apiClient.get(ApiEndpoints.schoolStudents, query: query);
    return extractApiData(res.data, context: 'students');
  }

  Future<Map<String, dynamic>> exportStudents({
    String? status,
    String? className,
    String? section,
  }) {
    return _get(
      ApiEndpoints.schoolStudentsExport,
      query: {
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
        if (className != null && className.trim().isNotEmpty)
          'className': className.trim(),
        if (section != null && section.trim().isNotEmpty)
          'section': section.trim(),
      },
      context: 'export students',
    );
  }

  Future<Map<String, dynamic>> importStudents(Map<String, dynamic> payload) {
    return _post(
      ApiEndpoints.schoolStudentsImport,
      payload: payload,
      context: 'import students',
    );
  }

  Future<Map<String, dynamic>> getStudentById(String id) async {
    final res = await _apiClient.get(ApiEndpoints.schoolStudentById(id));
    return extractApiData(res.data, context: 'student');
  }

  Future<Map<String, dynamic>> createStudent({
    required String admissionNo,
    required String firstName,
    required String lastName,
    required String className,
    String? classId,
    String? section,
    int? rollNo,
    String? gender,
    String? guardianPhone,
    String? status,
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolStudents,
      data: {
        'admissionNo': admissionNo,
        'firstName': firstName,
        'lastName': lastName,
        'className': className,
        if (classId != null && classId.trim().isNotEmpty) 'classId': classId,
        if (section != null && section.trim().isNotEmpty)
          'section': section.trim(),
        if (rollNo != null) 'rollNo': rollNo,
        if (gender != null && gender.trim().isNotEmpty) 'gender': gender.trim(),
        if (guardianPhone != null && guardianPhone.trim().isNotEmpty)
          'guardianPhone': guardianPhone.trim(),
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
      },
    );
    return extractApiData(res.data, context: 'create student');
  }

  Future<Map<String, dynamic>> updateStudent({
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    final res = await _apiClient.put(
      ApiEndpoints.schoolStudentById(id),
      data: payload,
    );
    return extractApiData(res.data, context: 'update student');
  }

  Future<Map<String, dynamic>> deleteStudent(String id) async {
    final res = await _apiClient.dio.delete(ApiEndpoints.schoolStudentById(id));
    return extractApiData(res.data, context: 'delete student');
  }

  Future<Map<String, dynamic>> updateStudentStatus({
    required String id,
    required String status,
  }) async {
    final res = await _apiClient.patch(
      ApiEndpoints.schoolStudentStatus(id),
      data: {'status': status},
    );
    return extractApiData(res.data, context: 'update student status');
  }

  Future<Map<String, dynamic>> moveStudentClass({
    required String id,
    required String className,
    String? classId,
    String? section,
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolStudentMoveClass(id),
      data: {
        'className': className,
        if (classId != null && classId.trim().isNotEmpty) 'classId': classId,
        if (section != null && section.trim().isNotEmpty)
          'section': section.trim(),
      },
    );
    return extractApiData(res.data, context: 'move student class');
  }

  Future<Map<String, dynamic>> addStudentDocument({
    required String id,
    required String name,
    required String url,
    String? type,
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolStudentDocuments(id),
      data: {
        'name': name,
        'url': url,
        if (type != null && type.trim().isNotEmpty) 'type': type.trim(),
      },
    );
    return extractApiData(res.data, context: 'add student document');
  }

  Future<Map<String, dynamic>> deleteStudentDocument({
    required String id,
    required String docId,
  }) {
    return _delete(
      ApiEndpoints.schoolStudentDocumentById(id, docId),
      context: 'delete student document',
    );
  }

  Future<Map<String, dynamic>> getTimetable({
    String? classId,
    String? dateFrom,
    String? dateTo,
  }) async {
    final query = <String, dynamic>{
      if (classId != null && classId.trim().isNotEmpty) 'classId': classId,
      if (dateFrom != null && dateFrom.trim().isNotEmpty) 'dateFrom': dateFrom,
      if (dateTo != null && dateTo.trim().isNotEmpty) 'dateTo': dateTo,
    };
    final res = await _apiClient.get(
      ApiEndpoints.schoolTimetable,
      query: query.isEmpty ? null : query,
    );
    return extractApiData(res.data, context: 'timetable');
  }

  Future<Map<String, dynamic>> getClassTimetable({
    required String classId,
    String? dateFrom,
    String? dateTo,
  }) {
    return _get(
      ApiEndpoints.schoolTimetableClass(classId),
      query: {
        if (dateFrom != null && dateFrom.trim().isNotEmpty)
          'dateFrom': dateFrom.trim(),
        if (dateTo != null && dateTo.trim().isNotEmpty) 'dateTo': dateTo.trim(),
      },
      context: 'class timetable',
    );
  }

  Future<Map<String, dynamic>> getTeacherTimetable({
    required String staffId,
    String? dateFrom,
    String? dateTo,
  }) {
    return _get(
      ApiEndpoints.schoolTimetableTeacher(staffId),
      query: {
        if (dateFrom != null && dateFrom.trim().isNotEmpty)
          'dateFrom': dateFrom.trim(),
        if (dateTo != null && dateTo.trim().isNotEmpty) 'dateTo': dateTo.trim(),
      },
      context: 'teacher timetable',
    );
  }

  Future<Map<String, dynamic>> getTimetableConflicts({
    String? classId,
    String? staffId,
    String? date,
  }) {
    return _get(
      ApiEndpoints.schoolTimetableConflicts,
      query: {
        if (classId != null && classId.trim().isNotEmpty)
          'classId': classId.trim(),
        if (staffId != null && staffId.trim().isNotEmpty)
          'staffId': staffId.trim(),
        if (date != null && date.trim().isNotEmpty) 'date': date.trim(),
      },
      context: 'timetable conflicts',
    );
  }

  Future<Map<String, dynamic>> getTimetablePeriods({
    int page = 1,
    int limit = 50,
  }) {
    return _get(
      ApiEndpoints.schoolTimetablePeriods,
      query: {'page': page, 'limit': limit},
      context: 'timetable periods',
    );
  }

  Future<Map<String, dynamic>> createTimetablePeriod(
    Map<String, dynamic> payload,
  ) {
    return _post(
      ApiEndpoints.schoolTimetablePeriods,
      payload: payload,
      context: 'create timetable period',
    );
  }

  Future<Map<String, dynamic>> updateTimetablePeriod({
    required String id,
    required Map<String, dynamic> payload,
  }) {
    return _put(
      ApiEndpoints.schoolTimetablePeriodById(id),
      payload: payload,
      context: 'update timetable period',
    );
  }

  Future<Map<String, dynamic>> deleteTimetablePeriod(String id) {
    return _delete(
      ApiEndpoints.schoolTimetablePeriodById(id),
      context: 'delete timetable period',
    );
  }

  Future<Map<String, dynamic>> createTimetableSlot({
    required Map<String, dynamic> payload,
  }) async {
    final res = await _apiClient.post(
      '${ApiEndpoints.schoolTimetable}/slots',
      data: payload,
    );
    return extractApiData(res.data, context: 'create timetable slot');
  }

  Future<Map<String, dynamic>> updateTimetableSlot({
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    final res = await _apiClient.put(
      ApiEndpoints.schoolTimetableSlotById(id),
      data: payload,
    );
    return extractApiData(res.data, context: 'update timetable slot');
  }

  Future<Map<String, dynamic>> deleteTimetableSlot(String id) async {
    final res = await _apiClient.dio.delete(
      ApiEndpoints.schoolTimetableSlotById(id),
    );
    return extractApiData(res.data, context: 'delete timetable slot');
  }

  Future<Map<String, dynamic>> publishTimetable({
    String? classId,
    String? dateFrom,
    String? dateTo,
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolTimetablePublish,
      data: {
        if (classId != null && classId.trim().isNotEmpty) 'classId': classId,
        if (dateFrom != null && dateFrom.trim().isNotEmpty)
          'dateFrom': dateFrom,
        if (dateTo != null && dateTo.trim().isNotEmpty) 'dateTo': dateTo,
      },
    );
    return extractApiData(res.data, context: 'publish timetable');
  }

  Future<Map<String, dynamic>> getLiveClassSessions({
    int page = 1,
    int limit = 50,
    String? status,
    String? classId,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (status != null && status.trim().isNotEmpty) 'status': status,
      if (classId != null && classId.trim().isNotEmpty) 'classId': classId,
    };
    final res = await _apiClient.get(
      ApiEndpoints.schoolLiveClassSessions,
      query: query,
    );
    return extractApiData(res.data, context: 'live class sessions');
  }

  Future<Map<String, dynamic>> createLiveClassSession(
    Map<String, dynamic> payload,
  ) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolLiveClassSessions,
      data: payload,
    );
    return extractApiData(res.data, context: 'create live class session');
  }

  Future<Map<String, dynamic>> updateLiveClassSession({
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    final res = await _apiClient.put(
      ApiEndpoints.schoolLiveClassSessionById(id),
      data: payload,
    );
    return extractApiData(res.data, context: 'update live class session');
  }

  Future<Map<String, dynamic>> endLiveClassSession(String id) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolLiveClassSessionEnd(id),
    );
    return extractApiData(res.data, context: 'end live class session');
  }

  Future<Map<String, dynamic>> getExams({
    int page = 1,
    int limit = 50,
    String? classId,
    String? subjectId,
    bool? isPublished,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (classId != null && classId.trim().isNotEmpty) 'classId': classId,
      if (subjectId != null && subjectId.trim().isNotEmpty)
        'subjectId': subjectId,
      if (isPublished != null) 'isPublished': isPublished.toString(),
    };
    final res = await _apiClient.get(ApiEndpoints.schoolExams, query: query);
    return extractApiData(res.data, context: 'exams');
  }

  Future<Map<String, dynamic>> createExam(Map<String, dynamic> payload) async {
    final res = await _apiClient.post(ApiEndpoints.schoolExams, data: payload);
    return extractApiData(res.data, context: 'create exam');
  }

  Future<Map<String, dynamic>> updateExam({
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    final res = await _apiClient.put(
      ApiEndpoints.schoolExamById(id),
      data: payload,
    );
    return extractApiData(res.data, context: 'update exam');
  }

  Future<Map<String, dynamic>> deleteExam(String id) async {
    final res = await _apiClient.dio.delete(ApiEndpoints.schoolExamById(id));
    return extractApiData(res.data, context: 'delete exam');
  }

  Future<Map<String, dynamic>> publishExam(String id) async {
    final res = await _apiClient.post(ApiEndpoints.schoolExamPublish(id));
    return extractApiData(res.data, context: 'publish exam');
  }

  Future<Map<String, dynamic>> getExamMarksStatus(String id) async {
    final res = await _apiClient.get(ApiEndpoints.schoolExamMarksStatus(id));
    return extractApiData(res.data, context: 'exam marks status');
  }

  Future<Map<String, dynamic>> saveExamMarks({
    required String id,
    required List<Map<String, dynamic>> results,
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolExamMarks(id),
      data: {'results': results},
    );
    return extractApiData(res.data, context: 'save exam marks');
  }

  Future<Map<String, dynamic>> getLibraryBooks({
    int page = 1,
    int limit = 50,
    String? search,
    String? category,
    bool? isActive,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search.trim().isNotEmpty) 'search': search,
      if (category != null && category.trim().isNotEmpty) 'category': category,
      if (isActive != null) 'isActive': isActive.toString(),
    };
    final res = await _apiClient.get(
      ApiEndpoints.schoolLibraryBooks,
      query: query,
    );
    return extractApiData(res.data, context: 'library books');
  }

  Future<Map<String, dynamic>> createLibraryBook(
    Map<String, dynamic> payload,
  ) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolLibraryBooks,
      data: payload,
    );
    return extractApiData(res.data, context: 'create library book');
  }

  Future<Map<String, dynamic>> updateLibraryBook({
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    final res = await _apiClient.put(
      ApiEndpoints.schoolLibraryBookById(id),
      data: payload,
    );
    return extractApiData(res.data, context: 'update library book');
  }

  Future<Map<String, dynamic>> deleteLibraryBook(String id) async {
    final res = await _apiClient.dio.delete(
      ApiEndpoints.schoolLibraryBookById(id),
    );
    return extractApiData(res.data, context: 'delete library book');
  }

  Future<Map<String, dynamic>> getLibraryBorrows({
    int page = 1,
    int limit = 50,
    String? status,
    String? borrowerType,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (status != null && status.trim().isNotEmpty) 'status': status,
      if (borrowerType != null && borrowerType.trim().isNotEmpty)
        'borrowerType': borrowerType,
    };
    final res = await _apiClient.get(
      ApiEndpoints.schoolLibraryBorrows,
      query: query,
    );
    return extractApiData(res.data, context: 'library borrows');
  }

  Future<Map<String, dynamic>> createLibraryBorrow(
    Map<String, dynamic> payload,
  ) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolLibraryBorrows,
      data: payload,
    );
    return extractApiData(res.data, context: 'create library borrow');
  }

  Future<Map<String, dynamic>> returnLibraryBorrow(String id) async {
    final res = await _apiClient.patch(
      ApiEndpoints.schoolLibraryBorrowReturn(id),
    );
    return extractApiData(res.data, context: 'return library borrow');
  }

  Future<Map<String, dynamic>> getInventoryItems({
    int page = 1,
    int limit = 50,
    String? search,
    String? category,
    bool? isActive,
    bool? lowStockOnly,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search.trim().isNotEmpty) 'search': search,
      if (category != null && category.trim().isNotEmpty) 'category': category,
      if (isActive != null) 'isActive': isActive.toString(),
      if (lowStockOnly != null) 'lowStockOnly': lowStockOnly.toString(),
    };
    final res = await _apiClient.get(
      ApiEndpoints.schoolInventoryItems,
      query: query,
    );
    return extractApiData(res.data, context: 'inventory items');
  }

  Future<Map<String, dynamic>> createInventoryItem(
    Map<String, dynamic> payload,
  ) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolInventoryItems,
      data: payload,
    );
    return extractApiData(res.data, context: 'create inventory item');
  }

  Future<Map<String, dynamic>> updateInventoryItem({
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    final res = await _apiClient.put(
      ApiEndpoints.schoolInventoryItemById(id),
      data: payload,
    );
    return extractApiData(res.data, context: 'update inventory item');
  }

  Future<Map<String, dynamic>> deleteInventoryItem(String id) async {
    final res = await _apiClient.dio.delete(
      ApiEndpoints.schoolInventoryItemById(id),
    );
    return extractApiData(res.data, context: 'delete inventory item');
  }

  Future<Map<String, dynamic>> getInventoryTransactions({
    int page = 1,
    int limit = 50,
    String? itemId,
    String? type,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (itemId != null && itemId.trim().isNotEmpty) 'itemId': itemId,
      if (type != null && type.trim().isNotEmpty) 'type': type,
    };
    final res = await _apiClient.get(
      ApiEndpoints.schoolInventoryTransactions,
      query: query,
    );
    return extractApiData(res.data, context: 'inventory transactions');
  }

  Future<Map<String, dynamic>> createInventoryTransaction(
    Map<String, dynamic> payload,
  ) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolInventoryTransactions,
      data: payload,
    );
    return extractApiData(res.data, context: 'create inventory transaction');
  }

  Future<Map<String, dynamic>> getTransportRoutes({
    int page = 1,
    int limit = 50,
  }) async {
    final res = await _apiClient.get(
      ApiEndpoints.schoolTransportRoutes,
      query: {'page': page, 'limit': limit},
    );
    return extractApiData(res.data, context: 'transport routes');
  }

  Future<Map<String, dynamic>> createTransportRoute(
    Map<String, dynamic> payload,
  ) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolTransportRoutes,
      data: payload,
    );
    return extractApiData(res.data, context: 'create transport route');
  }

  Future<Map<String, dynamic>> updateTransportRoute({
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    final res = await _apiClient.put(
      ApiEndpoints.schoolTransportRouteById(id),
      data: payload,
    );
    return extractApiData(res.data, context: 'update transport route');
  }

  Future<Map<String, dynamic>> deleteTransportRoute(String id) async {
    final res = await _apiClient.dio.delete(
      ApiEndpoints.schoolTransportRouteById(id),
    );
    return extractApiData(res.data, context: 'delete transport route');
  }

  Future<Map<String, dynamic>> getTransportDrivers({
    int page = 1,
    int limit = 50,
  }) async {
    final res = await _apiClient.get(
      ApiEndpoints.schoolTransportDrivers,
      query: {'page': page, 'limit': limit},
    );
    return extractApiData(res.data, context: 'transport drivers');
  }

  Future<Map<String, dynamic>> createTransportDriver(
    Map<String, dynamic> payload,
  ) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolTransportDrivers,
      data: payload,
    );
    return extractApiData(res.data, context: 'create transport driver');
  }

  Future<Map<String, dynamic>> updateTransportDriver({
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    final res = await _apiClient.put(
      ApiEndpoints.schoolTransportDriverById(id),
      data: payload,
    );
    return extractApiData(res.data, context: 'update transport driver');
  }

  Future<Map<String, dynamic>> getTransportAllocations({
    int page = 1,
    int limit = 50,
    String? routeId,
    String? studentId,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (routeId != null && routeId.trim().isNotEmpty) 'routeId': routeId,
      if (studentId != null && studentId.trim().isNotEmpty)
        'studentId': studentId,
    };
    final res = await _apiClient.get(
      ApiEndpoints.schoolTransportAllocations,
      query: query,
    );
    return extractApiData(res.data, context: 'transport allocations');
  }

  Future<Map<String, dynamic>> createTransportAllocation(
    Map<String, dynamic> payload,
  ) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolTransportAllocations,
      data: payload,
    );
    return extractApiData(res.data, context: 'create transport allocation');
  }

  Future<Map<String, dynamic>> updateTransportAllocation({
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    final res = await _apiClient.put(
      ApiEndpoints.schoolTransportAllocationById(id),
      data: payload,
    );
    return extractApiData(res.data, context: 'update transport allocation');
  }

  Future<Map<String, dynamic>> deleteTransportAllocation(String id) async {
    final res = await _apiClient.dio.delete(
      ApiEndpoints.schoolTransportAllocationById(id),
    );
    return extractApiData(res.data, context: 'delete transport allocation');
  }

  Future<Map<String, dynamic>> getHostelRooms() async {
    final res = await _apiClient.get(ApiEndpoints.schoolHostelRooms);
    return extractApiData(res.data, context: 'hostel rooms');
  }

  Future<Map<String, dynamic>> createHostelRoom(
    Map<String, dynamic> payload,
  ) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolHostelRooms,
      data: payload,
    );
    return extractApiData(res.data, context: 'create hostel room');
  }

  Future<Map<String, dynamic>> updateHostelRoom({
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    final res = await _apiClient.put(
      ApiEndpoints.schoolHostelRoomById(id),
      data: payload,
    );
    return extractApiData(res.data, context: 'update hostel room');
  }

  Future<Map<String, dynamic>> deleteHostelRoom(String id) async {
    final res = await _apiClient.dio.delete(
      ApiEndpoints.schoolHostelRoomById(id),
    );
    return extractApiData(res.data, context: 'delete hostel room');
  }

  Future<Map<String, dynamic>> getHostelAllocations({
    int page = 1,
    int limit = 50,
    String? roomId,
    String? studentId,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (roomId != null && roomId.trim().isNotEmpty) 'roomId': roomId,
      if (studentId != null && studentId.trim().isNotEmpty)
        'studentId': studentId,
    };
    final res = await _apiClient.get(
      ApiEndpoints.schoolHostelAllocations,
      query: query,
    );
    return extractApiData(res.data, context: 'hostel allocations');
  }

  Future<Map<String, dynamic>> createHostelAllocation(
    Map<String, dynamic> payload,
  ) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolHostelAllocations,
      data: payload,
    );
    return extractApiData(res.data, context: 'create hostel allocation');
  }

  Future<Map<String, dynamic>> getHostelAttendance({String? date}) async {
    final res = await _apiClient.get(
      ApiEndpoints.schoolHostelAttendance,
      query: {if (date != null && date.trim().isNotEmpty) 'date': date},
    );
    return extractApiData(res.data, context: 'hostel attendance');
  }

  Future<Map<String, dynamic>> markHostelAttendance(
    Map<String, dynamic> payload,
  ) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolHostelAttendance,
      data: payload,
    );
    return extractApiData(res.data, context: 'mark hostel attendance');
  }

  Future<Map<String, dynamic>> getHostelVisitors({
    int page = 1,
    int limit = 50,
  }) async {
    final res = await _apiClient.get(
      ApiEndpoints.schoolHostelVisitors,
      query: {'page': page, 'limit': limit},
    );
    return extractApiData(res.data, context: 'hostel visitors');
  }

  Future<Map<String, dynamic>> createHostelVisitor(
    Map<String, dynamic> payload,
  ) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolHostelVisitors,
      data: payload,
    );
    return extractApiData(res.data, context: 'create hostel visitor');
  }

  Future<Map<String, dynamic>> getEvents({
    int page = 1,
    int limit = 50,
    String? from,
    String? to,
    String? eventType,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (from != null && from.trim().isNotEmpty) 'from': from,
      if (to != null && to.trim().isNotEmpty) 'to': to,
      if (eventType != null && eventType.trim().isNotEmpty)
        'eventType': eventType,
    };
    final res = await _apiClient.get(ApiEndpoints.schoolEvents, query: query);
    return extractApiData(res.data, context: 'events');
  }

  Future<Map<String, dynamic>> getEventById(String id) async {
    final res = await _apiClient.get(ApiEndpoints.schoolEventById(id));
    return extractApiData(res.data, context: 'event');
  }

  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> payload) async {
    final res = await _apiClient.post(ApiEndpoints.schoolEvents, data: payload);
    return extractApiData(res.data, context: 'create event');
  }

  Future<Map<String, dynamic>> updateEvent({
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    final res = await _apiClient.put(
      ApiEndpoints.schoolEventById(id),
      data: payload,
    );
    return extractApiData(res.data, context: 'update event');
  }

  Future<Map<String, dynamic>> deleteEvent(String id) async {
    final res = await _apiClient.dio.delete(ApiEndpoints.schoolEventById(id));
    return extractApiData(res.data, context: 'delete event');
  }

  Future<Map<String, dynamic>> registerForEvent({
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolEventRegistrations(id),
      data: payload,
    );
    return extractApiData(res.data, context: 'register for event');
  }

  Future<Map<String, dynamic>> addEventGalleryImage({
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.schoolEventGallery(id),
      data: payload,
    );
    return extractApiData(res.data, context: 'add event gallery image');
  }

  Future<Map<String, dynamic>> deleteEventGalleryImage({
    required String id,
    required String imageId,
  }) async {
    final res = await _apiClient.dio.delete(
      ApiEndpoints.schoolEventGalleryImage(id, imageId),
    );
    return extractApiData(res.data, context: 'delete event gallery image');
  }

  Future<Map<String, dynamic>> deleteAdmissionApplication(String id) async {
    final res = await _apiClient.dio.delete(
      ApiEndpoints.schoolAdmissionApplicationById(id),
    );
    return extractApiData(res.data, context: 'delete admission application');
  }

  Future<Map<String, dynamic>> updateAdmissionFees(double fee) async {
    final normalized = fee < 0 ? 0 : fee;
    final list = await getFeeStructures(page: 1, limit: 100);
    final items = (list['items'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final existing = items.firstWhere(
      (item) =>
          ((item['name'] ?? '').toString().trim().toLowerCase() ==
              'admission fee'),
      orElse: () => const <String, dynamic>{},
    );
    final payload = <String, dynamic>{
      'name': 'Admission Fee',
      'amount': normalized,
      'frequency': 'ONE_TIME',
      'currency': 'INR',
      'isActive': true,
    };
    if ((existing['id'] ?? '').toString().trim().isNotEmpty) {
      return updateFeeStructure(
        id: existing['id'].toString(),
        payload: payload,
      );
    }
    return createFeeStructure(payload);
  }
}
