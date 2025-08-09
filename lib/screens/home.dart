import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uninorte/providers/auth.dart';
import 'package:uninorte/providers/task.dart';
import 'package:uninorte/providers/user.dart';
import 'package:uninorte/screens/user_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Cargar usuarios después del montaje
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UsuariosProvider>(context, listen: false).fetchUsuarios();
    });
  }

  Widget _buildUsuarios() {
    return Consumer<UsuariosProvider>(
      builder: (context, usuariosProvider, child) {
        if (usuariosProvider.cargando) {
          return const Center(child: CircularProgressIndicator());
        }
        if (usuariosProvider.usuarios.isEmpty) {
          return const Center(child: Text("No hay usuarios disponibles"));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: usuariosProvider.usuarios.length,
          itemBuilder: (context, index) {
            final usuario =
                usuariosProvider.usuarios[index] as Map<String, dynamic>;

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF004e92),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(usuario['nombre'] ?? 'Sin nombre'),
                subtitle: Text(usuario['email'] ?? ''),
                trailing: Chip(
                  label: Text(usuario['role'] ?? 'N/A'),
                  backgroundColor: Colors.blue.shade100,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider(
                        create: (_) => TareasProvider(),
                        child: UserDetailScreen(usuario: usuario),
                      ),
                    ),
                  );
                },
              ),
            );
          },
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
      return _buildUsuarios();
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
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Inicio",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Usuarios",
          ),
        ],
      ),
    );
  }
}
