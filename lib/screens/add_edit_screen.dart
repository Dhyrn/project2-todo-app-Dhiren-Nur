import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/project.dart';
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
  Task? _taskToEdit;
  bool _didLoadArgs = false;
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoadArgs) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Task) {
        _taskToEdit = args;
      } else {
        _taskToEdit = widget.existingTask;
      }

      _title = _taskToEdit?.title ?? '';
      _description = _taskToEdit?.description ?? '';
      _dueDate = _taskToEdit?.dueDate;
      _selectedProjectId =
          _taskToEdit?.projectId ?? widget.initialProjectId;
      _priority = _taskToEdit?.priority ?? Priority.media;

      _didLoadArgs = true;
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: _dueDate ?? now,
    );

    if (selected != null) {
      setState(() => _dueDate = selected);
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final isEditing = _taskToEdit != null;
    final newTask = Task(
      id: _taskToEdit?.id,
      title: _title,
      description: _description,
      dueDate: _dueDate,
      projectId: _selectedProjectId,
      priority: _priority,
      isDone: _taskToEdit?.isDone ?? false,
      createdAt: _taskToEdit?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setState(() => _isSaving = true);

    final provider = Provider.of<TaskProvider>(context, listen: false);

    try {
      if (isEditing) {
        await provider.updateTask(newTask);
      } else {
        await provider.addTask(newTask);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding:
      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    );
  }

  Color _priorityColor(Priority p) {
    switch (p) {
      case Priority.critico:
        return Colors.red;
      case Priority.alta:
        return Colors.orange;
      case Priority.media:
        return Colors.amber;
      case Priority.baixa:
        return Colors.green;
      case Priority.deixaPaOutroDia:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _taskToEdit != null;
    final projectProvider = Provider.of<ProjectProvider>(context);
    final List<Project> projects = projectProvider.projects;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Tarefa' : 'Adicionar Tarefa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Título
              TextFormField(
                initialValue: _title,
                decoration: _inputStyle('Título'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Preencha o título';
                  }
                  if (value.trim().length < 3) {
                    return 'O título precisa ter pelo menos 3 caracteres';
                  }
                  return null;
                },
                onSaved: (value) => _title = value!.trim(),
              ),
              const SizedBox(height: 16),

              // Descrição
              TextFormField(
                initialValue: _description,
                decoration: _inputStyle('Descrição'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Preencha a descrição';
                  }
                  return null;
                },
                onSaved: (value) => _description = value!.trim(),
              ),
              const SizedBox(height: 16),

              // Data
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: _inputStyle('Data de vencimento'),
                    controller: TextEditingController(
                      text: _dueDate == null
                          ? ''
                          : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Projeto (dropdown)
              DropdownButtonFormField<String>(
                decoration: _inputStyle('Projeto'),
                value: _selectedProjectId,
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Sem projeto'),
                  ),
                  ...projects.map(
                        (p) => DropdownMenuItem<String>(
                      value: p.id,
                      child: Text(p.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedProjectId = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Prioridade
              DropdownButtonFormField<Priority>(
                value: _priority,
                decoration: _inputStyle('Prioridade'),
                items: Priority.values.map((p) {
                  return DropdownMenuItem(
                    value: p,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 6,
                          backgroundColor: _priorityColor(p),
                        ),
                        const SizedBox(width: 8),
                        Text(priorityLabels[p]!),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (newP) => setState(() => _priority = newP!),
                validator: (p) =>
                p == null ? 'Selecione a prioridade' : null,
                onSaved: (p) => _priority = p!,
              ),
              const SizedBox(height: 20),

              // Botões
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveForm,
                    child: _isSaving
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                      CircularProgressIndicator(strokeWidth: 2),
                    )
                        : Text(isEditing ? 'Atualizar' : 'Salvar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
