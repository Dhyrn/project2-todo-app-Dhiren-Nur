import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/weather_widget.dart';
import './add_edit_screen.dart';
import './detail_screen.dart';

class ListScreen extends StatelessWidget {
  static const routeName = '/list';

  const ListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarefas'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: WeatherWidget(),
          ),
          Expanded(
            child: Builder(builder: (context) {
              if (taskProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (taskProvider.error != null) {
                return Center(child: Text('Erro: ${taskProvider.error}'));
              }
              final tasks = taskProvider.tasks;
              if (tasks.isEmpty) {
                return const Center(child: Text('Nenhuma tarefa ainda'));
              }
              return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (ctx, i) {
                  final task = tasks[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      leading: Icon(
                        task.isDone ? Icons.check_box : Icons.check_box_outline_blank,
                        color: task.isDone ? Colors.green : null,
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      subtitle: Text(task.description),
                      trailing: IconButton(
                        icon: const Icon(Icons.more_horiz),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (_) => Wrap(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.edit),
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
                                  leading: const Icon(Icons.delete),
                                  title: const Text('Excluir'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _confirmDelete(context, task.id!);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DetailScreen(task: task)),
                        );
                      },
                      onLongPress: () => _confirmDelete(context, task.id!),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddEditScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir tarefa?'),
        content: const Text('Deseja realmente excluir esta tarefa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<TaskProvider>(context, listen: false);
              provider.deleteTask(id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
