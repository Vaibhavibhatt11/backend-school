// lib/app/data/models/teacher_models.dart

enum AttendanceStatus { present, absent, late, unknown }

class Student {
  final String id;
  final String name;
  final String rollNo;
  final String grade;
  final String? imageUrl;
  final String? parentName;
  final String? parentPhone;
  final double attendancePercentage;
  final Map<String, AttendanceStatus> recentAttendance; // day -> status

  Student({
    required this.id,
    required this.name,
    required this.rollNo,
    required this.grade,
    this.imageUrl,
    this.parentName,
    this.parentPhone,
    required this.attendancePercentage,
    required this.recentAttendance,
  });
}

class ClassSession {
  final String id;
  final String title;
  final String grade;
  final String subject;
  final String? room;
  final DateTime startTime;
  final DateTime endTime;
  final bool isLive;
  final bool isCompleted;

  ClassSession({
    required this.id,
    required this.title,
    required this.grade,
    required this.subject,
    this.room,
    required this.startTime,
    required this.endTime,
    this.isLive = false,
    this.isCompleted = false,
  });
}

class Announcement {
  final String id;
  final String title;
  final String content;
  final String authorName;
  final String? authorImage;
  final DateTime timestamp;
  final List<String> targetGrades;
  final bool isUrgent;
  final String? imageUrl;
  final String? fileUrl;
  final String? fileName;
  final int views;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    this.authorImage,
    required this.timestamp,
    required this.targetGrades,
    this.isUrgent = false,
    this.imageUrl,
    this.fileUrl,
    this.fileName,
    this.views = 0,
  });
}

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String category; // e.g., 'Attendance', 'Principal', 'System'
  final DateTime timestamp;
  late final bool isRead;
  final String? actionRoute;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.timestamp,
    this.isRead = false,
    this.actionRoute,
  });
}

class UploadHistoryItem {
  final String id;
  final String fileName;
  final String fileType; // pdf, image, etc.
  final String targetClass;
  final DateTime uploadedAt;
  final bool isShared;

  UploadHistoryItem({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.targetClass,
    required this.uploadedAt,
    this.isShared = true,
  });
}
