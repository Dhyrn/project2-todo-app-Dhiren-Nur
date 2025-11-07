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

  // Campos do formulário
  late String _title;
  late String _description;
  DateTime? _dueDate;
  String? _category;
  String? _priority;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    _title = task?.title ?? '';
    _description = task?.description ?? '';
    _dueDate = task?.dueDate;
    _category = task?.category;
    _priority = task?.priority;
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final isEditing = widget.existingTask != null;
    final newTask = Task(
      id: widget.existingTask?.id,
      title: _title,
      description: _description,
      dueDate: _dueDate,
      category: _category,
      priority: _priority,
      isDone: widget.existingTask?.isDone ?? false,
      createdAt: widget.existingTask?.createdAt,
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
    final isEditing = widget.existingTask != null;

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
                    return 'Informe o título';
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
                    return 'Informe a descrição';
                  }
                  return null;
                },
                onSaved: (value) => _description = value!.trim(),
              ),
              const SizedBox(height: 12),

              // Data de vencimento opcional
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

              TextFormField(
                initialValue: _priority,
                decoration: const InputDecoration(labelText: 'Prioridade'),
                onSaved: (value) => _priority = value?.trim(),
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
