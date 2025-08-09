import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uninorte/providers/task.dart';

class UserDetailScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const UserDetailScreen({super.key, required this.usuario});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tareasProvider =
          Provider.of<TareasProvider>(context, listen: false);
      final userId = widget.usuario['id'];
      if (userId != null) {
        tareasProvider.fetchTareasPorUsuario(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tareasProvider = Provider.of<TareasProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.usuario['nombre'] ?? 'Usuario'),
        backgroundColor: const Color(0xFF004e92),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${widget.usuario['email'] ?? 'N/A'}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Rol: ${widget.usuario['role'] ?? 'N/A'}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            const Text(
              'Tareas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: tareasProvider.cargando
                  ? const Center(child: CircularProgressIndicator())
                  : tareasProvider.tareas.isEmpty
                      ? const Center(
                          child: Text(
                          'No hay tareas asignadas',
                          style: TextStyle(fontSize: 16),
                        ))
                      : ListView.builder(
                          itemCount: tareasProvider.tareas.length,
                          itemBuilder: (context, index) {
                            final tarea = tareasProvider.tareas[index];
                            if (tarea is Map<String, dynamic>) {
                              return TaskCard(
                                tarea: tarea,
                                onStatusChanged: (newStatus) async {
                                  final exito = await tareasProvider
                                      .actualizarEstadoTarea(tarea, newStatus);
                                  if (exito) {
                                    setState(() {
                                      tarea['status'] = newStatus;
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Error al actualizar el estado')),
                                    );
                                  }
                                },
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskCard extends StatefulWidget {
  final Map<String, dynamic> tarea;
  final Future<void> Function(String) onStatusChanged;

  const TaskCard(
      {super.key, required this.tarea, required this.onStatusChanged});

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  late String _currentStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.tarea['status']?.toString() ?? 'pendiente';
  }

  Future<void> _handleStatusChanged(String newStatus) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    await widget.onStatusChanged(newStatus);

    setState(() {
      _currentStatus = newStatus;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.tarea['title'] ?? 'Sin título',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              widget.tarea['description'] ?? '',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusIcon(status: _currentStatus),
                _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : DropdownButton<String>(
                        value: _currentStatus,
                        items: const [
                          DropdownMenuItem(
                              value: 'pendiente', child: Text('Pendiente')),
                          DropdownMenuItem(
                              value: 'en_progreso', child: Text('En progreso')),
                          DropdownMenuItem(
                              value: 'completada', child: Text('Completada')),
                        ],
                        onChanged: (value) {
                          if (value != null && value != _currentStatus) {
                            _handleStatusChanged(value);
                          }
                        },
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StatusIcon extends StatelessWidget {
  final String status;

  const StatusIcon({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (status) {
      case 'completada':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'en_progreso':
        icon = Icons.timelapse;
        color = Colors.orange;
        break;
      case 'pendiente':
      default:
        icon = Icons.pending;
        color = Colors.grey;
    }

    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 6),
        Text(
          status.replaceAll('_', ' ').toUpperCase(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
