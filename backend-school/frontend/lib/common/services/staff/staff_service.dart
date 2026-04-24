import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import '../parent/parent_api_utils.dart';

class StaffService {
  StaffService(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getDashboard() async {
    final res = await _apiClient.get(ApiEndpoints.staffDashboard);
    return extractApiData(res.data, context: 'staff dashboard');
  }

  Future<Map<String, dynamic>> getProfile() async {
    final res = await _apiClient.get(ApiEndpoints.staffProfile);
    return extractApiData(res.data, context: 'staff profile');
  }

  Future<Map<String, dynamic>> updateProfile({
    required Map<String, dynamic> payload,
  }) async {
    final res = await _apiClient.put(ApiEndpoints.staffProfile, data: payload);
    return extractApiData(res.data, context: 'update staff profile');
  }

  Future<Map<String, dynamic>> getReports() async {
    final res = await _apiClient.get(ApiEndpoints.staffReports);
    return extractApiData(res.data, context: 'staff reports');
  }

  Future<Map<String, dynamic>> getCommunication() async {
    final res = await _apiClient.get(ApiEndpoints.staffCommunication);
    return extractApiData(res.data, context: 'staff communication');
  }

  Future<Map<String, dynamic>> sendMessage({
    required String to,
    required String message,
    String? audience,
    String? recipientId,
    String? recipientName,
    String? parentId,
    String? studentId,
    String? subject,
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.staffCommunicationMessages,
      data: {
        'to': to,
        'message': message,
        if (audience != null && audience.trim().isNotEmpty)
          'audience': audience.trim(),
        if (recipientId != null && recipientId.trim().isNotEmpty)
          'recipientId': recipientId.trim(),
        if (recipientName != null && recipientName.trim().isNotEmpty)
          'recipientName': recipientName.trim(),
        if (parentId != null && parentId.trim().isNotEmpty)
          'parentId': parentId.trim(),
        if (studentId != null && studentId.trim().isNotEmpty)
          'studentId': studentId.trim(),
        if (subject != null && subject.trim().isNotEmpty)
          'subject': subject.trim(),
      },
    );
    return extractApiData(res.data, context: 'send staff message');
  }

  Future<Map<String, dynamic>> scheduleMeeting({
    required String parentName,
    required DateTime scheduledAt,
    required String purpose,
    required String mode,
    String? parentId,
    String? studentId,
    String? studentName,
    String? location,
    String? note,
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.staffCommunicationMeetings,
      data: {
        'parentName': parentName,
        'scheduledAt': scheduledAt.toIso8601String(),
        'purpose': purpose,
        'mode': mode,
        if (parentId != null && parentId.trim().isNotEmpty)
          'parentId': parentId.trim(),
        if (studentId != null && studentId.trim().isNotEmpty)
          'studentId': studentId.trim(),
        if (studentName != null && studentName.trim().isNotEmpty)
          'studentName': studentName.trim(),
        if (location != null && location.trim().isNotEmpty)
          'location': location.trim(),
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      },
    );
    return extractApiData(res.data, context: 'schedule staff meeting');
  }

  Future<Map<String, dynamic>> saveMeetingNote({
    required String title,
    required String note,
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.staffCommunicationMeetingNotes,
      data: {'title': title, 'note': note},
    );
    return extractApiData(res.data, context: 'save meeting note');
  }

  Future<Map<String, dynamic>> getSettings() async {
    final res = await _apiClient.get(ApiEndpoints.staffSettings);
    return extractApiData(res.data, context: 'staff settings');
  }

  Future<Map<String, dynamic>> updateSettings({
    required bool notificationsEnabled,
    required bool privacyMode,
    required bool compactView,
  }) async {
    final res = await _apiClient.put(
      ApiEndpoints.staffSettings,
      data: {
        'notificationsEnabled': notificationsEnabled,
        'privacyMode': privacyMode,
        'compactView': compactView,
      },
    );
    return extractApiData(res.data, context: 'update staff settings');
  }

  /// Calls live OpenAI via backend when `OPENAI_API_KEY` is set on the server.
  Future<Map<String, dynamic>> aiAssist({
    required String prompt,
    String contextType = 'general',
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.staffAiAssist,
      data: {'prompt': prompt, 'contextType': contextType},
    );
    return extractApiData(res.data, context: 'staff AI assist');
  }
}
