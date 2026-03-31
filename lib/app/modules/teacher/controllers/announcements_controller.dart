import 'package:erp_frontend/app/modules/teacher/models/teacher_models.dart';
import 'package:get/get.dart';

import '../../../../common/api/api_client.dart';
import '../../../../common/api/api_endpoints.dart';
import '../../../../common/services/parent/parent_api_utils.dart';
import '../../../../common/services/staff/staff_service.dart';
import '../../../../common/utils/app_toast.dart';

class AnnouncementsController extends GetxController {
  final selectedTab = 0.obs; // 0: All Notices, 1: My Classes, 2: Important
  final announcements = <Announcement>[].obs;
  final filteredAnnouncements = <Announcement>[].obs;
  final searchQuery = ''.obs;

  final ApiClient _apiClient = Get.find<ApiClient>();
  final StaffService _staffService = Get.find<StaffService>();

  final teacherClassTitles = <String>{}.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    load();
    ever(searchQuery, _filter);
    ever(selectedTab, (_) => _filter(searchQuery.value));
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      await _loadTeacherClasses();
      await _loadAnnouncements();
      _filter(searchQuery.value);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
      announcements.clear();
      filteredAnnouncements.clear();
      teacherClassTitles.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadTeacherClasses() async {
    teacherClassTitles.clear();

    final profile = await _staffService.getProfile();
    final staffId = profile['staffId']?.toString();
    if (staffId == null || staffId.isEmpty) return;

    final res = await _apiClient.get(ApiEndpoints.schoolTimetableTeacher(staffId));
    final data = extractApiData(res.data, context: 'teacher timetable');
    final items = data['items'];
    if (items is! List) return;

    for (final raw in items) {
      if (raw is! Map) continue;
      final classRoom = raw['classRoom'];
      if (classRoom is! Map) continue;

      final name = classRoom['name']?.toString() ?? '';
      final section = classRoom['section']?.toString() ?? '';
      if (name.isEmpty) continue;

      final title = section.isNotEmpty ? '$name-$section' : name;
      teacherClassTitles.add(title);
    }
  }

  List<String> _parseAudience(String? audienceRaw) {
    final audience = (audienceRaw ?? '').trim();
    if (audience.isEmpty) return const ['All'];
    if (audience.toLowerCase() == 'all') return const ['All'];

    return audience
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  void _filter(String query) {
    final q = query.trim().toLowerCase();

    final List<Announcement> filtered = announcements.where((a) {
      if (selectedTab.value == 1) {
        final isAll = a.targetGrades.contains('All') || a.targetGrades.contains('ALL');
        final intersects = a.targetGrades.any((g) => teacherClassTitles.contains(g));
        if (!isAll && !intersects) return false;
      }
      if (selectedTab.value == 2 && !a.isUrgent) return false;

      if (q.isNotEmpty) {
        final hay = '${a.title} ${a.content}'.toLowerCase();
        if (!hay.contains(q)) return false;
      }
      return true;
    }).toList();

    filteredAnnouncements.assignAll(filtered);
  }

  Future<void> _loadAnnouncements() async {
    // We show sent announcements only for teachers/staff.
    final res = await _apiClient.get(
      ApiEndpoints.schoolAnnouncements,
      query: {
        'page': 1,
        'limit': 50,
        'status': 'SENT',
      },
    );
    final payload = extractApiData(res.data, context: 'announcements');
    final items = payload['items'];

    final list = <Announcement>[];
    if (items is List) {
      for (final raw in items.whereType<Map>()) {
        final title = raw['title']?.toString() ?? '';
        final content = raw['content']?.toString() ?? '';
        final audience = raw['audience']?.toString();

        final targetGrades = _parseAudience(audience);

        final tsRaw =
            raw['sentAt']?.toString() ?? raw['scheduledAt']?.toString() ?? raw['createdAt']?.toString();
        final ts = DateTime.tryParse(tsRaw ?? '') ?? DateTime.now();

        final isUrgent = (raw['status']?.toString().toUpperCase() == 'SENT') &&
            (title.toLowerCase().contains('urgent') || content.toLowerCase().contains('urgent'));

        list.add(Announcement(
          id: raw['id']?.toString() ?? '',
          title: title,
          content: content,
          authorName: 'School',
          authorImage: null,
          timestamp: ts,
          targetGrades: targetGrades,
          isUrgent: isUrgent,
          views: 0,
          imageUrl: null,
          fileUrl: null,
          fileName: null,
        ));
      }
    }

    announcements.assignAll(list);
  }

  Future<void> createAnnouncement({
    required String title,
    required String content,
    required String audience,
  }) async {
    Get.back(); // close dialog quickly
    try {
      // Create as draft then "send" (sets status=SENT).
      final createdRes = await _apiClient.post(
        ApiEndpoints.schoolAnnouncements,
        data: {
          'title': title,
          'content': content,
          'audience': audience,
          'status': 'DRAFT',
        },
      );
      final createdPayload = extractApiData(createdRes.data, context: 'create announcement');
      final announcement = createdPayload['announcement'] as Map?;
      final id = announcement?['id']?.toString();
      if (id == null || id.isEmpty) throw Exception('Announcement id missing.');

      await _apiClient.post(ApiEndpoints.schoolAnnouncementSend(id), data: {});

      await load();
      AppToast.show('Announcement posted');
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }
}
