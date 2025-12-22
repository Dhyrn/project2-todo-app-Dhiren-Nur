import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // referência à subcoleção de tasks de um utilizador
  CollectionReference<Map<String, dynamic>> _userTasksRef(String userId) {
    return _db.collection('users').doc(userId).collection('tasks');
  }

  // stream de tasks do utilizador autenticado
  Stream<List<Task>> watchUserTasks(String userId) {
    return _userTasksRef(userId)
        .orderBy('priority')         // já aproveita o enum index
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
            (doc) => Task.fromFirestore(doc.data(), doc.id),
      )
          .toList(),
    );
  }

  Future<void> addTask(String userId, Task task) async {
    await _userTasksRef(userId).add(task.toFirestore());
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

    return snapshot.docs
        .map((doc) => Task.fromFirestore(doc.data(), doc.id))
        .toList();
  }
}
