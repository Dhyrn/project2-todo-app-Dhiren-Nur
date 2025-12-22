import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/firestore_service.dart';

class TaskProvider extends ChangeNotifier {
  final FirestoreService _firestore;
  String? _userId;

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  TaskProvider({FirestoreService? firestore})
      : _firestore = firestore ?? FirestoreService();

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // chamado quando o utilizador de auth muda
  void updateUser(String? userId) {
    if (_userId == userId) return; // evita recriar stream sem necessidade
    _userId = userId;

    if (_userId == null) {
      _tasks = [];
      _error = null;
      _isLoading = false;
      notifyListeners();
    } else {
      _listenToTasks();
    }
  }

  void _listenToTasks() {
    if (_userId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    _firestore.watchUserTasks(_userId!).listen(
          (tasks) {
        _tasks = tasks;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  Future<void> addTask(Task task) async {
    if (_userId == null) return;
    await _firestore.addTask(_userId!, task);
  }

  Future<void> updateTask(Task task) async {
    if (_userId == null || task.id == null) return;
    await _firestore.updateTask(_userId!, task);
  }

  Future<void> deleteTask(String id) async {
    if (_userId == null) return;
    await _firestore.deleteTask(_userId!, id);
  }

  Future<void> setTaskDone(String id, bool isDone) async {
    if (_userId == null) return;
    await _firestore.setTaskDone(_userId!, id, isDone);
  }
}
