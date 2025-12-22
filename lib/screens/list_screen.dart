import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/weather_widget.dart';
import './add_edit_screen.dart';
import './detail_screen.dart';
import './profile_screen.dart';


class ListScreen extends StatelessWidget {
  static const routeName = '/list';

  const ListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          'Tarefas',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
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
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: WeatherWidget(),
          ),

          Expanded(
            child: Builder(
              builder: (context) {
                if (taskProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (taskProvider.error != null) {
                  return Center(
                    child: Text(
                      'Erro: ${taskProvider.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final tasks = List<Task>.from(taskProvider.tasks)
                  ..sort((a, b) => a.priority.index.compareTo(b.priority.index));

                if (tasks.isEmpty) {
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

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: tasks.length,
                  itemBuilder: (ctx, i) {
                    final task = tasks[i];
                    final priorityColor = _priorityColor(task.priority);

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => DetailScreen(task: task)),
                          );
                        },
                        onLongPress: () => _confirmDelete(context, task.id!),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 70,
                              decoration: BoxDecoration(
                                color: priorityColor,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(14),
                                  bottomLeft: Radius.circular(14),
                                ),
                              ),
                            ),

                            Expanded(
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),

                                leading: InkWell(
                                  borderRadius: BorderRadius.circular(30),
                                  onTap: () async {
                                    final provider = Provider.of<TaskProvider>(context, listen: false);

                                    final updatedTask = Task(
                                      id: task.id,
                                      title: task.title,
                                      description: task.description,
                                      dueDate: task.dueDate,
                                      priority: task.priority,
                                      category: task.category,
                                      isDone: !task.isDone, // inverte estado
                                      createdAt: task.createdAt,
                                      updatedAt: DateTime.now(),
                                    );

                                    await provider.updateTask(updatedTask);
                                  },
                                  child: Icon(
                                    task.isDone ? Icons.check_circle : Icons.circle_outlined,
                                    color: task.isDone ? Colors.green : Colors.black45,
                                    size: 28,
                                  ),
                                ),

                                title: Text(
                                  '${task.title}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    decoration: task.isDone
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),

                                subtitle: Text(
                                  task.description,
                                  style: const TextStyle(color: Colors.black54),
                                ),

                                trailing: IconButton(
                                  icon: const Icon(Icons.more_vert, color: Colors.black54),
                                  onPressed: () {
                                    _showOptions(context, task);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddEditScreen()),
          );
        },
        child: const Icon(Icons.add, size: 28),
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
      default:
        return Colors.grey;
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
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