import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  String? id;
  String name;
  String color;
  DateTime? createdAt;

  Project({
    this.id,
    required this.name,
    required this.color,
    this.createdAt,
  });

  factory Project.fromFirestore(Map<String, dynamic> map, String id) {
    final tsCreated = map['createdAt'] as Timestamp?;
    return Project(
      id: id,
      name: map['name'] ?? '',
      color: map['color'] ?? '#FF6F00',
      createdAt: tsCreated?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'color': color,
      'createdAt': createdAt,
    };
  }

  Map<String, dynamic> toMap() => toFirestore();
}
