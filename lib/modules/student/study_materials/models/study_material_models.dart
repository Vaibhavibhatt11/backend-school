/// Type of study material file.
enum StudyMaterialFileType {
  pdf,
  ppt,
  image,
}

/// A single study material (PDF, PPT, or image) that user can open/view.
class StudyMaterialItem {
  const StudyMaterialItem({
    required this.id,
    required this.type,
    required this.title,
    this.subject,
    this.description,
  });

  final String id;
  final StudyMaterialFileType type;
  final String title;
  final String? subject;
  final String? description;
}
