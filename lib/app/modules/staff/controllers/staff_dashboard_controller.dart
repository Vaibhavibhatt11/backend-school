import 'package:erp_frontend/app/modules/staff/widgets/staff_ai_assistant_sheet.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/app/modules/staff/utils/staff_portal_navigation.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/services/staff/staff_service.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:erp_frontend/common/utils/safe_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffDashboardController extends GetxController {
  StaffDashboardController(this._staffService);

  final StaffService _staffService;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final todaySchedule = <String>[].obs;
  final assignedClasses = <String>[].obs;
  final pendingTasks = <String>[].obs;
  final studentAlerts = <String>[].obs;
  final upcomingExams = <String>[].obs;
  final meetings = <String>[].obs;
  final notifications = <String>[].obs;
  final homeworkStatus = <String>[].obs;
  final staffName = ''.obs;
  final todayScheduleItems = <Map<String, String>>[].obs;
  final selectedDashboardTab = 0.obs;

  final scheduleRecords = <Map<String, String>>[].obs;
  final classRecords = <Map<String, String>>[].obs;
  final taskRecords = <Map<String, String>>[].obs;
  final alertRecords = <Map<String, String>>[].obs;
  final notificationRecords = <Map<String, String>>[].obs;
  final homeworkRecords = <Map<String, String>>[].obs;
  final examRecords = <Map<String, String>>[].obs;
  final meetingRecords = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _staffService.getDashboard();
      staffName.value = (data['staffName'] ?? '').toString();
      todaySchedule.assignAll(_asStringList(data['todaySchedule']));
      _parseScheduleItems(data['todayScheduleItems']);
      assignedClasses.assignAll(_asStringList(data['assignedClasses']));
      pendingTasks.assignAll(_asStringList(data['pendingTasks']));
      studentAlerts.assignAll(_asStringList(data['studentAlerts']));
      upcomingExams.assignAll(_asStringList(data['upcomingExams']));
      meetings.assignAll(_asStringList(data['meetings']));
      notifications.assignAll(_asStringList(data['notifications']));
      homeworkStatus.assignAll(_asStringList(data['homeworkStatus']));
      _buildDashboardRecords();
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      AppToast.show(errorMessage.value);
      todaySchedule.clear();
      assignedClasses.clear();
      pendingTasks.clear();
      studentAlerts.clear();
      upcomingExams.clear();
      meetings.clear();
      notifications.clear();
      homeworkStatus.clear();
      staffName.value = '';
      todayScheduleItems.clear();
      scheduleRecords.clear();
      classRecords.clear();
      taskRecords.clear();
      alertRecords.clear();
      notificationRecords.clear();
      homeworkRecords.clear();
      examRecords.clear();
      meetingRecords.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void setDashboardTab(int index) {
    if (index < 0 || index > 7) return;
    selectedDashboardTab.value = index;
  }

  void _buildDashboardRecords() {
    scheduleRecords.assignAll(
      todayScheduleItems
          .map(
            (e) => {
              'id': '${e['time']}-${e['subject']}-${e['classLabel']}',
              'time': e['time'] ?? '',
              'subject': e['subject'] ?? '',
              'classLabel': e['classLabel'] ?? '',
              'status': 'SCHEDULED',
            },
          )
          .toList(),
    );
    classRecords.assignAll(
      assignedClasses
          .map(
            (e) => {
              'id': e,
              'name': e,
              'status': 'ASSIGNED',
            },
          )
          .toList(),
    );
    taskRecords.assignAll(
      pendingTasks
          .map(
            (e) => {
              'id': e,
              'title': e,
              'status': 'PENDING',
            },
          )
          .toList(),
    );
    alertRecords.assignAll(
      studentAlerts
          .map(
            (e) => {
              'id': e,
              'title': e,
              'status': 'OPEN',
            },
          )
          .toList(),
    );
    notificationRecords.assignAll(
      notifications
          .map(
            (e) => {
              'id': e,
              'title': e,
              'status': 'UNREAD',
            },
          )
          .toList(),
    );
    homeworkRecords.assignAll(
      homeworkStatus
          .map(
            (e) => {
              'id': e,
              'title': e,
              'status': 'ACTIVE',
            },
          )
          .toList(),
    );
    examRecords.assignAll(
      upcomingExams
          .map(
            (e) => {
              'id': e,
              'title': e,
              'status': 'UPCOMING',
            },
          )
          .toList(),
    );
    meetingRecords.assignAll(
      meetings
          .map(
            (e) => {
              'id': e,
              'title': e,
              'status': 'SCHEDULED',
            },
          )
          .toList(),
    );
  }

  Future<void> addTaskRecord() async {
    final title = TextEditingController();
    String status = 'PENDING';
    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Pending Task'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: 'Task title'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const ['PENDING', 'IN_PROGRESS', 'DONE']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) => setState(() => status = value ?? 'PENDING'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Get.back(result: true), child: const Text('Save')),
          ],
        ),
      ),
    );
    if (ok != true || title.text.trim().isEmpty) return;
    taskRecords.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title.text.trim(),
      'status': status,
    });
  }

  void updateRecordStatus(RxList<Map<String, String>> source, String id, String nextStatus) {
    source.assignAll(
      source
          .map(
            (e) => e['id'] == id
                ? {
                    ...e,
                    'status': nextStatus,
                  }
                : e,
          )
          .toList(),
    );
  }

  void deleteRecord(RxList<Map<String, String>> source, String id) {
    source.removeWhere((e) => e['id'] == id);
  }

  List<String> _asStringList(dynamic value) {
    if (value is! List) return <String>[];
    return value.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
  }

  void _parseScheduleItems(dynamic value) {
    todayScheduleItems.clear();
    if (value is! List) return;
    for (final e in value) {
      if (e is Map) {
        todayScheduleItems.add({
          'time': (e['time'] ?? '').toString(),
          'subject': (e['subject'] ?? '').toString(),
          'classLabel': (e['classLabel'] ?? '').toString(),
        });
      }
    }
  }

  void openAiAssistant() => StaffAiAssistantSheet.open();

  final quickActions = const <String>[
    'Dashboard',
    'Profile',
    'Communication',
    'Reports',
  ];

  void goToModules() => SafeNavigation.offNamed(AppRoutes.STAFF_HOME);

  void openModule(String moduleId) {
    StaffPortalNavigation.openModule(moduleId);
  }
}

