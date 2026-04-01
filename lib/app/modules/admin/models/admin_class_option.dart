class AdminClassOption {
  const AdminClassOption({
    required this.id,
    required this.name,
    required this.section,
  });

  final String id;
  final String name;
  final String section;

  String get label => section.isEmpty ? name : '$name - $section';

  factory AdminClassOption.fromJson(Map<String, dynamic> json) {
    return AdminClassOption(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      section: json['section']?.toString() ?? '',
    );
  }
}
