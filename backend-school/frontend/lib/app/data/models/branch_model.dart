class BranchModel {
  final String id;
  final String name;
  final String address;
  final bool isSelected;

  BranchModel({
    required this.id,
    required this.name,
    required this.address,
    this.isSelected = false,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      isSelected: json['isSelected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'isSelected': isSelected,
    };
  }
}