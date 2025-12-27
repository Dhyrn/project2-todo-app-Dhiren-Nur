import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/project.dart';
import '../providers/task_provider.dart';
import '../providers/project_provider.dart';
import '../providers/weather_provider.dart';
import '../services/location_reminder_service.dart';
import './add_edit_screen.dart';
import './detail_screen.dart';
import './profile_screen.dart';

enum ListMode { tasks, projects }

// Filtros e ordenação
enum TaskFilter { all, pending, done }
enum TaskSort { priority, createdAt, dueDate }

class ListScreen extends StatefulWidget {
  static const routeName = '/list';

  const ListScreen({Key? key}) : super(key: key);

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> with WidgetsBindingObserver{
  ListMode _mode = ListMode.tasks;
  String? _currentProjectId;
  String? _currentProjectName;

  late TextEditingController _searchController;
  int totalTasksCount = 0;

  TaskFilter _taskFilter = TaskFilter.all;
  TaskSort _taskSort = TaskSort.priority;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // Weather refresh automático
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LocationReminderService.instance.checkNearbyTasks(context);
    });
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TaskProvider, ProjectProvider>(
      builder: (context, taskProvider, projectProvider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            leading: (_mode == ListMode.tasks && _currentProjectId != null)
                ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  _currentProjectId = null;
                  _currentProjectName = null;
                  _mode = ListMode.projects;
                  _searchController.clear();
                });
              },
            )
                : null,
            title: Row(
              children: [
                Expanded(
                  child: (_mode == ListMode.tasks && _currentProjectId != null)
                      ? Text(
                    'Tarefas – $_currentProjectName',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  )
                      : _buildModeDropdownInAppBar(),
                ),
                const SizedBox(width: 8),
                _buildCountChip(taskProvider, projectProvider),
              ],
            ),
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Container(
                    margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: _mode == ListMode.tasks
                            ? "Pesquisar tarefas..."
                            : "Pesquisar projetos...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        prefixIcon:
                        Icon(Icons.search, color: Colors.grey[600]),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_searchController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              ),
                            if (_mode == ListMode.tasks)
                            IconButton(
                              icon: const Icon(Icons.filter_list),
                              onPressed: _openFilterSheet,
                            ),
                          ],
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),

                  Expanded(
                    child: Builder(
                      builder: (context) {
                        // MODO PROJETOS
                        if (_mode == ListMode.projects) {
                          List<Project> projects = projectProvider.projects;

                          if (projects.isEmpty) {
                            return const Center(
                              child: Text(
                                'Nenhum projeto ainda',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.only(bottom: 20),
                            itemCount: projects.length,
                            itemBuilder: (ctx, i) {
                              final project = projects[i];
                              Color color;
                              try {
                                color = Color(int.parse(project.color
                                    .replaceFirst('#', '0xFF')));
                              } catch (_) {
                                color = Colors.blueGrey;
                              }

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: color,
                                    child: const Icon(
                                      Icons.folder,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    project.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _currentProjectId = project.id;
                                      _currentProjectName = project.name;
                                      _mode = ListMode.tasks;
                                      _searchController.clear();
                                    });
                                  },
                                  onLongPress: () =>
                                      _showProjectOptions(context, project),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.more_vert,
                                        color: Colors.black54),
                                    onPressed: () =>
                                        _showProjectOptions(context, project),
                                  ),
                                ),
                              );
                            },
                          );
                        }

                        // MODO TAREFAS
                        if (taskProvider.isLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (taskProvider.error != null) {
                          return Center(
                            child: Text(
                              'Erro: ${taskProvider.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        // lista base (por projeto)
                        List<Task> projectTasks =
                        List<Task>.from(taskProvider.tasks);
                        if (_currentProjectId != null) {
                          projectTasks = projectTasks
                              .where(
                                  (t) => t.projectId == _currentProjectId)
                              .toList();
                        }

                        // 1) filtro de estado
                        projectTasks = projectTasks.where((t) {
                          switch (_taskFilter) {
                            case TaskFilter.all:
                              return true;
                            case TaskFilter.pending:
                              return !t.isDone;
                            case TaskFilter.done:
                              return t.isDone;
                          }
                        }).toList();

                        totalTasksCount = projectTasks.length;

                        final query =
                        _searchController.text.toLowerCase().trim();
                        final List<Task> visibleTasks = projectTasks
                            .where((task) => task.title
                            .toLowerCase()
                            .contains(query))
                            .toList();

                        if (visibleTasks.isEmpty && query.isEmpty) {
                          return const Center(
                            child: Text(
                              'Nenhuma tarefa ainda',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: [
                            if (query.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                  Border.all(color: Colors.blue[200]!),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${visibleTasks.length} de $totalTasksCount tarefas',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue[800],
                                        fontSize: 14,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {});
                                      },
                                      child: const Text('Mostrar todas'),
                                    ),
                                  ],
                                ),
                              ),
                            Expanded(
                              child: ListView.builder(
                                padding:
                                const EdgeInsets.only(bottom: 20),
                                itemCount: visibleTasks.length,
                                itemBuilder: (ctx, i) {
                                  final task = visibleTasks[i];
                                  final priorityColor =
                                  _priorityColor(task.priority);

                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                      BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12
                                              .withOpacity(0.05),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: InkWell(
                                      borderRadius:
                                      BorderRadius.circular(14),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                DetailScreen(task: task),
                                          ),
                                        );
                                      },
                                      onLongPress: () =>
                                          _confirmDelete(context, task.id!),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 70,
                                            decoration: BoxDecoration(
                                              color: priorityColor,
                                              borderRadius:
                                              const BorderRadius.only(
                                                topLeft: Radius.circular(14),
                                                bottomLeft:
                                                Radius.circular(14),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: ListTile(
                                              contentPadding:
                                              const EdgeInsets
                                                  .symmetric(
                                                horizontal: 16,
                                                vertical: 6,
                                              ),
                                              leading: InkWell(
                                                borderRadius:
                                                BorderRadius.circular(30),
                                                onTap: () async {
                                                  final provider =
                                                  Provider.of<TaskProvider>(
                                                    context,
                                                    listen: false,
                                                  );

                                                  final updatedTask = Task(
                                                    id: task.id,
                                                    title: task.title,
                                                    description:
                                                    task.description,
                                                    projectId: task.projectId,
                                                    dueDate: task.dueDate,
                                                    priority: task.priority,
                                                    isDone: !task.isDone,
                                                    createdAt: task.createdAt,
                                                    updatedAt: DateTime.now(),
                                                  );

                                                  await provider
                                                      .updateTask(
                                                      updatedTask);
                                                },
                                                child: Icon(
                                                  task.isDone
                                                      ? Icons.check_circle
                                                      : Icons.circle_outlined,
                                                  color: task.isDone
                                                      ? Colors.green
                                                      : Colors.black45,
                                                  size: 28,
                                                ),
                                              ),
                                              title: Text(
                                                task.title,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  decoration: task.isDone
                                                      ? TextDecoration
                                                      .lineThrough
                                                      : TextDecoration.none,
                                                ),
                                              ),
                                              subtitle: Text(
                                                task.description,
                                                style: const TextStyle(
                                                    color:
                                                    Colors.black54),
                                              ),
                                              trailing: IconButton(
                                                icon: const Icon(
                                                  Icons.more_vert,
                                                  color: Colors.black54,
                                                ),
                                                onPressed: () {
                                                  _showOptions(
                                                      context, task);
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),

              // Temperatura posicionada conforme pedido
              Positioned(
                right: 15,
                bottom: 115,
                child: _buildTemperatureChip(),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.blueAccent,
            elevation: 4,
            onPressed: () {
              if (_mode == ListMode.projects) {
                _showAddProjectDialog(context);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditScreen(
                      initialProjectId: _currentProjectId,
                    ),
                  ),
                );
              }
            },
            child: Icon(
              _mode == ListMode.projects
                  ? Icons.create_new_folder
                  : Icons.add,
              size: 28,
            ),
          ),
        );
      },
    );
  }

  // ===== filtros em bottom sheet =====

  void _openFilterSheet() {
    if (_mode != ListMode.tasks) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: SizedBox(
                  width: 40,
                  child: Divider(thickness: 3),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Filtros rápidos',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Todas'),
                    selected: _taskFilter == TaskFilter.all,
                    onSelected: (_) {
                      setState(() => _taskFilter = TaskFilter.all);
                      Navigator.pop(ctx);
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Por fazer'),
                    selected: _taskFilter == TaskFilter.pending,
                    onSelected: (_) {
                      setState(() => _taskFilter = TaskFilter.pending);
                      Navigator.pop(ctx);
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Concluídas'),
                    selected: _taskFilter == TaskFilter.done,
                    onSelected: (_) {
                      setState(() => _taskFilter = TaskFilter.done);
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Ordenar por',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                children: [
                  RadioListTile<TaskSort>(
                    dense: true,
                    value: TaskSort.priority,
                    groupValue: _taskSort,
                    title: const Text('Prioridade'),
                    onChanged: (val) {
                      if (val == null) return;
                      setState(() => _taskSort = val);
                      Navigator.pop(ctx);
                    },
                  ),
                  RadioListTile<TaskSort>(
                    dense: true,
                    value: TaskSort.dueDate,
                    groupValue: _taskSort,
                    title: const Text('Data de vencimento'),
                    onChanged: (val) {
                      if (val == null) return;
                      setState(() => _taskSort = val);
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _taskFilter = TaskFilter.all;
                      _taskSort = TaskSort.priority;
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('Repor padrão'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==== helpers ====

  Widget _buildModeDropdownInAppBar() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        value: _mode == ListMode.tasks ? 'tasks' : 'projects',
        icon: const Icon(Icons.keyboard_arrow_down),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        items: const [
          DropdownMenuItem(
            value: 'tasks',
            child: Text(
              'Todas as tarefas',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          DropdownMenuItem(
            value: 'projects',
            child: Text(
              'Todos os projetos',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        onChanged: (value) {
          if (value == null) return;
          setState(() {
            _mode = value == 'tasks' ? ListMode.tasks : ListMode.projects;
            if (_mode == ListMode.projects) {
              _currentProjectId = null;
              _currentProjectName = null;
            }
            _searchController.clear();
          });
        },
      ),
    );
  }

  Widget _buildTemperatureChip() {
    final weatherProvider = Provider.of<WeatherProvider>(context);

    if (weatherProvider.isLoading) {
      return Container(
        width: 60,
        height: 26,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
      );
    }

    if (weatherProvider.error != null ||
        weatherProvider.currentWeather == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.thermostat, size: 16, color: Colors.grey),
            SizedBox(width: 4),
            Text(
              '—°C',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    final temp = weatherProvider.currentWeather!.temperature;
    final bgColor = temp >= 25
        ? Colors.red[100]
        : temp <= 10
        ? Colors.blue[100]
        : Colors.orange[100];
    final fgColor = temp >= 25
        ? Colors.red[900]
        : temp <= 10
        ? Colors.blue[900]
        : Colors.orange[900];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.thermostat, size: 16, color: Colors.black54),
          const SizedBox(width: 4),
          Text(
            '${temp.toStringAsFixed(1)}°C',
            style: TextStyle(
              color: fgColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountChip(
      TaskProvider taskProvider, ProjectProvider projectProvider) {
    late int count;
    late String label;

    if (_mode == ListMode.tasks) {
      List<Task> tasks = List<Task>.from(taskProvider.tasks);
      if (_currentProjectId != null) {
        tasks = tasks.where((t) => t.projectId == _currentProjectId).toList();
      }
      count = tasks.where((t) => !t.isDone).length;
      label = '$count por fazer';
    } else {
      count = projectProvider.projects.length;
      label = '$count projetos';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.blue[900],
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Color _priorityColor(Priority p) {
    switch (p) {
      case Priority.critico:
        return Colors.red.shade700;
      case Priority.alta:
        return Colors.deepOrange.shade400;
      case Priority.media:
        return Colors.amber.shade600;
      case Priority.baixa:
        return Colors.green.shade600;
      case Priority.deixaPaOutroDia:
        return Colors.blueGrey.shade200;
    }
  }

  void _showOptions(BuildContext context, Task task) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Editar'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditScreen(existingTask: task),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Excluir'),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, task.id!);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Excluir tarefa?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('Deseja realmente excluir esta tarefa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final provider =
              Provider.of<TaskProvider>(context, listen: false);
              provider.deleteTask(id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _showAddProjectDialog(BuildContext context) {
    final projectProvider =
    Provider.of<ProjectProvider>(context, listen: false);
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Novo Projeto'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nome do projeto',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                final project = Project(
                  name: controller.text.trim(),
                  color: '#FF6F00',
                );
                await projectProvider.addProject(project);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  // ==== opções para projetos ====

  void _showProjectOptions(BuildContext context, Project project) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.blue),
            title: const Text('Editar projeto'),
            onTap: () {
              Navigator.pop(context);
              _showEditProjectDialog(context, project);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Eliminar projeto'),
            onTap: () {
              Navigator.pop(context);
              _confirmDeleteProject(context, project.id!);
            },
          ),
        ],
      ),
    );
  }

  void _showEditProjectDialog(BuildContext context, Project project) {
    final controller = TextEditingController(text: project.name);
    final projectProvider =
    Provider.of<ProjectProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Editar Projeto'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nome do projeto',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final updated = Project(
                  id: project.id,
                  name: name,
                  color: project.color,
                );
                await projectProvider.updateProject(updated);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteProject(BuildContext context, String id) {
    final projectProvider =
    Provider.of<ProjectProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Eliminar projeto?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
            'As tarefas podem ficar sem projeto se não as apagares manualmente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              await projectProvider.deleteProject(id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
