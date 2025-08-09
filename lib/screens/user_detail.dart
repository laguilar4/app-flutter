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
    // Esperamos a que se monte el widget para llamar al provider
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
            Text('Email: ${widget.usuario['email'] ?? 'N/A'}'),
            const SizedBox(height: 10),
            Text('Rol: ${widget.usuario['role'] ?? 'N/A'}'),
            const SizedBox(height: 20),
            const Text(
              'Tareas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: tareasProvider.cargando
                  ? const Center(child: CircularProgressIndicator())
                  : tareasProvider.tareas.isEmpty
                      ? const Center(child: Text('No hay tareas asignadas'))
                      : ListView.builder(
                          itemCount: tareasProvider.tareas.length,
                          itemBuilder: (context, index) {
                            final tarea = tareasProvider.tareas[index];
                            // Aseguramos que tarea sea Map<String, dynamic>
                            if (tarea is Map<String, dynamic>) {
                              return ListTile(
                                title: Text(tarea['title'] ?? 'Sin título'),
                                subtitle: Text(tarea['description'] ?? ''),
                                trailing: (tarea['completada'] == true)
                                    ? const Icon(Icons.check_circle,
                                        color: Colors.green)
                                    : const Icon(Icons.pending,
                                        color: Colors.orange),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
