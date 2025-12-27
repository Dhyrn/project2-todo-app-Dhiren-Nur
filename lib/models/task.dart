import 'package:cloud_firestore/cloud_firestore.dart';
import 'subtask.dart';

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
  String? projectId;
  DateTime? dueDate;
  final Priority priority;
  bool isDone;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<Subtask> subtasks;
  GeoPoint? location;
  String? locationName;
  List<String> attachments;
  bool isOutdoor;
  bool locationReminderEnabled;
  List<String>? collaborators;

  Task({
    this.id,
    required this.title,
    required this.description,
    this.projectId,
    this.dueDate,
    required this.priority,
    this.isDone = false,
    this.createdAt,
    this.updatedAt,
    List<Subtask>? subtasks,
    this.location,
    this.locationName,
    List<String>? attachments,
    this.isOutdoor = false,
    this.locationReminderEnabled = false,
    this.collaborators,
  })  : subtasks = subtasks ?? [],
        attachments = attachments ?? [];

  factory Task.fromFirestore(Map<String, dynamic> map, String id) {
    final tsCreated = map['createdAt'] as Timestamp?;
    final tsUpdated = map['updatedAt'] as Timestamp?;
    final List<dynamic>? rawSubtasks = map['subtasks'] as List<dynamic>?;
    final List<dynamic>? rawAttachments = map['attachments'] as List<dynamic>?;
    final List<dynamic>? rawCollaborators = map['collaborators'] as List<dynamic?>?;

    return Task(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      projectId: map['projectId'],
      dueDate: (map['dueDate'] as Timestamp?)?.toDate(),
      priority: Priority.values[map['priority'] ?? 2], // Média como default
      isDone: map['isDone'] ?? false,
      createdAt: tsCreated?.toDate(),
      updatedAt: tsUpdated?.toDate(),
      subtasks: rawSubtasks != null
          ? rawSubtasks
          .whereType<Map<String, dynamic>>()
          .map((m) => Subtask.fromMap(m))
          .toList()
          : [],
      location: map['location'] as GeoPoint?,
      locationName: map['locationName'] as String?,
      attachments: rawAttachments != null
          ? rawAttachments.whereType<String>().toList()
          : [],
      isOutdoor: map['isOutdoor'] ?? false,
      locationReminderEnabled: map['locationReminderEnabled'] ?? false,
      collaborators: rawCollaborators != null
          ? rawCollaborators.whereType<String>().toList()
          : [],
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
      'subtasks': subtasks.map((s) => s.toMap()).toList(),
      'location': location,
      'locationName': locationName,
      'attachments': attachments,
      'isOutdoor': isOutdoor,
      'locationReminderEnabled': locationReminderEnabled,
      'collaborators': collaborators ?? [],
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? projectId,
    DateTime? dueDate,
    Priority? priority,
    bool? isDone,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Subtask>? subtasks,
    GeoPoint? location,
    String? locationName,
    List<String>? attachments,
    bool? isOutdoor,
    bool? locationReminderEnabled,
    List<String>? collaborators,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      projectId: projectId ?? this.projectId,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      subtasks: subtasks ?? this.subtasks,
      location: location ?? this.location,
      locationName: locationName ?? this.locationName,
      attachments: attachments ?? this.attachments,
      isOutdoor: isOutdoor ?? this.isOutdoor,
      locationReminderEnabled: locationReminderEnabled ?? this.locationReminderEnabled,
      collaborators: collaborators ?? this.collaborators,
    );
  }

  Map<String, dynamic> toMap() => toFirestore();
}
