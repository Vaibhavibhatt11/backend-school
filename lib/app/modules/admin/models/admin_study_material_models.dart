enum AdminStudyMaterialCategory { notes, videos, pdfs, resources }

extension AdminStudyMaterialCategoryX on AdminStudyMaterialCategory {
  String get value {
    switch (this) {
      case AdminStudyMaterialCategory.notes:
        return 'notes';
      case AdminStudyMaterialCategory.videos:
        return 'videos';
      case AdminStudyMaterialCategory.pdfs:
        return 'pdfs';
      case AdminStudyMaterialCategory.resources:
        return 'resources';
    }
  }

  String get title {
    switch (this) {
      case AdminStudyMaterialCategory.notes:
        return 'Upload Notes';
      case AdminStudyMaterialCategory.videos:
        return 'Upload Videos';
      case AdminStudyMaterialCategory.pdfs:
        return 'Upload PDFs';
      case AdminStudyMaterialCategory.resources:
        return 'Learning Resources';
    }
  }

  String get singularLabel {
    switch (this) {
      case AdminStudyMaterialCategory.notes:
        return 'Note';
      case AdminStudyMaterialCategory.videos:
        return 'Video';
      case AdminStudyMaterialCategory.pdfs:
        return 'PDF';
      case AdminStudyMaterialCategory.resources:
        return 'Resource';
    }
  }

  String get apiType {
    switch (this) {
      case AdminStudyMaterialCategory.notes:
        return 'NOTE';
      case AdminStudyMaterialCategory.videos:
        return 'VIDEO';
      case AdminStudyMaterialCategory.pdfs:
        return 'PDF';
      case AdminStudyMaterialCategory.resources:
        return 'RESOURCE';
    }
  }

  static AdminStudyMaterialCategory fromValue(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'videos':
      case 'video':
        return AdminStudyMaterialCategory.videos;
      case 'pdfs':
      case 'pdf':
        return AdminStudyMaterialCategory.pdfs;
      case 'resources':
      case 'resource':
        return AdminStudyMaterialCategory.resources;
      default:
        return AdminStudyMaterialCategory.notes;
    }
  }
}

class AdminStudyMaterialClassOption {
  const AdminStudyMaterialClassOption({
    required this.id,
    required this.name,
    required this.section,
  });

  final String id;
  final String name;
  final String section;

  String get label => section.trim().isEmpty ? name : '$name - $section';
}

class AdminStudyMaterialSubjectOption {
  const AdminStudyMaterialSubjectOption({
    required this.id,
    required this.name,
    required this.code,
  });

  final String id;
  final String name;
  final String code;

  String get label => code.trim().isEmpty ? name : '$name | $code';
}

class AdminStudyMaterialRecord {
  const AdminStudyMaterialRecord({
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

  AdminStudyMaterialCategory get category {
    final typeUpper = type.trim().toUpperCase();
    final urlLower = url.trim().toLowerCase();

    if (typeUpper == 'VIDEO' ||
        urlLower.contains('youtube.com') ||
        urlLower.contains('youtu.be') ||
        urlLower.endsWith('.mp4') ||
        urlLower.endsWith('.mov') ||
        urlLower.endsWith('.webm')) {
      return AdminStudyMaterialCategory.videos;
    }

    if (typeUpper == 'PDF' || urlLower.endsWith('.pdf')) {
      return AdminStudyMaterialCategory.pdfs;
    }

    if (typeUpper == 'RESOURCE' ||
        typeUpper == 'LINK' ||
        typeUpper == 'WEB' ||
        typeUpper == 'URL' ||
        typeUpper == 'ARTICLE') {
      return AdminStudyMaterialCategory.resources;
    }

    return AdminStudyMaterialCategory.notes;
  }

  String get subtitleParts {
    final parts = <String>[
      if (subjectName.trim().isNotEmpty) subjectName.trim(),
      if (classLabel.trim().isNotEmpty) classLabel.trim(),
    ];
    return parts.join(' | ');
  }
}

