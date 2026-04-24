enum StaffStudyMaterialCategory { notes, videos, pdfs, resources }

extension StaffStudyMaterialCategoryX on StaffStudyMaterialCategory {
  String get value {
    switch (this) {
      case StaffStudyMaterialCategory.notes:
        return 'notes';
      case StaffStudyMaterialCategory.videos:
        return 'videos';
      case StaffStudyMaterialCategory.pdfs:
        return 'pdfs';
      case StaffStudyMaterialCategory.resources:
        return 'resources';
    }
  }

  String get title {
    switch (this) {
      case StaffStudyMaterialCategory.notes:
        return 'Upload Notes';
      case StaffStudyMaterialCategory.videos:
        return 'Upload Videos';
      case StaffStudyMaterialCategory.pdfs:
        return 'Upload PDFs';
      case StaffStudyMaterialCategory.resources:
        return 'Learning Resources';
    }
  }

  String get singularLabel {
    switch (this) {
      case StaffStudyMaterialCategory.notes:
        return 'Note';
      case StaffStudyMaterialCategory.videos:
        return 'Video';
      case StaffStudyMaterialCategory.pdfs:
        return 'PDF';
      case StaffStudyMaterialCategory.resources:
        return 'Resource';
    }
  }

  String get apiType {
    switch (this) {
      case StaffStudyMaterialCategory.notes:
        return 'NOTE';
      case StaffStudyMaterialCategory.videos:
        return 'VIDEO';
      case StaffStudyMaterialCategory.pdfs:
        return 'PDF';
      case StaffStudyMaterialCategory.resources:
        return 'RESOURCE';
    }
  }

  static StaffStudyMaterialCategory fromValue(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'videos':
      case 'video':
        return StaffStudyMaterialCategory.videos;
      case 'pdfs':
      case 'pdf':
        return StaffStudyMaterialCategory.pdfs;
      case 'resources':
      case 'resource':
        return StaffStudyMaterialCategory.resources;
      default:
        return StaffStudyMaterialCategory.notes;
    }
  }
}

class StaffStudyMaterialClassOption {
  const StaffStudyMaterialClassOption({
    required this.id,
    required this.name,
    required this.section,
  });

  final String id;
  final String name;
  final String section;

  String get label => section.trim().isEmpty ? name : '$name - $section';
}

class StaffStudyMaterialSubjectOption {
  const StaffStudyMaterialSubjectOption({
    required this.id,
    required this.name,
    required this.code,
  });

  final String id;
  final String name;
  final String code;

  String get label => code.trim().isEmpty ? name : '$name | $code';
}

class StaffStudyMaterialRecord {
  const StaffStudyMaterialRecord({
    required this.id,
    required this.title,
    required this.type,
    required this.url,
    required this.classId,
    required this.classLabel,
    required this.subjectId,
    required this.subjectName,
    required this.createdAt,
    required this.isPublished,
    this.description = '',
  });

  final String id;
  final String title;
  final String type;
  final String url;
  final String classId;
  final String classLabel;
  final String subjectId;
  final String subjectName;
  final DateTime createdAt;
  final bool isPublished;
  final String description;

  StaffStudyMaterialCategory get category {
    final typeUpper = type.trim().toUpperCase();
    final urlLower = url.trim().toLowerCase();

    if (typeUpper == 'VIDEO' ||
        urlLower.contains('youtube.com') ||
        urlLower.contains('youtu.be') ||
        urlLower.endsWith('.mp4') ||
        urlLower.endsWith('.mov') ||
        urlLower.endsWith('.webm')) {
      return StaffStudyMaterialCategory.videos;
    }

    if (typeUpper == 'PDF' || urlLower.endsWith('.pdf')) {
      return StaffStudyMaterialCategory.pdfs;
    }

    if (typeUpper == 'RESOURCE' ||
        typeUpper == 'LINK' ||
        typeUpper == 'WEB' ||
        typeUpper == 'URL' ||
        typeUpper == 'ARTICLE') {
      return StaffStudyMaterialCategory.resources;
    }

    return StaffStudyMaterialCategory.notes;
  }

  String get subtitleParts {
    final parts = <String>[
      if (subjectName.trim().isNotEmpty) subjectName.trim(),
      if (classLabel.trim().isNotEmpty) classLabel.trim(),
    ];
    return parts.join(' | ');
  }
}
