import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _isDone = widget.task.isDone;
  }

  void _toggleDone(bool value) async {
    setState(() {
      _isDone = value;
    });
    final provider = Provider.of<TaskProvider>(context, listen: false);
    await provider.setTaskDone(widget.task.id!, value);
    // Aqui, se quiser, você pode mostrar um feedback visual/snackbar
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Tarefa'),
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
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(task.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(task.description, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            if (task.dueDate != null) ...[
              Text('Vencimento: ${task.dueDate!.toLocal().toString().split(' ')[0]}',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
            ],
            if (task.category != null) ...[
              Text('Categoria: ${task.category}', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
            ],
            Text(
              'Prioridade: ${priorityLabels[task.priority]}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Concluída: '),
                Switch(
                  value: _isDone,
                  onChanged: (value) => _toggleDone(value),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
