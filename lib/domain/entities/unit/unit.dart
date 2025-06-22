import '../get_id.dart';

class Unit {
  final int id;
  final String name;
  final String? description;
  final DateTime? createDate;
  final DateTime? updatedDate;

  Unit({
    required this.id,
    required this.name,
    this.description,
    this.createDate,
    this.updatedDate,
  });

  int get getId => id;

  // Copy with method to create a new instance with updated fields
  Unit copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? createDate,
    DateTime? updatedDate,
  }) {
    return Unit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createDate: createDate ?? this.createDate,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }

  // Factory to create a unit from JSON
  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      createDate: json['createDate'] != null ? DateTime.parse(json['createDate'] as String) : null,
      updatedDate: json['updatedDate'] != null ? DateTime.parse(json['updatedDate'] as String) : null,
    );
  }

  // Convert unit to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (createDate != null) 'createDate': createDate!.toIso8601String(),
      if (updatedDate != null) 'updatedDate': updatedDate!.toIso8601String(),
    };
  }

  // Equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Unit && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
