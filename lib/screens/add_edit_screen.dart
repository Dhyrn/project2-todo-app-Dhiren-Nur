import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';
import '../models/subtask.dart';
import '../providers/task_provider.dart';
import '../providers/project_provider.dart';

class AddEditScreen extends StatefulWidget {
  static const routeName = '/add-edit';
  final Task? existingTask;
  final String? initialProjectId;

  const AddEditScreen({
    Key? key,
    this.existingTask,
    this.initialProjectId,
  }) : super(key: key);

  @override
  _AddEditScreenState createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _title;
  late String _description;
  DateTime? _dueDate;
  String? _selectedProjectId;
  late Priority _priority;

  // ======= CAMPOS QUE FALTAVAM =======
  GeoPoint? _location;
  String? _locationName;
  bool _locationReminderEnabled = false;
  bool _isOutdoor = false;
  List<Subtask> _subtasks = [];
  List<String> _attachments = [];

  Task? _taskToEdit;
  bool _didLoadArgs = false;
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoadArgs) {
      final args = ModalRoute.of(context)?.settings.arguments;
      _taskToEdit = args is Task ? args : widget.existingTask;

      _title = _taskToEdit?.title ?? '';
      _description = _taskToEdit?.description ?? '';
      _dueDate = _taskToEdit?.dueDate;
      _selectedProjectId = _taskToEdit?.projectId ?? widget.initialProjectId;
      _priority = _taskToEdit?.priority ?? Priority.media;

      // ======= LOAD EXTRA =======
      _location = _taskToEdit?.location;
      _locationName = _taskToEdit?.locationName;
      _locationReminderEnabled = _taskToEdit?.locationReminderEnabled ?? false;
      _isOutdoor = _taskToEdit?.isOutdoor ?? false;
      _subtasks = List.from(_taskToEdit?.subtasks ?? []);
      _attachments = List.from(_taskToEdit?.attachments ?? []);

      _didLoadArgs = true;
    }
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: _dueDate ?? DateTime.now(),
    );
    if (selected != null) setState(() => _dueDate = selected);
  }

  // ======= LOCALIZAÇÃO MOCK (igual ao DetailScreen) =======
  Future<void> _setMockLocation() async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Definir localização como atual'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar')),
        ],
      ),
    );

    if (ok != true) return;

    setState(() {
      _location = const GeoPoint(38.7223, -9.1393);
      _locationName = controller.text.trim().isEmpty ? 'Localização' : controller.text.trim();
    });
  }

  void _clearLocation() {
    setState(() {
      _location = null;
      _locationName = null;
      _locationReminderEnabled = false;
    });
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final isEditing = _taskToEdit != null;

    final task = Task(
      id: _taskToEdit?.id,
      title: _title,
      description: _description,
      dueDate: _dueDate,
      projectId: _selectedProjectId,
      priority: _priority,
      isDone: _taskToEdit?.isDone ?? false,
      createdAt: _taskToEdit?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      subtasks: _subtasks,
      attachments: _attachments,
      location: _location,
      locationName: _locationName,
      locationReminderEnabled: _locationReminderEnabled,
      isOutdoor: _isOutdoor,
    );

    setState(() => _isSaving = true);
    final provider = Provider.of<TaskProvider>(context, listen: false);

    try {
      isEditing ? await provider.updateTask(task) : await provider.addTask(task);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _input(String label) => InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), labelText: label);

  @override
  Widget build(BuildContext context) {
    final projects = Provider.of<ProjectProvider>(context).projects;

    return Scaffold(
      appBar: AppBar(title: Text(_taskToEdit == null ? 'Nova tarefa' : 'Editar tarefa')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(initialValue: _title, decoration: _input('Título'), onSaved: (v) => _title = v!.trim()),
              const SizedBox(height: 12),
              TextFormField(initialValue: _description, decoration: _input('Descrição'), maxLines: 3, onSaved: (v) => _description = v!.trim()),
              const SizedBox(height: 12),
              GestureDetector(onTap: _pickDate, child: AbsorbPointer(child: TextFormField(decoration: _input('Data'), controller: TextEditingController(text: _dueDate == null ? '' : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}')))),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(value: _selectedProjectId, decoration: _input('Projeto'), items: [const DropdownMenuItem(value: null, child: Text('Sem projeto')), ...projects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))] , onChanged: (v) => setState(() => _selectedProjectId = v)),
              const SizedBox(height: 12),

              // ======= LOCALIZAÇÃO =======
              SwitchListTile(title: const Text('Tarefa exterior'), value: _isOutdoor, onChanged: (v) => setState(() => _isOutdoor = v)),
              if (_location != null)
                SwitchListTile(title: const Text('Lembrete por localização'), value: _locationReminderEnabled, onChanged: (v) => setState(() => _locationReminderEnabled = v)),

              Row(children: [ElevatedButton(onPressed: _setMockLocation, child: const Text('Definir localização como atual')), const SizedBox(width: 8), if (_location != null) TextButton(onPressed: _clearLocation, child: const Text('Remover'))]),

              const SizedBox(height: 20),
              ElevatedButton(onPressed: _isSaving ? null : _saveForm, child: _isSaving ? const CircularProgressIndicator() : const Text('Guardar')),
            ],
          ),
        ),
      ),
    );
  }
}
