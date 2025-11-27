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
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final priorityColor = _priorityColor(task.priority);

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
                  // Indicador de prioridade
                  Container(
                    width: 10,
                    height: 70,
                    decoration: BoxDecoration(
                      color: priorityColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Título + estado
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
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ======= DATAS E CATEGORIA =======
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

                  if (task.dueDate != null)
                    _infoRow(
                      icon: Icons.event,
                      label: 'Vencimento',
                      value: task.dueDate!.toLocal().toString().split(' ')[0],
                    ),

                  if (task.category != null)
                    _infoRow(
                      icon: Icons.folder,
                      label: 'Categoria',
                      value: task.category!,
                    ),
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
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
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

  // === Widgets auxiliares para organização ===

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