import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Notice {
  final String id;
  final String title;
  final String description;
  final String status; // PUBLISHED, SCHEDULED, DRAFT
  final String time;
  final List<String> audiences;
  final String? imageUrl;
  Notice({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.time,
    required this.audiences,
    this.imageUrl,
  });
}

class StaffChatThread {
  const StaffChatThread({
    required this.id,
    required this.staffName,
    required this.topic,
    required this.lastMessage,
    required this.updatedAt,
  });

  final String id;
  final String staffName;
  final String topic;
  final String lastMessage;
  final String updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'staffName': staffName,
    'topic': topic,
    'lastMessage': lastMessage,
    'updatedAt': updatedAt,
  };

  factory StaffChatThread.fromJson(Map<String, dynamic> json) {
    return StaffChatThread(
      id: json['id']?.toString() ?? '',
      staffName: json['staffName']?.toString() ?? '',
      topic: json['topic']?.toString() ?? '',
      lastMessage: json['lastMessage']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }
}

class ChannelCampaignRecord {
  const ChannelCampaignRecord({
    required this.id,
    required this.title,
    required this.message,
    required this.channel,
    required this.audience,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final String channel;
  final String audience;
  final String status;
  final String createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'channel': channel,
    'audience': audience,
    'status': status,
    'createdAt': createdAt,
  };

  factory ChannelCampaignRecord.fromJson(Map<String, dynamic> json) {
    return ChannelCampaignRecord(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      channel: json['channel']?.toString() ?? '',
      audience: json['audience']?.toString() ?? '',
      status: json['status']?.toString() ?? 'DRAFT',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

class ParentCommunicationRecord {
  const ParentCommunicationRecord({
    required this.id,
    required this.parentName,
    required this.subject,
    required this.message,
    required this.status,
    required this.updatedAt,
  });

  final String id;
  final String parentName;
  final String subject;
  final String message;
  final String status;
  final String updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'parentName': parentName,
    'subject': subject,
    'message': message,
    'status': status,
    'updatedAt': updatedAt,
  };

  factory ParentCommunicationRecord.fromJson(Map<String, dynamic> json) {
    return ParentCommunicationRecord(
      id: json['id']?.toString() ?? '',
      parentName: json['parentName']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      status: json['status']?.toString() ?? 'OPEN',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }
}

class AdminNoticeBoardController extends GetxController {
  AdminNoticeBoardController(this._adminService);

  final AdminService _adminService;
  final selectedTab = 0.obs; // circular announcement filter
  final communicationTab = 0.obs; // 0..5 for communication center modules
  final isLoading = false.obs;

  final notices = <Notice>[].obs;
  final staffChats = <StaffChatThread>[].obs;
  final smsCampaigns = <ChannelCampaignRecord>[].obs;
  final emailCampaigns = <ChannelCampaignRecord>[].obs;
  final appNotifications = <ChannelCampaignRecord>[].obs;
  final parentCommunications = <ParentCommunicationRecord>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;
    try {
      await Future.wait([loadAnnouncements(), loadCommunicationSettings()]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAnnouncements() async {
    try {
      final data = await _adminService.getAnnouncements(page: 1, limit: 50);
      final items = (data['items'] as List<dynamic>? ?? const <dynamic>[])
          .cast<Map<String, dynamic>>();
      final mapped = items
          .map(
            (item) => Notice(
              id: item['id']?.toString() ?? '',
              title: item['title']?.toString() ?? '',
              description: item['content']?.toString() ?? '',
              status: item['status']?.toString() ?? 'DRAFT',
              time:
                  item['updatedAt']?.toString() ??
                  item['createdAt']?.toString() ??
                  '',
              audiences: (item['audience']?.toString() ?? '')
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
            ),
          )
          .toList();
      notices.assignAll(mapped);
    } catch (e) {
      notices.clear();
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> loadCommunicationSettings() async {
    try {
      final settings = await _adminService.getSchoolSettings();
      final raw = settings['communicationCenter'];
      if (raw is! Map) {
        staffChats.clear();
        smsCampaigns.clear();
        emailCampaigns.clear();
        appNotifications.clear();
        parentCommunications.clear();
        return;
      }
      final map = Map<String, dynamic>.from(raw);
      staffChats.assignAll(
        (map['staffChats'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map>()
            .map((e) => StaffChatThread.fromJson(e.cast<String, dynamic>()))
            .toList(),
      );
      smsCampaigns.assignAll(
        (map['smsCampaigns'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map>()
            .map(
              (e) => ChannelCampaignRecord.fromJson(e.cast<String, dynamic>()),
            )
            .toList(),
      );
      emailCampaigns.assignAll(
        (map['emailCampaigns'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map>()
            .map(
              (e) => ChannelCampaignRecord.fromJson(e.cast<String, dynamic>()),
            )
            .toList(),
      );
      appNotifications.assignAll(
        (map['appNotifications'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map>()
            .map(
              (e) => ChannelCampaignRecord.fromJson(e.cast<String, dynamic>()),
            )
            .toList(),
      );
      parentCommunications.assignAll(
        (map['parentCommunications'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map>()
            .map(
              (e) =>
                  ParentCommunicationRecord.fromJson(e.cast<String, dynamic>()),
            )
            .toList(),
      );
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  void onTabChanged(int index) {
    selectedTab.value = index;
  }

  void onCommunicationTabChanged(int index) {
    communicationTab.value = index;
  }

  List<Notice> noticesForTab([int? tabIndex]) {
    final index = tabIndex ?? selectedTab.value;
    return notices.where((notice) {
      if (index == 0) return true;
      if (index == 1) {
        return notice.status == 'SENT' || notice.status == 'SCHEDULED';
      }
      return notice.status == 'DRAFT';
    }).toList();
  }

  List<Notice> searchNotices(String query, {int? tabIndex}) {
    final trimmed = query.trim().toLowerCase();
    final source = noticesForTab(tabIndex);
    if (trimmed.isEmpty) return source;
    return source.where((notice) {
      return notice.title.toLowerCase().contains(trimmed) ||
          notice.description.toLowerCase().contains(trimmed) ||
          notice.status.toLowerCase().contains(trimmed) ||
          notice.audiences.any(
            (audience) => audience.toLowerCase().contains(trimmed),
          );
    }).toList();
  }

  void onAddNotice() {
    _openAddNoticeDialog();
  }

  void onNoticeTap(Notice notice) {
    _openNoticeActionDialog(notice);
  }

  void goToSystemAuditLogs() {
    Get.toNamed(AppRoutes.ADMIN_AUDIT_LOGS);
  }

  Future<void> refreshAll() async {
    await loadInitialData();
  }

  Future<void> openStaffChatDialog({StaffChatThread? existing}) async {
    final staff = TextEditingController(text: existing?.staffName ?? '');
    final topic = TextEditingController(text: existing?.topic ?? '');
    final message = TextEditingController(text: existing?.lastMessage ?? '');
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: Text(
          existing == null ? 'Start Staff Chat' : 'Update Staff Chat',
        ),
        content: SizedBox(
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: staff,
                decoration: const InputDecoration(labelText: 'Staff name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: topic,
                decoration: const InputDecoration(labelText: 'Topic'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: message,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Message'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (ok != true || staff.text.trim().isEmpty || topic.text.trim().isEmpty) {
      if (ok == true) AppToast.show('Staff name and topic are required.');
      return;
    }
    final next = [
      ...staffChats.where((e) => e.id != existing?.id),
      StaffChatThread(
        id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        staffName: staff.text.trim(),
        topic: topic.text.trim(),
        lastMessage: message.text.trim(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
    ];
    staffChats.assignAll(next);
    await _saveCommunicationSettings();
    AppToast.show('Staff chat saved.');
  }

  Future<void> deleteStaffChat(StaffChatThread item) async {
    if (!await _confirm('Delete chat with ${item.staffName}?')) return;
    staffChats.removeWhere((e) => e.id == item.id);
    await _saveCommunicationSettings();
    AppToast.show('Staff chat deleted.');
  }

  Future<void> openChannelCampaignDialog({
    required String channel,
    ChannelCampaignRecord? existing,
  }) async {
    final title = TextEditingController(text: existing?.title ?? '');
    final message = TextEditingController(text: existing?.message ?? '');
    final audience = TextEditingController(text: existing?.audience ?? 'ALL');
    String status = existing?.status ?? 'DRAFT';
    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            existing == null
                ? 'Create $channel Campaign'
                : 'Update $channel Campaign',
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: title,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: message,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(labelText: 'Message'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: audience,
                    decoration: const InputDecoration(labelText: 'Audience'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const ['DRAFT', 'SCHEDULED', 'SENT']
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => status = value ?? 'DRAFT'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (ok != true ||
        title.text.trim().isEmpty ||
        message.text.trim().isEmpty) {
      if (ok == true) AppToast.show('Title and message are required.');
      return;
    }
    final record = ChannelCampaignRecord(
      id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.text.trim(),
      message: message.text.trim(),
      channel: channel,
      audience: audience.text.trim(),
      status: status,
      createdAt: existing?.createdAt ?? DateTime.now().toIso8601String(),
    );
    if (channel == 'SMS/WHATSAPP') {
      smsCampaigns.assignAll([
        ...smsCampaigns.where((e) => e.id != existing?.id),
        record,
      ]);
    } else if (channel == 'EMAIL') {
      emailCampaigns.assignAll([
        ...emailCampaigns.where((e) => e.id != existing?.id),
        record,
      ]);
    } else {
      appNotifications.assignAll([
        ...appNotifications.where((e) => e.id != existing?.id),
        record,
      ]);
    }
    await _saveCommunicationSettings();
    AppToast.show('$channel campaign saved.');
  }

  Future<void> sendChannelCampaign({
    required String channel,
    required ChannelCampaignRecord item,
  }) async {
    final updated = ChannelCampaignRecord(
      id: item.id,
      title: item.title,
      message: item.message,
      channel: item.channel,
      audience: item.audience,
      status: 'SENT',
      createdAt: item.createdAt,
    );
    if (channel == 'SMS/WHATSAPP') {
      smsCampaigns.assignAll(
        smsCampaigns.map((e) => e.id == item.id ? updated : e).toList(),
      );
    } else if (channel == 'EMAIL') {
      emailCampaigns.assignAll(
        emailCampaigns.map((e) => e.id == item.id ? updated : e).toList(),
      );
    } else {
      appNotifications.assignAll(
        appNotifications.map((e) => e.id == item.id ? updated : e).toList(),
      );
    }
    await _saveCommunicationSettings();
    AppToast.show('$channel campaign sent.');
  }

  Future<void> deleteChannelCampaign({
    required String channel,
    required ChannelCampaignRecord item,
  }) async {
    if (!await _confirm('Delete campaign "${item.title}"?')) return;
    if (channel == 'SMS/WHATSAPP') {
      smsCampaigns.removeWhere((e) => e.id == item.id);
    } else if (channel == 'EMAIL') {
      emailCampaigns.removeWhere((e) => e.id == item.id);
    } else {
      appNotifications.removeWhere((e) => e.id == item.id);
    }
    await _saveCommunicationSettings();
    AppToast.show('Campaign deleted.');
  }

  Future<void> openParentCommunicationDialog({
    ParentCommunicationRecord? existing,
  }) async {
    final parent = TextEditingController(text: existing?.parentName ?? '');
    final subject = TextEditingController(text: existing?.subject ?? '');
    final message = TextEditingController(text: existing?.message ?? '');
    String status = existing?.status ?? 'OPEN';
    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            existing == null
                ? 'New Parent Communication'
                : 'Update Parent Communication',
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: parent,
                    decoration: const InputDecoration(labelText: 'Parent name'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: subject,
                    decoration: const InputDecoration(labelText: 'Subject'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: message,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(labelText: 'Message'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const ['OPEN', 'REPLIED', 'CLOSED']
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => status = value ?? 'OPEN'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (ok != true ||
        parent.text.trim().isEmpty ||
        subject.text.trim().isEmpty) {
      if (ok == true) AppToast.show('Parent name and subject are required.');
      return;
    }
    parentCommunications.assignAll([
      ...parentCommunications.where((e) => e.id != existing?.id),
      ParentCommunicationRecord(
        id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        parentName: parent.text.trim(),
        subject: subject.text.trim(),
        message: message.text.trim(),
        status: status,
        updatedAt: DateTime.now().toIso8601String(),
      ),
    ]);
    await _saveCommunicationSettings();
    AppToast.show('Parent communication saved.');
  }

  Future<void> _saveCommunicationSettings() async {
    await _adminService.patchSchoolSettings({
      'communicationCenter': {
        'staffChats': staffChats.map((e) => e.toJson()).toList(),
        'smsCampaigns': smsCampaigns.map((e) => e.toJson()).toList(),
        'emailCampaigns': emailCampaigns.map((e) => e.toJson()).toList(),
        'appNotifications': appNotifications.map((e) => e.toJson()).toList(),
        'parentCommunications': parentCommunications
            .map((e) => e.toJson())
            .toList(),
      },
    });
  }

  Future<bool> _confirm(String message) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _openAddNoticeDialog() async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final audienceController = TextEditingController(text: 'ALL');
    final sendNow = false.obs;

    final ok = await Get.dialog<bool>(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Obx(
              () => SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create Notice',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: contentController,
                      minLines: 5,
                      maxLines: 8,
                      decoration: const InputDecoration(labelText: 'Content'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: audienceController,
                      decoration: const InputDecoration(
                        labelText: 'Audience (e.g. ALL, PARENT, STUDENT)',
                      ),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      value: sendNow.value,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Send immediately'),
                      onChanged: (v) => sendNow.value = v == true,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Get.back(result: false),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () => Get.back(result: true),
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (ok != true) return;
    if (titleController.text.trim().isEmpty ||
        contentController.text.trim().isEmpty) {
      AppToast.show('Title and content are required.');
      return;
    }
    try {
      final created = await _adminService.createAnnouncement(
        title: titleController.text.trim(),
        content: contentController.text.trim(),
        audience: audienceController.text.trim(),
        status: sendNow.value ? 'SENT' : 'DRAFT',
      );
      if (sendNow.value) {
        final announcement = created['announcement'] as Map<String, dynamic>?;
        final id = announcement?['id']?.toString();
        if (id != null && id.isNotEmpty) {
          await _adminService.sendAnnouncement(id);
        }
      }
      await loadAnnouncements();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> _openNoticeActionDialog(Notice notice) async {
    if (notice.id.isEmpty) return;
    final action = await Get.dialog<String>(
      AlertDialog(
        title: Text(notice.title),
        content: const Text('Select action'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: 'close'),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: 'send'),
            child: const Text('Send Now'),
          ),
        ],
      ),
    );
    if (action == 'send') {
      try {
        await _adminService.sendAnnouncement(notice.id);
        await loadAnnouncements();
      } catch (e) {
        AppToast.show(dioOrApiErrorMessage(e));
      }
    }
  }
}
