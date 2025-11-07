import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/firestore_service.dart';

class TaskProvider with ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  List<Task> _tasks = [];
  bool _isLoading = true;
  String? _error;

  TaskProvider() {
    _init();
  }

  void _init() {
    _service.getTasksStream().listen((tasks) {
      _tasks = tasks;
      _isLoading = false;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> addTask(Task task) async {
    try {
      await _service.addTask(task);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _service.updateTask(task);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _service.deleteTask(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> setTaskDone(String id, bool value) async {
    try {
      await _service.setTaskDone(id, value);

      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tasks[index].isDone = value;
        _tasks[index].updatedAt = DateTime.now();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
