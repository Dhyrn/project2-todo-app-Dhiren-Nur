import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';
import '../models/project.dart';
import 'package:rxdart/rxdart.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userTasksRef(String userId) {
    return _db.collection('users').doc(userId).collection('tasks');
  }

  CollectionReference<Map<String, dynamic>> _userSharedTasksRef(String userId) {
    return _db.collection('users').doc(userId).collection('sharedTasks');
  }

  Stream<List<Task>> watchAllUserTasks(String userId) {
    final own = _userTasksRef(userId).snapshots();
    final shared = _userSharedTasksRef(userId).snapshots();

    return Rx.combineLatest2(
      own,
      shared,
          (QuerySnapshot<Map<String, dynamic>> a,
          QuerySnapshot<Map<String, dynamic>> b) {

        final ownTasks = a.docs
            .map((d) => Task.fromFirestore(d.data(), d.id))
            .toList();

        final sharedTasks = b.docs
            .map((d) => Task.fromFirestore(d.data(), d.id))
            .toList();

        return [...ownTasks, ...sharedTasks];
      },
    );
  }

  // Mantém compatibilidade
  Stream<List<Task>> watchUserTasks(String userId) {
    return watchAllUserTasks(userId);
  }

  Future<void> addTask(String userId, Task task) async {
    final taskWithOwner = task.copyWith(
      ownerId: userId,
      collaborators: [],
      isShared: false,
      createdAt: DateTime.now(),
    );

    await _userTasksRef(userId).add(taskWithOwner.toFirestore());
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
