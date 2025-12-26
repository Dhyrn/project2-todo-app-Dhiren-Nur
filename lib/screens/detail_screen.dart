import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/project.dart';
import '../models/subtask.dart';
import '../providers/project_provider.dart';
import '../providers/task_provider.dart';
import '../services/storage_service.dart';
import '../services/image_service.dart';
import 'add_edit_screen.dart';

class DetailScreen extends StatefulWidget {
  static const routeName = '/detail';
  final Task task;

  const DetailScreen({Key? key, required this.task}) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late bool _isDone;
  late List<Subtask> _subtasks;
  final _storageService = StorageService();
  final _imageService = ImageService();

  String get _createdAtFormatted {
    final dt = widget.task.createdAt;
    return DateFormat('dd/MM/yyyy HH:mm').format(dt!);
  }

  @override
  void initState() {
    super.initState();
    _isDone = widget.task.isDone;
    _subtasks = List<Subtask>.from(widget.task.subtasks);
  }

  Task _baseUpdatedTask({
    List<Subtask>? subtasks,
    GeoPoint? location,
    String? locationName,
    List<String>? attachments,
  }) {
    return Task(
      id: widget.task.id,
      title: widget.task.title,
      description: widget.task.description,
      projectId: widget.task.projectId,
      dueDate: widget.task.dueDate,
      priority: widget.task.priority,
      isDone: _isDone,
      createdAt: widget.task.createdAt,
      updatedAt: DateTime.now(),
      subtasks: subtasks ?? _subtasks,
      location: location ?? widget.task.location,
      locationName: locationName ?? widget.task.locationName,
      attachments: attachments ?? widget.task.attachments,
    );
  }

  void _toggleDone(bool value) async {
    setState(() {
      _isDone = value;
    });

    final provider = Provider.of<TaskProvider>(context, listen: false);
    await provider.setTaskDone(widget.task.id!, value);
  }

  Future<void> _deleteSubtask(int index) async {
    setState(() {
      _subtasks.removeAt(index);
    });

    final provider = Provider.of<TaskProvider>(context, listen: false);
    await provider.updateTask(_baseUpdatedTask());
  }

  Future<void> _toggleSubtaskDone(int index, bool value) async {
    setState(() {
      _subtasks[index] = _subtasks[index].copyWith(isDone: value);
    });

    final provider = Provider.of<TaskProvider>(context, listen: false);
    await provider.updateTask(_baseUpdatedTask());
  }

  void _showAddSubtaskDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova subtarefa'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Título da subtarefa',
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
              final text = controller.text.trim();
              if (text.isEmpty) return;

              setState(() {
                _subtasks.add(Subtask(title: text));
              });

              final provider =
              Provider.of<TaskProvider>(context, listen: false);
              await provider.updateTask(_baseUpdatedTask());
              if (mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  Future<void> _setMockLocation() async {
    final nameController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Definir localização'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nome da localização (ex: Casa, Trabalho)',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final geo = const GeoPoint(38.7223, -9.1393); // Lisboa exemplo
    final locationName = nameController.text.trim().isEmpty
        ? 'Localização'
        : nameController.text.trim();

    final provider = Provider.of<TaskProvider>(context, listen: false);
    await provider.updateTask(
      _baseUpdatedTask(
        location: geo,
        locationName: locationName,
      ),
    );

    setState(() {
      widget.task.location = geo;
      widget.task.locationName = locationName;
    });
  }

  Future<void> _clearLocation() async {
    final provider = Provider.of<TaskProvider>(context, listen: false);
    await provider.updateTask(
      _baseUpdatedTask(location: null, locationName: null),
    );

    setState(() {
      widget.task.location = null;
      widget.task.locationName = null;
    });
  }

  Future<void> _addAttachment() async {
    if (widget.task.id == null) return;

    final picked = await _imageService.pickImageFromGallery();
    if (picked == null) return;

    final url = await _storageService.uploadTaskAttachment(
      widget.task.id!,
      picked.path,
    );
    if (url == null) return;

    final provider = Provider.of<TaskProvider>(context, listen: false);
    await provider.addAttachment(widget.task.id!, url);
  }

  Future<void> _removeAttachment(String url) async {
    if (widget.task.id == null) return;
    final provider = Provider.of<TaskProvider>(context, listen: false);
    await provider.removeAttachment(widget.task.id!, url);
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
        return Colors.blueGrey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final priorityColor = _priorityColor(task.priority);
    final projectProvider = Provider.of<ProjectProvider>(context);
    Project? project;
    if (task.projectId != null) {
      project = projectProvider.projects.firstWhere(
            (p) => p.id == task.projectId,
        orElse: () => Project(id: '', name: '', color: '#FF6F00'),
      );
      if (project.id == '') project = null;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          'Detalhes da Tarefa',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AddEditScreen.routeName,
                arguments: widget.task,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: ListView(
          children: [
            // ======= TÍTULO + PRIORIDADE =======
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 10,
                    height: 70,
                    decoration: BoxDecoration(
                      color: priorityColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Prioridade: ${priorityLabels[task.priority]}',
                          style: TextStyle(
                            color: priorityColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ======= DESCRIÇÃO =======
            Container(
              padding: const EdgeInsets.all(18),
              decoration: _boxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Descrição',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    task.description,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ======= INFORMAÇÕES =======
            Container(
              padding: const EdgeInsets.all(18),
              decoration: _boxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informações',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // NOVO: data de criação
                  _infoRow(
                    icon: Icons.schedule,
                    label: 'Criada',
                    value: _createdAtFormatted,
                  ),

                  if (task.dueDate != null)
                    _infoRow(
                      icon: Icons.event,
                      label: 'Vencimento',
                      value: task.dueDate!
                          .toLocal()
                          .toString()
                          .split(' ')
                          .first,
                    ),
                  if (project != null)
                    _infoRow(
                      icon: Icons.folder,
                      label: 'Projeto',
                      value: project.name!,
                    ),
                  if (task.location != null)
                    _infoRow(
                      icon: Icons.location_on,
                      label: 'Localização',
                      value: task.locationName ??
                          '${task.location!.latitude.toStringAsFixed(5)}, '
                              '${task.location!.longitude.toStringAsFixed(5)}',
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _setMockLocation,
                        icon: const Icon(Icons.my_location, size: 18),
                        label: const Text('Definir localização'),
                      ),
                      const SizedBox(width: 8),
                      if (task.location != null)
                        TextButton(
                          onPressed: _clearLocation,
                          child: const Text('Remover'),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ======= SUBTAREFAS =======
            Container(
              padding: const EdgeInsets.all(18),
              decoration: _boxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Subtarefas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _showAddSubtaskDialog,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Adicionar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_subtasks.isEmpty)
                    const Text(
                      'Nenhuma subtarefa ainda',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    )
                  else
                    ..._subtasks.asMap().entries.map((entry) {
                      final index = entry.key;
                      final subtask = entry.value;
                      return Row(
                        children: [
                          Expanded(
                            child: CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              title: Text(subtask.title),
                              value: subtask.isDone,
                              onChanged: (val) =>
                                  _toggleSubtaskDone(index, val ?? false),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.redAccent),
                            onPressed: () => _deleteSubtask(index),
                          ),
                        ],
                      );
                    }).toList(),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ======= ANEXOS =======
            Container(
              padding: const EdgeInsets.all(18),
              decoration: _boxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Anexos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _addAttachment,
                        icon: const Icon(Icons.attach_file, size: 18),
                        label: const Text('Adicionar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (widget.task.attachments.isEmpty)
                    const Text(
                      'Nenhum anexo ainda',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    )
                  else
                    ...widget.task.attachments.map((url) {
                      return ListTile(
                        leading: const Icon(Icons.insert_drive_file),
                        title: Text(
                          url,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.redAccent),
                          onPressed: () => _removeAttachment(url),
                        ),
                        onTap: () {
                          // futuro: abrir viewer
                        },
                      );
                    }).toList(),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ======= ESTADO: CONCLUÍDA =======
            Container(
              padding: const EdgeInsets.all(18),
              decoration: _boxDecoration(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Concluída',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Switch(
                    value: _isDone,
                    activeColor: Colors.green,
                    onChanged: _toggleDone,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black12.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.blueGrey.shade600),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
