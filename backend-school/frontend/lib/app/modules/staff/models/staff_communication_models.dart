enum StaffMessageAudience { parent, student }

extension StaffMessageAudienceX on StaffMessageAudience {
  String get value =>
      this == StaffMessageAudience.parent ? 'parent' : 'student';

  String get label =>
      this == StaffMessageAudience.parent ? 'Parents' : 'Students';

  String get singularLabel =>
      this == StaffMessageAudience.parent ? 'Parent' : 'Student';

  static StaffMessageAudience fromValue(String value) {
    return value.toLowerCase() == 'student'
        ? StaffMessageAudience.student
        : StaffMessageAudience.parent;
  }
}

class StaffRecipient {
  const StaffRecipient({
    required this.id,
    required this.audience,
    required this.name,
    required this.subtitle,
    required this.contact,
    required this.deliveryTarget,
    this.badge = '',
    this.primaryStudentId = '',
    this.relatedStudentIds = const <String>[],
  });

  final String id;
  final StaffMessageAudience audience;
  final String name;
  final String subtitle;
  final String contact;
  final String deliveryTarget;
  final String badge;
  final String primaryStudentId;
  final List<String> relatedStudentIds;

  String get threadKey => '${audience.value}:$id';
}

class StaffConversationMessage {
  const StaffConversationMessage({
    required this.id,
    required this.body,
    required this.timestamp,
    required this.isOutgoing,
    this.status = 'SENT',
  });

  final String id;
  final String body;
  final DateTime timestamp;
  final bool isOutgoing;
  final String status;
}

class StaffConversationThread {
  const StaffConversationThread({
    required this.id,
    required this.recipientName,
    required this.lastMessage,
    required this.updatedAt,
    this.audience,
    this.recipientId,
    this.subtitle = '',
    this.unreadCount = 0,
  });

  final String id;
  final StaffMessageAudience? audience;
  final String? recipientId;
  final String recipientName;
  final String subtitle;
  final String lastMessage;
  final DateTime updatedAt;
  final int unreadCount;

  String get threadKey {
    if (audience != null && recipientId != null && recipientId!.isNotEmpty) {
      return '${audience!.value}:$recipientId';
    }
    return id;
  }

  StaffConversationThread copyWith({
    String? id,
    StaffMessageAudience? audience,
    String? recipientId,
    String? recipientName,
    String? subtitle,
    String? lastMessage,
    DateTime? updatedAt,
    int? unreadCount,
  }) {
    return StaffConversationThread(
      id: id ?? this.id,
      audience: audience ?? this.audience,
      recipientId: recipientId ?? this.recipientId,
      recipientName: recipientName ?? this.recipientName,
      subtitle: subtitle ?? this.subtitle,
      lastMessage: lastMessage ?? this.lastMessage,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class StaffAnnouncementRecord {
  const StaffAnnouncementRecord({
    required this.id,
    required this.title,
    required this.content,
    required this.audience,
    required this.status,
    required this.updatedAt,
    this.isUrgent = false,
  });

  final String id;
  final String title;
  final String content;
  final String audience;
  final String status;
  final DateTime updatedAt;
  final bool isUrgent;
}

class StaffNotificationRecord {
  const StaffNotificationRecord({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.status,
    required this.createdAt,
    required this.isRead,
    this.audience = '',
  });

  final String id;
  final String title;
  final String body;
  final String category;
  final String status;
  final DateTime createdAt;
  final bool isRead;
  final String audience;

  StaffNotificationRecord copyWith({
    String? id,
    String? title,
    String? body,
    String? category,
    String? status,
    DateTime? createdAt,
    bool? isRead,
    String? audience,
  }) {
    return StaffNotificationRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      audience: audience ?? this.audience,
    );
  }
}

class StaffMeetingSchedule {
  const StaffMeetingSchedule({
    required this.id,
    required this.parentName,
    required this.studentName,
    required this.purpose,
    required this.dateTime,
    required this.mode,
    required this.status,
    required this.note,
    this.location = '',
  });

  final String id;
  final String parentName;
  final String studentName;
  final String purpose;
  final DateTime dateTime;
  final String mode;
  final String location;
  final String status;
  final String note;

  String get title {
    if (studentName.trim().isEmpty) {
      return parentName;
    }
    return '$parentName / $studentName';
  }

  StaffMeetingSchedule copyWith({
    String? id,
    String? parentName,
    String? studentName,
    String? purpose,
    DateTime? dateTime,
    String? mode,
    String? location,
    String? status,
    String? note,
  }) {
    return StaffMeetingSchedule(
      id: id ?? this.id,
      parentName: parentName ?? this.parentName,
      studentName: studentName ?? this.studentName,
      purpose: purpose ?? this.purpose,
      dateTime: dateTime ?? this.dateTime,
      mode: mode ?? this.mode,
      location: location ?? this.location,
      status: status ?? this.status,
      note: note ?? this.note,
    );
  }
}
