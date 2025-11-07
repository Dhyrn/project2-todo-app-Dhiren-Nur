import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'add_edit_screen.dart';

class DetailScreen extends StatelessWidget {
  static const routeName = '/detail';
  final Task task;

  const DetailScreen({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Tarefa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditScreen(existingTask: task),
                ),
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
            if (task.priority != null) ...[
              Text('Prioridade: ${task.priority}', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                const Text('Concluída: '),
                Switch(
                  value: task.isDone,
                  onChanged: (value) {
                    provider.setTaskDone(task.id!, value);
                  },
                ),
                Switch(
                  value: task.isDone,
                  onChanged: (value) {
                    final provider = Provider.of<TaskProvider>(context, listen: false);
                    provider.setTaskDone(task.id!, value);
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
