import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class FirestoreService {
  final CollectionReference _tasksRef =
  FirebaseFirestore.instance.collection('tasks');

  Stream<List<Task>> getTasksStream() {
    return _tasksRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Task.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Future<void> addTask(Task task) async {
    try {
      task.createdAt = DateTime.now();
      task.updatedAt = DateTime.now();
      await _tasksRef.add(task.toFirestore());
    } on FirebaseException catch (e) {
      throw e;
    } catch (e) {
      throw Exception('Erro ao adicionar tarefa: $e');
    }
  }

  Future<void> updateTask(Task task) async {
    if (task.id == null) {
      throw Exception('ID da tarefa não informado');
    }
    try {
      task.updatedAt = DateTime.now();
      await _tasksRef.doc(task.id).update(task.toFirestore());
    } on FirebaseException catch (e) {
      throw e;
    } catch (e) {
      throw Exception('Erro ao atualizar tarefa');
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _tasksRef.doc(id).delete();
    } on FirebaseException catch (e) {
      throw e;
    } catch (e) {
      throw Exception('Erro ao deletar tarefa');
    }
  }

  Future<void> setTaskDone(String id, bool value) async {
    try {
      await _tasksRef.doc(id).update({'isDone': value, 'updatedAt': DateTime.now()});
    } on FirebaseException catch (e) {
      throw e;
    } catch (e) {
      throw Exception('Erro ao atualizar status da tarefa');
    }
  }

// Outros métodos, se necessários, podem vir aqui
}
