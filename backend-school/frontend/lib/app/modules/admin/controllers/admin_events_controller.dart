import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminEventRecord {
  const AdminEventRecord({
    required this.id,
    required this.title,
    required this.eventType,
    required this.location,
    required this.isPublished,
    required this.registrationsCount,
    required this.startDate,
    required this.endDate,
  });

  final String id;
  final String title;
  final String eventType;
  final String location;
  final bool isPublished;
  final int registrationsCount;
  final DateTime? startDate;
  final DateTime? endDate;

  factory AdminEventRecord.fromJson(Map<String, dynamic> json) {
    final counts =
        json['_count'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    return AdminEventRecord(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      eventType: json['eventType']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      isPublished: json['isPublished'] == true,
      registrationsCount: (counts['registrations'] as num?)?.toInt() ?? 0,
      startDate: _opsDate(json['startDate']),
      endDate: _opsDate(json['endDate']),
    );
  }
}

class AdminEventRegistrationRecord {
  const AdminEventRegistrationRecord({
    required this.id,
    required this.eventId,
    required this.participantLabel,
    required this.email,
    required this.createdAt,
  });

  final String id;
  final String eventId;
  final String participantLabel;
  final String email;
  final String createdAt;

  factory AdminEventRegistrationRecord.fromJson(
    Map<String, dynamic> json, {
    required String eventId,
  }) {
    return AdminEventRegistrationRecord(
      id: json['id']?.toString() ?? '',
      eventId: eventId,
      participantLabel:
          json['email']?.toString() ??
          json['studentId']?.toString() ??
          json['userId']?.toString() ??
          'Registrant',
      email: json['email']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

class AdminEventGalleryRecord {
  const AdminEventGalleryRecord({
    required this.id,
    required this.eventId,
    required this.url,
    required this.caption,
    required this.createdAt,
  });

  final String id;
  final String eventId;
  final String url;
  final String caption;
  final String createdAt;

  factory AdminEventGalleryRecord.fromJson(
    Map<String, dynamic> json, {
    required String eventId,
  }) {
    return AdminEventGalleryRecord(
      id: json['id']?.toString() ?? '',
      eventId: eventId,
      url: json['url']?.toString() ?? '',
      caption: json['caption']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

class AdminCompetitionRecord {
  const AdminCompetitionRecord({
    required this.id,
    required this.title,
    required this.category,
    required this.eventId,
    required this.eventTitle,
    required this.status,
    required this.participantsCount,
  });

  final String id;
  final String title;
  final String category;
  final String eventId;
  final String eventTitle;
  final String status;
  final int participantsCount;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'eventId': eventId,
    'eventTitle': eventTitle,
    'status': status,
    'participantsCount': participantsCount,
  };

  factory AdminCompetitionRecord.fromJson(Map<String, dynamic> json) {
    return AdminCompetitionRecord(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      eventId: json['eventId']?.toString() ?? '',
      eventTitle: json['eventTitle']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PLANNED',
      participantsCount: (json['participantsCount'] as num?)?.toInt() ?? 0,
    );
  }
}

DateTime? _opsDate(dynamic date) {
  if (date == null) return null;
  try {
    return DateTime.parse(date.toString());
  } catch (_) {
    return null;
  }
}

DateTime? _opsInputDate(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  try {
    return DateTime.parse(value.trim());
  } catch (_) {
    return null;
  }
}

class AdminEventsController extends GetxController {
  AdminEventsController(this._adminService);

  final AdminService _adminService;

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final events = <AdminEventRecord>[].obs;
  final eventRegistrations = <AdminEventRegistrationRecord>[].obs;
  final eventGallery = <AdminEventGalleryRecord>[].obs;
  final competitions = <AdminCompetitionRecord>[].obs;
  final selectedEventId = ''.obs;

  // Analytics for the Reports tab
  final totalEvents = 0.obs;
  final activeCompetitions = 0.obs;
  final totalRegistrations = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadEventsData(force: true);
  }

  Future<void> refreshData() async {
    await loadEventsData(force: true);
  }

  Future<void> loadEventsData({bool force = false}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await Future.wait([loadEvents(), loadEventsWorkbenchSettings()]);
      _computeAnalytics();
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      AppToast.show(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  void _computeAnalytics() {
    totalEvents.value = events.length;
    activeCompetitions.value = competitions
        .where((c) => c.status == 'ONGOING' || c.status == 'PLANNED')
        .length;
    totalRegistrations.value = events.fold(
      0,
      (sum, e) => sum + e.registrationsCount,
    );
  }

  Future<void> loadEvents() async {
    final data = await _adminService.getEvents(page: 1, limit: 50);
    final rawItems = data['items'];
    if (rawItems is! List) {
      events.clear();
      return;
    }
    events.assignAll(
      rawItems
          .whereType<Map>()
          .map(
            (item) => AdminEventRecord.fromJson(item.cast<String, dynamic>()),
          )
          .toList(),
    );
    if (selectedEventId.value.isEmpty && events.isNotEmpty) {
      selectedEventId.value = events.first.id;
    }
    if (selectedEventId.value.isNotEmpty) {
      await loadEventInsights(selectedEventId.value);
    }
  }

  Future<void> loadEventInsights(String eventId) async {
    if (eventId.trim().isEmpty) {
      eventRegistrations.clear();
      eventGallery.clear();
      return;
    }
    selectedEventId.value = eventId;
    try {
      final data = await _adminService.getEventById(eventId);
      final rawRegs = data['registrations'];
      final rawGallery = data['gallery'];
      if (rawRegs is List) {
        eventRegistrations.assignAll(
          rawRegs
              .whereType<Map>()
              .map(
                (item) => AdminEventRegistrationRecord.fromJson(
                  item.cast<String, dynamic>(),
                  eventId: eventId,
                ),
              )
              .toList(),
        );
      } else {
        eventRegistrations.clear();
      }
      if (rawGallery is List) {
        eventGallery.assignAll(
          rawGallery
              .whereType<Map>()
              .map(
                (item) => AdminEventGalleryRecord.fromJson(
                  item.cast<String, dynamic>(),
                  eventId: eventId,
                ),
              )
              .toList(),
        );
      } else {
        eventGallery.clear();
      }
    } catch (_) {
      eventRegistrations.clear();
      eventGallery.clear();
    }
  }

  Future<void> loadEventsWorkbenchSettings() async {
    final data = await _adminService.getSchoolSettings();
    final raw = data['eventsWorkbench'];
    if (raw is! Map) {
      competitions.clear();
      return;
    }
    final map = Map<String, dynamic>.from(raw);
    competitions.assignAll(
      (map['competitions'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map(
            (e) => AdminCompetitionRecord.fromJson(e.cast<String, dynamic>()),
          )
          .toList(),
    );
  }

  Future<void> openCompetitionDialog({AdminCompetitionRecord? existing}) async {
    if (events.isEmpty) {
      AppToast.show('Create an event first.');
      return;
    }
    String eventId = existing?.eventId.isNotEmpty == true
        ? existing!.eventId
        : events.first.id;
    final titleController = TextEditingController(text: existing?.title ?? '');
    final categoryController = TextEditingController(
      text: existing?.category ?? '',
    );
    String status = existing?.status ?? 'PLANNED';
    final participantsController = TextEditingController(
      text: (existing?.participantsCount ?? 0).toString(),
    );

    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              existing == null ? 'Add Competition' : 'Update Competition',
            ),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: eventId,
                      decoration: const InputDecoration(labelText: 'Event'),
                      items: events
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item.id,
                              child: Text(item.title),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => eventId = value ?? ''),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Competition title',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items:
                          const ['PLANNED', 'ONGOING', 'COMPLETED', 'CANCELLED']
                              .map(
                                (item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                ),
                              )
                              .toList(),
                      onChanged: (value) =>
                          setState(() => status = value ?? 'PLANNED'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: participantsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Participants count',
                      ),
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
          );
        },
      ),
    );
    final participants = int.tryParse(participantsController.text.trim());
    if (ok != true ||
        eventId.isEmpty ||
        titleController.text.trim().isEmpty ||
        participants == null) {
      if (ok == true) {
        AppToast.show('Event, title, and participants are required.');
      }
      return;
    }
    final event = events.firstWhereOrNull((e) => e.id == eventId);
    competitions.assignAll([
      ...competitions.where((e) => e.id != existing?.id),
      AdminCompetitionRecord(
        id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: titleController.text.trim(),
        category: categoryController.text.trim(),
        eventId: eventId,
        eventTitle: event?.title ?? 'Event',
        status: status,
        participantsCount: participants,
      ),
    ]);
    await _saveEventsWorkbench();
    AppToast.show('Competition saved.');
  }

  Future<void> deleteCompetition(AdminCompetitionRecord item) async {
    if (!await _confirm('Delete ${item.title}?')) return;
    competitions.removeWhere((e) => e.id == item.id);
    await _saveEventsWorkbench();
    AppToast.show('Competition deleted.');
  }

  Future<void> _saveEventsWorkbench() async {
    await _adminService.patchSchoolSettings({
      'eventsWorkbench': {
        'competitions': competitions.map((e) => e.toJson()).toList(),
      },
    });
    _computeAnalytics();
  }

  Future<void> openEventDialog({AdminEventRecord? existing}) async {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final typeController = TextEditingController(
      text: existing?.eventType ?? '',
    );
    final locController = TextEditingController(text: existing?.location ?? '');
    final startDateController = TextEditingController(
      text: existing?.startDate?.toIso8601String().split('T').first ?? '',
    );
    final endDateController = TextEditingController(
      text: existing?.endDate?.toIso8601String().split('T').first ?? '',
    );
    bool isPublished = existing?.isPublished ?? false;

    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(existing == null ? 'Create Event' : 'Edit Event'),
            content: SizedBox(
              width: 460,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Event title',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: typeController,
                      decoration: const InputDecoration(
                        labelText: 'Event type',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: locController,
                      decoration: const InputDecoration(labelText: 'Location'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: startDateController,
                      decoration: const InputDecoration(
                        labelText: 'Start date',
                        helperText: 'YYYY-MM-DD',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: endDateController,
                      decoration: const InputDecoration(
                        labelText: 'End date',
                        helperText: 'YYYY-MM-DD',
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: isPublished,
                      onChanged: (value) => setState(() => isPublished = value),
                      title: const Text('Published'),
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
                child: Text(existing == null ? 'Create' : 'Save'),
              ),
            ],
          );
        },
      ),
    );

    final sDate = _opsInputDate(startDateController.text);
    if (ok != true ||
        titleController.text.trim().isEmpty ||
        typeController.text.trim().isEmpty ||
        sDate == null) {
      if (ok == true) AppToast.show('Title, type, and start date required.');
      return;
    }

    try {
      final eventTypeInput = typeController.text.trim();
      final eventTypeNormalized =
          eventTypeInput.isEmpty ? 'GENERAL' : eventTypeInput;
      final eventTypeCapped = eventTypeNormalized.length > 30
          ? eventTypeNormalized.substring(0, 30)
          : eventTypeNormalized;
      final locationInput = locController.text.trim();
      final payload = {
        'title': titleController.text.trim(),
        'eventType': eventTypeCapped,
        if (locationInput.isNotEmpty) 'location': locationInput,
        'startDate': sDate.toIso8601String(),
        'endDate':
            _opsInputDate(endDateController.text)?.toIso8601String() ??
            sDate.toIso8601String(),
        'isPublished': isPublished,
      };
      if (existing == null) {
        await _adminService.createEvent(payload);
        AppToast.show('Event created.');
      } else {
        await _adminService.updateEvent(id: existing.id, payload: payload);
        AppToast.show('Event updated.');
      }
      await loadEvents();
      _computeAnalytics();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> deleteEvent(AdminEventRecord item) async {
    if (!await _confirm('Delete ${item.title}?')) return;
    try {
      await _adminService.deleteEvent(item.id);
      AppToast.show('Event deleted.');
      await loadEvents();
      _computeAnalytics();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> openEventDetails(AdminEventRecord item) async {
    selectedEventId.value = item.id;
    await loadEventInsights(item.id);
    AppToast.show('Insights loaded for ${item.title}');
  }

  Future<void> registerForEvent(AdminEventRecord event) async {
    final emailController = TextEditingController();
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Register Participant'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'Email or User ID'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Register'),
          ),
        ],
      ),
    );
    if (ok != true || emailController.text.trim().isEmpty) return;
    try {
      await _adminService.registerForEvent(
        id: event.id,
        payload: {'email': emailController.text.trim()},
      );
      AppToast.show('Participant registered.');
      await loadEventInsights(event.id);
      await loadEvents();
      _computeAnalytics();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> addEventGallery(AdminEventRecord event) async {
    final urlController = TextEditingController();
    final captionController = TextEditingController();
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Add Gallery Photo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlController,
              decoration: const InputDecoration(labelText: 'Image URL'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: captionController,
              decoration: const InputDecoration(
                labelText: 'Caption (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (ok != true || urlController.text.trim().isEmpty) return;
    try {
      await _adminService.addEventGalleryImage(
        id: event.id,
        payload: {
          'url': urlController.text.trim(),
          'caption': captionController.text.trim(),
        },
      );
      AppToast.show('Photo added.');
      await loadEventInsights(event.id);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<bool> _confirm(String msg) async {
    final res = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm'),
        content: Text(msg),
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
    return res == true;
  }
}
