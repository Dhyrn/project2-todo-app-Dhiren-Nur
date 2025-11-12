import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class AddEditScreen extends StatefulWidget {
  static const routeName = '/add-edit';
  final Task? existingTask;

  const AddEditScreen({Key? key, this.existingTask}) : super(key: key);

  @override
  _AddEditScreenState createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _title;
  late String _description;
  DateTime? _dueDate;
  String? _category;
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
      _category = _taskToEdit?.category;
      _priority = _taskToEdit?.priority ?? Priority.media;
      _didLoadArgs = true;
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
      category: _category,
      priority: _priority,
      isDone: _taskToEdit?.isDone ?? false,
      createdAt: _taskToEdit?.createdAt,
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
        SnackBar(content: Text('Erro ao salvar: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _taskToEdit != null;

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
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Título'),
                textInputAction: TextInputAction.next,
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
              const SizedBox(height: 12),

              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Descrição'),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Preencha a descrição';
                  }
                  return null;
                },
                onSaved: (value) => _description = value!.trim(),
              ),
              const SizedBox(height: 12),

              InputDatePickerFormField(
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                initialDate: _dueDate ?? DateTime.now(),
                onDateSubmitted: (date) => _dueDate = date,
                onDateSaved: (date) => _dueDate = date,
              ),
              const SizedBox(height: 12),

              TextFormField(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Categoria'),
                onSaved: (value) => _category = value?.trim(),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<Priority>(
                value: _priority,
                items: Priority.values.map((p) {
                  return DropdownMenuItem(
                    value: p,
                    child: Text(priorityLabels[p]!),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Prioridade'),
                onChanged: (newP) => setState(() => _priority = newP!),
                validator: (p) => p == null ? 'Selecione a prioridade' : null,
                onSaved: (p) => _priority = p!,
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveForm,
                    child: _isSaving
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
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
