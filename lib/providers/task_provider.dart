import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/firestore_service.dart';
import '../services/user_service.dart';

class TaskProvider extends ChangeNotifier {
  final FirestoreService _firestore;
  String? _userId;

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  TaskProvider({FirestoreService? firestore}) : _firestore = firestore ?? FirestoreService();

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void updateUser(String? userId) {
    if (_userId == userId) return;
    _userId = userId;

    if (_userId == null) {
      _tasks = [];
      _error = null;
      _isLoading = false;
      notifyListeners();
    } else {
      // ✅ Usa watchAllUserTasks (próprias + partilhadas)
      _listenToAllTasks();
    }
  }

  // ✅ NOVO: Escuta tasks próprias + partilhadas
  void _listenToAllTasks() {
    if (_userId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    _firestore.watchAllUserTasks(_userId!).listen(
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

  // Mantém _listenToTasks antigo para compatibilidade (apenas próprias)
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

  // ✅ NOVO: Partilhar task com utilizador
  Future<void> shareTask(String taskId, String collaboratorId) async {
    if (_userId == null) return;
    final userService = UserService();
    await userService.shareTaskWithUser(taskId, _userId!, collaboratorId, add: true);
  }

  // ✅ NOVO: Remover partilha
  Future<void> unshareTask(String taskId, String collaboratorId) async {
    if (_userId == null) return;
    final userService = UserService();
    await userService.shareTaskWithUser(taskId, _userId!, collaboratorId, add: false);
  }

  Future<void> addAttachment(String taskId, String url) async {
    if (_userId == null) return;
    final task = _tasks.firstWhere((t) => t.id == taskId, orElse: () => throw Exception('Task not found'));
    final updated = task.copyWith(
      attachments: [...task.attachments, url],
      updatedAt: DateTime.now(),
    );
    await _firestore.updateTask(_userId!, updated);
  }

  Future<void> removeAttachment(String taskId, String url) async {
    if (_userId == null) return;
    final task = _tasks.firstWhere((t) => t.id == taskId, orElse: () => throw Exception('Task not found'));
    final updated = task.copyWith(
      attachments: task.attachments.where((a) => a != url).toList(),
      updatedAt: DateTime.now(),
    );
    await _firestore.updateTask(_userId!, updated);
  }
}
