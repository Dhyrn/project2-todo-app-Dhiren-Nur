import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String? id;
  String title;
  String description;
  DateTime? dueDate;
  String? priority;
  String? category;
  bool isDone;
  DateTime? createdAt;
  DateTime? updatedAt;

  Task({
    this.id,
    required this.title,
    required this.description,
    this.dueDate,
    this.priority,
    this.category,
    this.isDone = false,
    this.createdAt,
    this.updatedAt,
  });

  factory Task.fromFirestore(Map<String, dynamic> map, String id) {
    final tsCreated = map['createdAt'] as Timestamp?;
    final tsUpdated = map['updatedAt'] as Timestamp?;
    return Task(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: (map['dueDate'] as Timestamp?)?.toDate(),
      priority: map['priority'],
      category: map['category'],
      isDone: map['isDone'] ?? false,
      createdAt: tsCreated?.toDate(),
      updatedAt: tsUpdated?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'priority': priority,
      'category': category,
      'isDone': isDone,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Map<String, dynamic> toMap() => toFirestore();
}
