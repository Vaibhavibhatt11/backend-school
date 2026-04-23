enum StudyMaterialCategory { all, notes, videos, pdfs, resources }

extension StudyMaterialCategoryX on StudyMaterialCategory {
  String get label {
    switch (this) {
      case StudyMaterialCategory.all:
        return 'All';
      case StudyMaterialCategory.notes:
        return 'Notes';
      case StudyMaterialCategory.videos:
        return 'Videos';
      case StudyMaterialCategory.pdfs:
        return 'PDFs';
      case StudyMaterialCategory.resources:
        return 'Resources';
    }
  }

  String get emptyLabel {
    switch (this) {
      case StudyMaterialCategory.all:
        return 'No study materials are available yet.';
      case StudyMaterialCategory.notes:
        return 'No notes are available yet.';
      case StudyMaterialCategory.videos:
        return 'No videos are available yet.';
      case StudyMaterialCategory.pdfs:
        return 'No PDFs are available yet.';
      case StudyMaterialCategory.resources:
        return 'No learning resources are available yet.';
    }
  }
}

class StudyMaterialItem {
  const StudyMaterialItem({
    required this.id,
    required this.category,
    required this.title,
    required this.url,
    required this.subject,
    required this.classLabel,
    required this.description,
    required this.createdAt,
    required this.isPublished,
  });

  final String id;
  final StudyMaterialCategory category;
  final String title;
  final String url;
  final String subject;
  final String classLabel;
  final String description;
  final DateTime createdAt;
  final bool isPublished;

  factory StudyMaterialItem.fromJson(Map<String, dynamic> json) {
    final subjectData = json['subject'] as Map<String, dynamic>? ?? const {};
    final classData = json['class'] as Map<String, dynamic>? ?? const {};
    final className = _firstNonEmptyString([
      classData['name'],
      json['className'],
    ]);
    final section = _firstNonEmptyString([
      classData['section'],
      json['section'],
    ]);
    final classLabel = section.isEmpty
        ? className
        : className.isEmpty
        ? ''
        : '$className - $section';
    final url = _firstNonEmptyString([
      json['url'],
      json['fileUrl'],
      json['videoUrl'],
      json['resourceUrl'],
    ]);
    final type = _firstNonEmptyString([json['type'], 'NOTE']);

    return StudyMaterialItem(
      id: _firstNonEmptyString([json['id'], json['title'], url]),
      category: _inferCategory(type: type, url: url),
      title: _firstNonEmptyString([json['title'], 'Study Material']),
      url: url,
      subject: _firstNonEmptyString([subjectData['name'], json['subjectName']]),
      classLabel: classLabel,
      description: _firstNonEmptyString([
        json['description'],
        json['content'],
        json['summary'],
      ]),
      createdAt: _parseDate(
        json['createdAt'] ?? json['updatedAt'] ?? json['publishedAt'],
      ),
      isPublished: json['isPublished'] != false,
    );
  }

  String get subtitle {
    final parts = <String>[
      if (subject.trim().isNotEmpty) subject.trim(),
      if (classLabel.trim().isNotEmpty) classLabel.trim(),
    ];
    return parts.join(' | ');
  }

  String get hostLabel {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.trim().isEmpty) {
      return 'Hosted resource';
    }
    return uri.host.toLowerCase();
  }

  static StudyMaterialCategory _inferCategory({
    required String type,
    required String url,
  }) {
    final typeUpper = type.trim().toUpperCase();
    final urlLower = url.trim().toLowerCase();

    if (typeUpper == 'VIDEO' ||
        urlLower.contains('youtube.com') ||
        urlLower.contains('youtu.be') ||
        urlLower.endsWith('.mp4') ||
        urlLower.endsWith('.mov') ||
        urlLower.endsWith('.webm')) {
      return StudyMaterialCategory.videos;
    }

    if (typeUpper == 'PDF' || urlLower.endsWith('.pdf')) {
      return StudyMaterialCategory.pdfs;
    }

    if (typeUpper == 'RESOURCE' ||
        typeUpper == 'LINK' ||
        typeUpper == 'WEB' ||
        typeUpper == 'URL' ||
        typeUpper == 'ARTICLE') {
      return StudyMaterialCategory.resources;
    }

    return StudyMaterialCategory.notes;
  }

  static String _firstNonEmptyString(List<dynamic> values) {
    for (final value in values) {
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    final text = value.toString().trim();
    if (text.isEmpty) return DateTime.now();
    return DateTime.tryParse(text)?.toLocal() ?? DateTime.now();
  }
}
