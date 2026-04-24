import 'package:erp_frontend/app/modules/staff/models/staff_communication_models.dart';
import 'package:erp_frontend/app/modules/staff/widgets/staff_ai_assistant_sheet.dart';
import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/services/staff/staff_service.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';

class StaffCommunicationController extends GetxController {
  StaffCommunicationController(this._staffService, this._adminService);

  final StaffService _staffService;
  final AdminService _adminService;

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final isParentsLoading = false.obs;
  final isStudentsLoading = false.obs;
  final isAnnouncementsLoading = false.obs;
  final isNotificationsLoading = false.obs;
  final isSendingMessage = false.obs;
  final isSchedulingMeeting = false.obs;
  final isGeneratingAi = false.obs;

  final parentRecipientsError = ''.obs;
  final studentRecipientsError = ''.obs;
  final announcementError = ''.obs;
  final notificationError = ''.obs;

  final chats = <Map<String, String>>[].obs;
  final announcements = <String>[].obs;
  final meetings = <Map<String, String>>[].obs;

  final parentRecipients = <StaffRecipient>[].obs;
  final studentRecipients = <StaffRecipient>[].obs;
  final conversationThreads = <StaffConversationThread>[].obs;
  final announcementItems = <StaffAnnouncementRecord>[].obs;
  final notificationItems = <StaffNotificationRecord>[].obs;
  final meetingSchedules = <StaffMeetingSchedule>[].obs;
  final conversationMessages = <String, List<StaffConversationMessage>>{}.obs;

  final _locallyReadNotificationIds = <String>{};

  @override
  void onInit() {
    super.onInit();
    loadCommunication();
  }

  Future<void> loadCommunication() async {
    isLoading.value = true;
    errorMessage.value = '';
    Object? summaryError;
    try {
      try {
        await _loadCommunicationSummary();
      } catch (e) {
        summaryError = e;
      }
      await loadAnnouncements(showErrors: false);
      await loadNotifications(showErrors: false);
      if (summaryError != null &&
          announcementItems.isEmpty &&
          notificationItems.isEmpty &&
          conversationThreads.isEmpty &&
          meetingSchedules.isEmpty) {
        errorMessage.value = dioOrApiErrorMessage(summaryError);
        AppToast.show(errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      AppToast.show(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadRecipients(
    StaffMessageAudience audience, {
    String search = '',
    bool showErrors = true,
  }) async {
    final trimmedSearch = search.trim();
    final targetLoading = audience == StaffMessageAudience.parent
        ? isParentsLoading
        : isStudentsLoading;
    final targetError = audience == StaffMessageAudience.parent
        ? parentRecipientsError
        : studentRecipientsError;

    targetLoading.value = true;
    targetError.value = '';
    try {
      if (audience == StaffMessageAudience.parent) {
        final data = await _adminService.getParents(
          page: 1,
          limit: 100,
          search: trimmedSearch.isEmpty ? null : trimmedSearch,
        );
        final rawItems = data['items'];
        final next = <StaffRecipient>[];
        if (rawItems is List) {
          for (final raw in rawItems.whereType<Map>()) {
            final item = raw.cast<String, dynamic>();
            final fullName = _firstNonEmptyString([item['fullName']]);
            if (fullName.isEmpty) continue;
            final email = _firstNonEmptyString([item['email']]);
            final phone = _firstNonEmptyString([item['phone']]);
            final students = item['students'] as List? ?? const [];
            final linkedStudentIds = <String>[];
            String primaryStudentId = '';
            for (final rawStudent in students.whereType<Map>()) {
              final relation = Map<String, dynamic>.from(
                rawStudent.cast<String, dynamic>(),
              );
              final student = relation['student'];
              if (student is! Map) continue;
              final studentMap = Map<String, dynamic>.from(
                student.cast<String, dynamic>(),
              );
              final currentStudentId = studentMap['id']?.toString() ?? '';
              if (currentStudentId.isEmpty) continue;
              linkedStudentIds.add(currentStudentId);
              if (primaryStudentId.isEmpty && relation['isPrimary'] == true) {
                primaryStudentId = currentStudentId;
              }
            }
            if (primaryStudentId.isEmpty && linkedStudentIds.isNotEmpty) {
              primaryStudentId = linkedStudentIds.first;
            }
            final contact = phone.isNotEmpty ? phone : email;
            final linkedCount = students.length;
            final subtitle = linkedCount > 0
                ? '$linkedCount linked student${linkedCount == 1 ? '' : 's'}'
                : (contact.isEmpty ? 'Parent contact' : contact);
            next.add(
              StaffRecipient(
                id: item['id']?.toString() ?? fullName,
                audience: StaffMessageAudience.parent,
                name: fullName,
                subtitle: subtitle,
                contact: contact,
                deliveryTarget: contact.isEmpty
                    ? fullName
                    : '$fullName | $contact',
                badge: linkedCount > 0 ? '$linkedCount' : '',
                primaryStudentId: primaryStudentId,
                relatedStudentIds: linkedStudentIds,
              ),
            );
          }
        }
        parentRecipients.assignAll(next);
      } else {
        final data = await _adminService.getStudents(
          page: 1,
          limit: 150,
          search: trimmedSearch.isEmpty ? null : trimmedSearch,
          status: 'ACTIVE',
        );
        final rawItems = data['items'];
        final next = <StaffRecipient>[];
        if (rawItems is List) {
          for (final raw in rawItems.whereType<Map>()) {
            final item = raw.cast<String, dynamic>();
            final firstName = _firstNonEmptyString([item['firstName']]);
            final lastName = _firstNonEmptyString([item['lastName']]);
            final fullName = '$firstName $lastName'.trim();
            if (fullName.isEmpty) continue;
            final className = _firstNonEmptyString([item['className']]);
            final section = _firstNonEmptyString([item['section']]);
            final admissionNo = _firstNonEmptyString([item['admissionNo']]);
            final classLabel = section.isEmpty
                ? className
                : '$className - $section';
            final subtitleParts = <String>[
              if (admissionNo.isNotEmpty) admissionNo,
              if (classLabel.isNotEmpty) classLabel,
            ];
            next.add(
              StaffRecipient(
                id: item['id']?.toString() ?? admissionNo,
                audience: StaffMessageAudience.student,
                name: fullName,
                subtitle: subtitleParts.isEmpty
                    ? 'Student record'
                    : subtitleParts.join(' | '),
                contact: _firstNonEmptyString([item['guardianPhone']]),
                deliveryTarget: admissionNo.isEmpty
                    ? fullName
                    : '$fullName | $admissionNo',
                badge: classLabel,
                primaryStudentId: item['id']?.toString() ?? '',
                relatedStudentIds: [
                  if ((item['id']?.toString() ?? '').isNotEmpty)
                    item['id'].toString(),
                ],
              ),
            );
          }
        }
        studentRecipients.assignAll(next);
      }
      _linkThreadsToRecipients();
    } catch (e) {
      targetError.value = dioOrApiErrorMessage(e);
      if (showErrors) {
        AppToast.show(targetError.value);
      }
    } finally {
      targetLoading.value = false;
    }
  }

  Future<void> loadAnnouncements({bool showErrors = true}) async {
    isAnnouncementsLoading.value = true;
    announcementError.value = '';
    try {
      final data = await _adminService.getAnnouncements(page: 1, limit: 100);
      final rawItems = data['items'];
      final next = <StaffAnnouncementRecord>[];
      if (rawItems is List) {
        for (final raw in rawItems.whereType<Map>()) {
          final item = raw.cast<String, dynamic>();
          final title = _firstNonEmptyString([item['title']]);
          if (title.isEmpty) continue;
          final content = _firstNonEmptyString([item['content']]);
          final audience = _firstNonEmptyString([item['audience'], 'ALL']);
          final status = _firstNonEmptyString([item['status'], 'DRAFT']);
          final updatedAt = _parseDate(
            item['sentAt'] ?? item['updatedAt'] ?? item['createdAt'],
          );
          final lowered = '$title $content'.toLowerCase();
          next.add(
            StaffAnnouncementRecord(
              id: item['id']?.toString() ?? title,
              title: title,
              content: content,
              audience: audience,
              status: status,
              updatedAt: updatedAt,
              isUrgent: lowered.contains('urgent'),
            ),
          );
        }
      }
      announcementItems.assignAll(next);
      announcements.assignAll(next.map((item) => item.title));
    } catch (e) {
      announcementError.value = dioOrApiErrorMessage(e);
      if (announcementItems.isEmpty && announcements.isNotEmpty) {
        announcementItems.assignAll(
          announcements
              .map(
                (title) => StaffAnnouncementRecord(
                  id: title,
                  title: title,
                  content: '',
                  audience: 'ALL',
                  status: 'SENT',
                  updatedAt: DateTime.now(),
                ),
              )
              .toList(),
        );
      }
      if (showErrors) {
        AppToast.show(announcementError.value);
      }
    } finally {
      isAnnouncementsLoading.value = false;
    }
  }

  Future<void> loadNotifications({bool showErrors = true}) async {
    isNotificationsLoading.value = true;
    notificationError.value = '';
    try {
      final data = await _adminService.getNotifications(page: 1, limit: 100);
      final rawItems = data['items'];
      final next = <StaffNotificationRecord>[];
      if (rawItems is List) {
        for (final raw in rawItems.whereType<Map>()) {
          final item = raw.cast<String, dynamic>();
          final id = item['id']?.toString() ?? 'notification-${next.length}';
          final title = _firstNonEmptyString([
            item['title'],
            item['subject'],
            item['headline'],
            item['type'],
          ]);
          final body = _firstNonEmptyString([
            item['body'],
            item['message'],
            item['description'],
            item['content'],
          ]);
          final category = _firstNonEmptyString([
            item['category'],
            item['channel'],
            item['type'],
          ]);
          next.add(
            StaffNotificationRecord(
              id: id,
              title: title.isEmpty ? 'Notification' : title,
              body: body,
              category: category.isEmpty ? 'General' : category,
              status: _firstNonEmptyString([item['status'], 'SENT']),
              createdAt: _parseDate(
                item['createdAt'] ?? item['updatedAt'] ?? item['sentAt'],
              ),
              isRead:
                  item['isRead'] == true ||
                  item['read'] == true ||
                  _locallyReadNotificationIds.contains(id),
              audience: _firstNonEmptyString([item['audience']]),
            ),
          );
        }
      }
      notificationItems.assignAll(next);
    } catch (e) {
      notificationError.value = dioOrApiErrorMessage(e);
      await _loadNotificationsFallback(showErrors: showErrors);
      if (showErrors && notificationItems.isEmpty) {
        AppToast.show(notificationError.value);
      }
    } finally {
      isNotificationsLoading.value = false;
    }
  }

  Future<void> _loadCommunicationSummary() async {
    final localMeetings = meetingSchedules
        .where((item) => item.id.startsWith('local-meeting-'))
        .toList();
    final data = await _staffService.getCommunication();

    final rawChats = data['chats'];
    final nextThreads = <StaffConversationThread>[];
    if (rawChats is List) {
      chats.assignAll(
        rawChats.whereType<Map>().map((e) {
          final item = e.cast<String, dynamic>();
          final to = _firstNonEmptyString([item['to']]);
          final last = _firstNonEmptyString([item['last']]);
          final updatedAt = _parseDate(
            item['updatedAt'] ?? item['time'] ?? item['createdAt'],
          );
          nextThreads.add(
            StaffConversationThread(
              id: item['id']?.toString() ?? 'chat-${nextThreads.length}',
              audience: item['audience'] == null
                  ? null
                  : StaffMessageAudienceX.fromValue(
                      item['audience'].toString(),
                    ),
              recipientId: item['recipientId']?.toString(),
              recipientName: to.isEmpty ? 'Conversation' : to,
              lastMessage: last,
              updatedAt: updatedAt,
              subtitle: _firstNonEmptyString([item['channel']]),
            ),
          );
          return {'to': to, 'last': last};
        }).toList(),
      );
    } else {
      chats.clear();
    }

    final rawMessages = data['messages'];
    final nextConversationMessages = <String, List<StaffConversationMessage>>{};
    if (rawMessages is List) {
      for (final raw in rawMessages.whereType<Map>()) {
        final item = raw.cast<String, dynamic>();
        final threadKey = _firstNonEmptyString([
          item['threadKey'],
          if (item['audience'] != null && item['recipientId'] != null)
            '${item['audience']}:${item['recipientId']}',
        ]);
        if (threadKey.isEmpty) continue;
        final list = nextConversationMessages.putIfAbsent(
          threadKey,
          () => <StaffConversationMessage>[],
        );
        list.add(
          StaffConversationMessage(
            id: item['id']?.toString() ?? 'message-${list.length}',
            body: _firstNonEmptyString([item['message'], item['body']]),
            timestamp: _parseDate(item['createdAt'] ?? item['time']),
            isOutgoing: item['isOutgoing'] == true,
            status: _firstNonEmptyString([item['status'], 'SENT']),
          ),
        );
      }
    }
    for (final entry in conversationMessages.entries) {
      nextConversationMessages.putIfAbsent(
        entry.key,
        () => List<StaffConversationMessage>.from(entry.value),
      );
    }
    for (final entry in nextConversationMessages.entries) {
      entry.value.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    }
    conversationMessages.assignAll(nextConversationMessages);

    final rawAnnouncements = data['announcements'];
    if (rawAnnouncements is List) {
      announcements.assignAll(
        rawAnnouncements
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty),
      );
    } else {
      announcements.clear();
    }

    final rawMeetings = data['meetings'];
    final nextMeetings = <StaffMeetingSchedule>[];
    if (rawMeetings is List) {
      meetings.assignAll(
        rawMeetings.whereType<Map>().map((e) {
          final item = e.cast<String, dynamic>();
          final parsed = _parseMeetingRecord(item, nextMeetings.length);
          nextMeetings.add(parsed);
          return {'title': parsed.title, 'time': _formatMeetingSummary(parsed)};
        }).toList(),
      );
    } else {
      meetings.clear();
    }

    for (final item in localMeetings) {
      if (nextMeetings.every((meeting) => meeting.id != item.id)) {
        nextMeetings.add(item);
      }
    }
    nextMeetings.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    meetingSchedules.assignAll(nextMeetings);

    conversationThreads.assignAll(nextThreads);
    _linkThreadsToRecipients();
    _mergeLocalThreadsFromMessages();
  }

  Future<void> _loadNotificationsFallback({bool showErrors = true}) async {
    try {
      final data = await _staffService.getDashboard();
      final next = <StaffNotificationRecord>[];

      void addItems(
        dynamic value, {
        required String category,
        required String defaultTitle,
      }) {
        if (value is! List) return;
        for (final item in value) {
          final text = item.toString().trim();
          if (text.isEmpty) continue;
          final id = '$category-${next.length}';
          next.add(
            StaffNotificationRecord(
              id: id,
              title: defaultTitle,
              body: text,
              category: category,
              status: 'LIVE',
              createdAt: DateTime.now(),
              isRead: _locallyReadNotificationIds.contains(id),
            ),
          );
        }
      }

      addItems(
        data['pendingTasks'],
        category: 'Tasks',
        defaultTitle: 'Pending task',
      );
      addItems(
        data['notifications'],
        category: 'Announcements',
        defaultTitle: 'Staff update',
      );
      addItems(
        data['upcomingExams'],
        category: 'Exams',
        defaultTitle: 'Exam update',
      );
      addItems(
        data['meetings'],
        category: 'Meetings',
        defaultTitle: 'Meeting update',
      );
      notificationItems.assignAll(next);
    } catch (fallbackError) {
      if (showErrors) {
        AppToast.show(dioOrApiErrorMessage(fallbackError));
      }
    }
  }

  StaffRecipient buildManualRecipient({
    required StaffMessageAudience audience,
    required String name,
    String subtitle = 'Manual contact',
    String contact = '',
  }) {
    final trimmedName = name.trim().isEmpty
        ? audience.singularLabel
        : name.trim();
    final trimmedContact = contact.trim();
    return StaffRecipient(
      id: 'manual-${audience.value}-${DateTime.now().millisecondsSinceEpoch}',
      audience: audience,
      name: trimmedName,
      subtitle: subtitle,
      contact: trimmedContact,
      deliveryTarget: trimmedContact.isEmpty
          ? trimmedName
          : '$trimmedName | $trimmedContact',
    );
  }

  StaffRecipient? findRecipient(StaffMessageAudience audience, String id) {
    final source = audience == StaffMessageAudience.parent
        ? parentRecipients
        : studentRecipients;
    return source.firstWhereOrNull((item) => item.id == id);
  }

  StaffConversationThread? threadForRecipient(StaffRecipient recipient) {
    return conversationThreads.firstWhereOrNull(
      (thread) => thread.threadKey == recipient.threadKey,
    );
  }

  List<StaffConversationThread> threadsForAudience(
    StaffMessageAudience audience,
  ) {
    return conversationThreads
        .where((thread) => thread.audience == audience)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  List<StaffConversationMessage> messagesForRecipient(
    StaffRecipient recipient,
  ) {
    return List<StaffConversationMessage>.from(
      conversationMessages[recipient.threadKey] ??
          const <StaffConversationMessage>[],
    )..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  void ensureConversationSeedForRecipient(StaffRecipient recipient) {
    _ensureMessageSeed(recipient);
  }

  List<StaffAnnouncementRecord> announcementResults({
    String query = '',
    String filter = 'ALL',
  }) {
    final trimmedQuery = query.trim().toLowerCase();
    final trimmedFilter = filter.trim().toUpperCase();
    return announcementItems.where((item) {
      if (trimmedFilter != 'ALL' &&
          item.status.toUpperCase() != trimmedFilter) {
        if (trimmedFilter == 'IMPORTANT' && item.isUrgent) {
        } else {
          return false;
        }
      }
      if (trimmedQuery.isEmpty) return true;
      final haystack = '${item.title} ${item.content} ${item.audience}'
          .toLowerCase();
      return haystack.contains(trimmedQuery);
    }).toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  List<StaffNotificationRecord> notificationResults({
    String query = '',
    String filter = 'ALL',
  }) {
    final trimmedQuery = query.trim().toLowerCase();
    final trimmedFilter = filter.trim().toUpperCase();
    return notificationItems.where((item) {
      if (trimmedFilter != 'ALL' &&
          item.category.toUpperCase() != trimmedFilter &&
          item.status.toUpperCase() != trimmedFilter) {
        if (trimmedFilter == 'UNREAD' && !item.isRead) {
        } else {
          return false;
        }
      }
      if (trimmedQuery.isEmpty) return true;
      final haystack =
          '${item.title} ${item.body} ${item.category} ${item.audience}'
              .toLowerCase();
      return haystack.contains(trimmedQuery);
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<StaffMeetingSchedule> meetingResults({
    String query = '',
    String filter = 'ALL',
  }) {
    final trimmedQuery = query.trim().toLowerCase();
    final trimmedFilter = filter.trim().toUpperCase();
    return meetingSchedules.where((item) {
      if (trimmedFilter == 'UPCOMING' &&
          item.dateTime.isBefore(DateTime.now())) {
        return false;
      }
      if (trimmedFilter == 'COMPLETED' &&
          item.status.toUpperCase() != 'COMPLETED') {
        return false;
      }
      if (trimmedFilter == 'ALL') {
      } else if (trimmedFilter != 'UPCOMING' && trimmedFilter != 'COMPLETED') {
        final matches =
            item.status.toUpperCase() == trimmedFilter ||
            item.mode.toUpperCase() == trimmedFilter;
        if (!matches) return false;
      }
      if (trimmedQuery.isEmpty) return true;
      final haystack =
          '${item.parentName} ${item.studentName} ${item.purpose} ${item.note} ${item.mode}'
              .toLowerCase();
      return haystack.contains(trimmedQuery);
    }).toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  Future<bool> sendMessageToRecipient({
    required StaffRecipient recipient,
    required String message,
    bool showToast = true,
  }) async {
    if (message.trim().isEmpty) return false;
    isSendingMessage.value = true;
    try {
      final isManualRecipient = recipient.id.startsWith('manual-');
      final studentId = recipient.audience == StaffMessageAudience.student
          ? recipient.id
          : recipient.primaryStudentId;
      await _staffService.sendMessage(
        to: recipient.deliveryTarget,
        message: message.trim(),
        audience: recipient.audience.value,
        recipientId: isManualRecipient ? null : recipient.id,
        recipientName: recipient.name,
        parentId:
            !isManualRecipient &&
                recipient.audience == StaffMessageAudience.parent
            ? recipient.id
            : null,
        studentId: isManualRecipient || studentId.isEmpty ? null : studentId,
        subject: 'Staff message',
      );
      _appendOutgoingMessage(recipient, message.trim());
      if (showToast) {
        AppToast.show('${recipient.audience.singularLabel} message sent.');
      }
      return true;
    } catch (e) {
      if (showToast) {
        AppToast.show(dioOrApiErrorMessage(e));
      }
      return false;
    } finally {
      isSendingMessage.value = false;
    }
  }

  Future<bool> createAnnouncement({
    required String title,
    required String content,
    required String audience,
    required bool sendNow,
  }) async {
    if (title.trim().isEmpty || content.trim().isEmpty) return false;
    try {
      final created = await _adminService.createAnnouncement(
        title: title.trim(),
        content: content.trim(),
        audience: audience.trim().isEmpty ? 'ALL' : audience.trim(),
      );
      final announcement = created['announcement'];
      final id = announcement is Map
          ? announcement['id']?.toString() ?? ''
          : '';
      if (sendNow && id.isNotEmpty) {
        await _adminService.sendAnnouncement(id);
      }
      await loadAnnouncements(showErrors: false);
      AppToast.show(
        sendNow ? 'Announcement published.' : 'Announcement saved.',
      );
      return true;
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
      return false;
    }
  }

  Future<bool> publishAnnouncement(StaffAnnouncementRecord record) async {
    if (record.id.trim().isEmpty) return false;
    try {
      await _adminService.sendAnnouncement(record.id);
      await loadAnnouncements(showErrors: false);
      AppToast.show('Announcement published.');
      return true;
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
      return false;
    }
  }

  void markNotificationRead(String id) {
    _locallyReadNotificationIds.add(id);
    notificationItems.assignAll(
      notificationItems
          .map((item) => item.id == id ? item.copyWith(isRead: true) : item)
          .toList(),
    );
  }

  void markAllNotificationsRead() {
    for (final item in notificationItems) {
      _locallyReadNotificationIds.add(item.id);
    }
    notificationItems.assignAll(
      notificationItems.map((item) => item.copyWith(isRead: true)).toList(),
    );
  }

  Future<bool> scheduleMeeting({
    required StaffRecipient parent,
    StaffRecipient? student,
    required DateTime dateTime,
    required String purpose,
    required String mode,
    String location = '',
    String note = '',
  }) async {
    final trimmedPurpose = purpose.trim();
    if (trimmedPurpose.isEmpty) return false;
    isSchedulingMeeting.value = true;
    try {
      final data = await _staffService.scheduleMeeting(
        parentName: parent.name,
        parentId: parent.id.startsWith('manual-') ? null : parent.id,
        studentId: student?.id,
        studentName: student?.name,
        scheduledAt: dateTime,
        purpose: trimmedPurpose,
        mode: mode,
        location: location,
        note: note,
      );
      final meetingMap = data['meeting'];
      final invitation =
          _firstNonEmptyString([data['invitationMessage']]).isEmpty
          ? _buildMeetingInvitation(
              parent: parent,
              student: student,
              dateTime: dateTime,
              purpose: trimmedPurpose,
              mode: mode,
              location: location,
              note: note,
            )
          : _firstNonEmptyString([data['invitationMessage']]);
      if (meetingMap is Map) {
        final parsedMeeting = _parseMeetingRecord(
          meetingMap.cast<String, dynamic>(),
          meetingSchedules.length,
        );
        meetingSchedules.assignAll(
          [
            parsedMeeting,
            ...meetingSchedules.where((item) => item.id != parsedMeeting.id),
          ]..sort((a, b) => a.dateTime.compareTo(b.dateTime)),
        );
        meetings.assignAll([
          {
            'title': parsedMeeting.title,
            'time': _formatMeetingSummary(parsedMeeting),
          },
          ...meetings.where((item) => item['title'] != parsedMeeting.title),
        ]);
      }

      _appendOutgoingMessage(parent, invitation);
      if (student != null) {
        _appendOutgoingMessage(student, invitation);
      }
      AppToast.show('Meeting scheduled and invitation sent.');
      return true;
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
      return false;
    } finally {
      isSchedulingMeeting.value = false;
    }
  }

  Future<String?> generateAiDraft({
    required String prompt,
    String contextType = 'communication',
  }) async {
    final trimmedPrompt = prompt.trim();
    if (trimmedPrompt.isEmpty) return null;
    isGeneratingAi.value = true;
    try {
      final data = await _staffService.aiAssist(
        prompt: trimmedPrompt,
        contextType: contextType,
      );
      final reply = _firstNonEmptyString([data['reply']]);
      return reply.isEmpty ? null : reply;
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
      return null;
    } finally {
      isGeneratingAi.value = false;
    }
  }

  void openCommunicationAssistant() {
    StaffAiAssistantSheet.open(initialContext: 'communication');
  }

  int get unreadNotificationsCount =>
      notificationItems.where((item) => !item.isRead).length;

  int get scheduledMeetingCount => meetingSchedules.length;

  int get liveAnnouncementCount => announcementItems.length;

  void _ensureMessageSeed(StaffRecipient recipient) {
    if (conversationMessages.containsKey(recipient.threadKey)) return;
    final thread = threadForRecipient(recipient);
    if (thread == null || thread.lastMessage.trim().isEmpty) {
      conversationMessages[recipient.threadKey] = <StaffConversationMessage>[];
      conversationMessages.refresh();
      return;
    }
    conversationMessages[recipient.threadKey] = [
      StaffConversationMessage(
        id: 'seed-${recipient.threadKey}',
        body: thread.lastMessage,
        timestamp: thread.updatedAt,
        isOutgoing: false,
      ),
    ];
    conversationMessages.refresh();
  }

  void _appendOutgoingMessage(StaffRecipient recipient, String message) {
    final nextMessages = [
      ...messagesForRecipient(recipient),
      StaffConversationMessage(
        id: 'message-${DateTime.now().millisecondsSinceEpoch}',
        body: message,
        timestamp: DateTime.now(),
        isOutgoing: true,
      ),
    ];
    conversationMessages[recipient.threadKey] = nextMessages;
    conversationMessages.refresh();

    final nextThread = StaffConversationThread(
      id: recipient.threadKey,
      audience: recipient.audience,
      recipientId: recipient.id,
      recipientName: recipient.name,
      subtitle: recipient.subtitle,
      lastMessage: message,
      updatedAt: DateTime.now(),
    );
    final existingIndex = conversationThreads.indexWhere(
      (thread) => thread.threadKey == recipient.threadKey,
    );
    if (existingIndex >= 0) {
      conversationThreads[existingIndex] = nextThread;
    } else {
      conversationThreads.insert(0, nextThread);
    }
    conversationThreads.assignAll(
      conversationThreads.toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)),
    );

    chats.assignAll([
      {'to': recipient.name, 'last': message},
      ...chats.where((item) => item['to'] != recipient.name),
    ]);
  }

  void _linkThreadsToRecipients() {
    if (conversationThreads.isEmpty) return;
    final allRecipients = <StaffRecipient>[
      ...parentRecipients,
      ...studentRecipients,
    ];
    if (allRecipients.isEmpty) {
      _mergeLocalThreadsFromMessages();
      return;
    }

    conversationThreads.assignAll(
      conversationThreads.map((thread) {
        if (thread.audience != null &&
            thread.recipientId != null &&
            thread.recipientId!.isNotEmpty) {
          return thread;
        }
        for (final recipient in allRecipients) {
          if (_threadMatchesRecipient(thread, recipient)) {
            return thread.copyWith(
              id: recipient.threadKey,
              audience: recipient.audience,
              recipientId: recipient.id,
              recipientName: recipient.name,
              subtitle: recipient.subtitle,
            );
          }
        }
        return thread;
      }).toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)),
    );
    _mergeLocalThreadsFromMessages();
  }

  void _mergeLocalThreadsFromMessages() {
    if (conversationMessages.isEmpty) return;

    final nextThreads = conversationThreads.toList();
    final allRecipients = <StaffRecipient>[
      ...parentRecipients,
      ...studentRecipients,
    ];

    for (final entry in conversationMessages.entries) {
      final threadKey = entry.key;
      final messages = entry.value;
      if (messages.isEmpty) continue;
      final lastMessage = messages.last;
      final existingIndex = nextThreads.indexWhere(
        (thread) => thread.threadKey == threadKey,
      );
      final recipient = allRecipients.firstWhereOrNull(
        (item) => item.threadKey == threadKey,
      );
      final existingThread = nextThreads.firstWhereOrNull(
        (thread) => thread.threadKey == threadKey,
      );
      final updatedThread = StaffConversationThread(
        id: threadKey,
        audience: recipient?.audience ?? existingThread?.audience,
        recipientId: recipient?.id ?? existingThread?.recipientId,
        recipientName:
            recipient?.name ?? existingThread?.recipientName ?? 'Conversation',
        subtitle: recipient?.subtitle ?? existingThread?.subtitle ?? '',
        lastMessage: lastMessage.body,
        updatedAt: lastMessage.timestamp,
      );
      if (existingIndex >= 0) {
        nextThreads[existingIndex] = updatedThread;
      } else {
        nextThreads.add(updatedThread);
      }
    }

    nextThreads.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    conversationThreads.assignAll(nextThreads);
  }

  bool _threadMatchesRecipient(
    StaffConversationThread thread,
    StaffRecipient recipient,
  ) {
    final threadValue = thread.recipientName.toLowerCase();
    final recipientValue = recipient.name.toLowerCase();
    if (threadValue == recipientValue) return true;
    if (threadValue.contains(recipientValue) ||
        recipientValue.contains(threadValue)) {
      return true;
    }
    final contact = recipient.contact.toLowerCase();
    return contact.isNotEmpty && threadValue.contains(contact);
  }

  String _buildMeetingInvitation({
    required StaffRecipient parent,
    StaffRecipient? student,
    required DateTime dateTime,
    required String purpose,
    required String mode,
    required String location,
    required String note,
  }) {
    final buffer = StringBuffer()
      ..writeln('Parent-teacher meeting invitation')
      ..writeln('Parent: ${parent.name}');
    if (student != null && student.name.trim().isNotEmpty) {
      buffer.writeln('Student: ${student.name}');
    }
    buffer
      ..writeln('Purpose: $purpose')
      ..writeln('Date: ${_formatDate(dateTime)}')
      ..writeln('Time: ${_formatTime(dateTime)}')
      ..writeln('Mode: $mode');
    if (location.trim().isNotEmpty) {
      buffer.writeln('Location: ${location.trim()}');
    }
    if (note.trim().isNotEmpty) {
      buffer.writeln('Notes: ${note.trim()}');
    }
    return buffer.toString().trim();
  }

  String _formatMeetingSummary(StaffMeetingSchedule meeting) {
    return '${_formatDate(meeting.dateTime)} | ${_formatTime(meeting.dateTime)}';
  }

  StaffMeetingSchedule _parseMeetingRecord(
    Map<String, dynamic> item,
    int index,
  ) {
    final title = _firstNonEmptyString([item['title'], 'Meeting']);
    final directParentName = _firstNonEmptyString([
      item['parentName'],
      item['parent'],
    ]);
    final directStudentName = _firstNonEmptyString([
      item['studentName'],
      item['student'],
    ]);
    final directPurpose = _firstNonEmptyString([item['purpose']]);
    final directMode = _firstNonEmptyString([item['mode']]);
    final directLocation = _firstNonEmptyString([item['location']]);
    final directNote = _firstNonEmptyString([item['note']]);
    final noteText = _firstNonEmptyString([
      item['note'],
      item['body'],
      item['message'],
      item['time'],
    ]);
    final lines = noteText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
    final values = <String, String>{};
    for (final line in lines) {
      final divider = line.indexOf(':');
      if (divider <= 0) continue;
      final key = line.substring(0, divider).trim().toLowerCase();
      final value = line.substring(divider + 1).trim();
      if (key.isNotEmpty && value.isNotEmpty) {
        values[key] = value;
      }
    }
    final purpose = values['purpose'];
    final parentName = values['parent'];
    final studentName = values['student'];
    final dateText = values['date'];
    final timeOnly = values['time'] ?? item['timeSlot']?.toString();
    final note = values['note'] ?? noteText;
    final mode = values['mode'];
    final location = values['location'];

    DateTime scheduledAt = _parseDate(
      item['scheduledAt'] ?? item['date'] ?? item['time'],
    );
    if (dateText != null && dateText.isNotEmpty) {
      final rebuilt = _parseMeetingDateTime(dateText, timeOnly);
      if (rebuilt != null) {
        scheduledAt = rebuilt;
      }
    }

    final fallbackSummary = _firstNonEmptyString([item['time'], noteText]);
    return StaffMeetingSchedule(
      id: item['id']?.toString() ?? 'meeting-$index',
      parentName: directParentName.isEmpty
          ? (parentName ?? title)
          : directParentName,
      studentName: directStudentName.isNotEmpty
          ? directStudentName
          : (studentName == 'N/A' ? '' : (studentName ?? '')),
      purpose: directPurpose.isEmpty ? (purpose ?? title) : directPurpose,
      dateTime: scheduledAt,
      mode: directMode.isEmpty ? (mode ?? 'Saved note') : directMode,
      status: _firstNonEmptyString([item['status'], 'Saved']),
      note: directNote.isNotEmpty
          ? directNote
          : (note.isEmpty ? fallbackSummary : note),
      location: directLocation.isEmpty ? (location ?? '') : directLocation,
    );
  }

  String _firstNonEmptyString(List<dynamic> values) {
    for (final value in values) {
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    final text = value.toString().trim();
    if (text.isEmpty) return DateTime.now();
    return DateTime.tryParse(text)?.toLocal() ?? DateTime.now();
  }

  DateTime? _parseMeetingDateTime(String dateText, String? timeText) {
    final parsedDate = _parseFormattedDate(dateText);
    if (parsedDate == null) return null;
    final parsedTime = _parseFormattedTime(timeText);
    if (parsedTime == null) {
      return parsedDate;
    }
    return DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
      parsedTime.hour,
      parsedTime.minute,
    );
  }

  DateTime? _parseFormattedDate(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return null;
    final months = <String, int>{
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };
    final parts = raw.split(RegExp(r'\s+'));
    if (parts.length < 3) {
      return DateTime.tryParse(raw)?.toLocal();
    }
    final day = int.tryParse(parts[0]);
    final monthToken = parts[1].length >= 3
        ? parts[1].substring(0, 3)
        : parts[1];
    final month = months[monthToken.toLowerCase()];
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) {
      return DateTime.tryParse(raw)?.toLocal();
    }
    return DateTime(year, month, day);
  }

  DateTime? _parseFormattedTime(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final raw = value.trim().toUpperCase();
    final match = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$').firstMatch(raw);
    if (match == null) {
      return DateTime.tryParse(value)?.toLocal();
    }
    final hourValue = int.tryParse(match.group(1) ?? '');
    final minute = int.tryParse(match.group(2) ?? '');
    final suffix = match.group(3);
    if (hourValue == null || minute == null || suffix == null) {
      return null;
    }
    final normalizedHour = suffix == 'PM'
        ? (hourValue % 12) + 12
        : (hourValue % 12);
    return DateTime(2000, 1, 1, normalizedHour, minute);
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    final months = const [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${local.day} ${months[local.month - 1]} ${local.year}';
  }

  String _formatTime(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour == 0
        ? 12
        : local.hour > 12
        ? local.hour - 12
        : local.hour;
    final suffix = local.hour >= 12 ? 'PM' : 'AM';
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute $suffix';
  }
}
