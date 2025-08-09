import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uninorte/providers/auth.dart';
import 'package:uninorte/providers/task.dart';
import 'package:uninorte/providers/user.dart';
import 'package:uninorte/screens/user_detail.dart';

class TeacherScreen extends StatefulWidget {
  const TeacherScreen({super.key});

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Cargar usuarios después del montaje
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UsuariosProvider>(context, listen: false).fetchUsuarios();
    });
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 2) {
      // Cuando se selecciona la pestaña Tareas, cargar las tareas del usuario
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final tareasProvider =
          Provider.of<TareasProvider>(context, listen: false);

      final userId = authProvider.usuario?['id'];
      if (userId != null) {
        tareasProvider.fetchTareasPorUsuario(userId);
      }
    }
  }

  Widget _buildTareas() {
    return Consumer2<AuthProvider, TareasProvider>(
      builder: (context, authProvider, tareasProvider, child) {
        if (tareasProvider.cargando) {
          return const Center(child: CircularProgressIndicator());
        }

        final userId = authProvider.usuario?['id'];
        if (userId == null) {
          return const Center(child: Text("Usuario no autenticado"));
        }

        // Filtrar tareas por usuario actual
        final tareasUsuario =
            tareasProvider.tareas.where((t) => t['user_id'] == userId).toList();

        if (tareasUsuario.isEmpty) {
          return const Center(
            child: Text(
              "No tienes tareas asignadas",
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => tareasProvider.fetchTareasPorUsuario(userId),
          child: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: tareasUsuario.length,
            itemBuilder: (context, index) {
              final tarea = tareasUsuario[index];

              return TaskCard(
                tarea: tarea,
                onStatusChanged: (newStatus) async {
                  final exito = await tareasProvider.actualizarEstadoTarea(
                      tarea, newStatus);
                  if (exito) {
                    // Actualizar estado local para refrescar UI
                    setState(() {
                      tarea['status'] = newStatus;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Error al actualizar el estado')),
                    );
                  }
                },
                onDelete: () async {
                  final exito = await tareasProvider.eliminarTarea(tarea['id']);
                  if (exito) {
                    setState(() {
                      tareasProvider.tareas.remove(tarea);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Tarea eliminada correctamente')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Error al eliminar la tarea')),
                    );
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    if (_currentIndex == 0) {
      return const Center(
        child: Text(
          "Bienvenido al Sistema Universitario",
          style: TextStyle(fontSize: 20),
        ),
      );
    } else if (_currentIndex == 1) {
      return _buildTareas();
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel Universitario"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF004e92), Color(0xFF000428)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              authProvider.logout();
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: _buildContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF004e92),
        unselectedItemColor: Colors.grey,
        onTap: _onTabChanged, // Usamos la función que maneja carga de tareas
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Inicio",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: "Tareas",
          ),
        ],
      ),
    );
  }
}
