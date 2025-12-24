import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/project.dart';
import '../services/firestore_service.dart';

class ProjectProvider with ChangeNotifier {
  final FirestoreService _firestoreService;

  ProjectProvider(this._firestoreService);

  String? _userId;
  List<Project> _projects = [];
  StreamSubscription<List<Project>>? _projectsSub;

  List<Project> get projects => _projects;

  String? _selectedProjectId;
  String? get selectedProjectId => _selectedProjectId;

  // chamar quando o AuthProvider mudar de user
  void updateUser(String? userId) {
    if (_userId == userId) return;

    _userId = userId;
    _projects = [];
    _selectedProjectId = null;
    _projectsSub?.cancel();
    _projectsSub = null;

    if (_userId != null) {
      _listenToProjects();
    }
    notifyListeners();
  }

  void _listenToProjects() {
    _projectsSub = _firestoreService.watchUserProjects(_userId!).listen(
          (projects) {
        _projects = projects;

        // se não houver projeto selecionado e existirem projetos, seleciona o primeiro
        if (_selectedProjectId == null && _projects.isNotEmpty) {
          _selectedProjectId = _projects.first.id;
        } else if (_projects.indexWhere((p) => p.id == _selectedProjectId) == -1) {
          // projeto selecionado foi apagado → limpar seleção
          _selectedProjectId = _projects.isNotEmpty ? _projects.first.id : null;
        }

        notifyListeners();
      },
    );
  }

  Future<void> addProject(Project project) async {
    if (_userId == null) return;
    await _firestoreService.addProject(_userId!, project);
  }

  Future<void> updateProject(Project project) async {
    if (_userId == null) return;
    await _firestoreService.updateProject(_userId!, project);
  }

  Future<void> deleteProject(String projectId) async {
    if (_userId == null) return;
    await _firestoreService.deleteProject(_userId!, projectId);
  }

  void selectProject(String? projectId) {
    _selectedProjectId = projectId;
    notifyListeners();
  }

  @override
  void dispose() {
    _projectsSub?.cancel();
    super.dispose();
  }
}
