import 'package:cloud_firestore/cloud_firestore.dart';

enum Priority {
  critico,
  alta,
  media,
  baixa,
  deixaPaOutroDia,
}

const priorityLabels = {
  Priority.critico:       'Crítico' ,
  Priority.alta:          'Alta',
  Priority.media:         'Média',
  Priority.baixa:         'Baixa',
  Priority.deixaPaOutroDia: 'Deixa pa outro dia',
};


class Task {
  String? id;
  String title;
  String description;
  String? projectId;  // ← NOVO: substitui category
  DateTime? dueDate;
  final Priority priority;
  bool isDone;
  DateTime? createdAt;
  DateTime? updatedAt;

  Task({
    this.id,
    required this.title,
    required this.description,
    this.projectId,    // ← NOVO
    this.dueDate,
    required this.priority,
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
      projectId: map['projectId'],  // ← NOVO: substitui category
      dueDate: (map['dueDate'] as Timestamp?)?.toDate(),
      priority: Priority.values[map['priority'] ?? 2],
      isDone: map['isDone'] ?? false,
      createdAt: tsCreated?.toDate(),
      updatedAt: tsUpdated?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'projectId': projectId,
      'dueDate': dueDate,
      'priority': priority.index,
      'isDone': isDone,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Map<String, dynamic> toMap() => toFirestore();
}
