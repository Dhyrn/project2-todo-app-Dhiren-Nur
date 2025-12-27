import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';
import '../models/project.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userTasksRef(String userId) {
    return _db.collection('users').doc(userId).collection('tasks');
  }

  CollectionReference<Map<String, dynamic>> _userSharedTasksRef(String userId) {
    return _db.collection('users').doc(userId).collection('sharedTasks');
  }

  Stream<List<Task>> watchAllUserTasks(String userId) {
    return _userTasksRef(userId)
        .orderBy('priority')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Task.fromFirestore(doc.data(), doc.id))
        .toList());
  }

  // Mantém compatibilidade
  Stream<List<Task>> watchUserTasks(String userId) {
    return watchAllUserTasks(userId);
  }

  Future<void> addTask(String userId, Task task) async {
    final taskWithCollab = task.copyWith(
      collaborators: task.collaborators ?? [],
    );
    await _userTasksRef(userId).add(taskWithCollab.toFirestore());
  }

  Future<void> updateTask(String userId, Task task) async {
    if (task.id == null) return;
    await _userTasksRef(userId).doc(task.id).update(task.toFirestore());
  }

  Future<void> deleteTask(String userId, String taskId) async {
    await _userTasksRef(userId).doc(taskId).delete();
  }

  Future<void> setTaskDone(String userId, String taskId, bool isDone) async {
    await _userTasksRef(userId).doc(taskId).update({
      'isDone': isDone,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Task>> searchTasks(String userId, String query) async {
    final snapshot = await _userTasksRef(userId)
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    return snapshot.docs.map((doc) => Task.fromFirestore(doc.data(), doc.id)).toList();
  }

  // PROJECTS (igual)
  CollectionReference<Map<String, dynamic>> _userProjectsRef(String userId) {
    return _db.collection('users').doc(userId).collection('projects');
  }

  Stream<List<Project>> watchUserProjects(String userId) {
    return _userProjectsRef(userId).orderBy('createdAt').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => Project.fromFirestore(doc.data(), doc.id)).toList(),
    );
  }

  Future<void> addProject(String userId, Project project) async {
    final docRef = _userProjectsRef(userId).doc();
    final projectToSave = Project(
      id: docRef.id,
      name: project.name,
      color: project.color,
      createdAt: project.createdAt ?? DateTime.now(),
    );
    await docRef.set(projectToSave.toFirestore());
  }

  Future<void> updateProject(String userId, Project project) async {
    if (project.id == null) return;
    await _userProjectsRef(userId).doc(project.id).update(project.toFirestore());
  }

  Future<void> deleteProject(String userId, String projectId) async {
    await _userProjectsRef(userId).doc(projectId).delete();
  }
}
