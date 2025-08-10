import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uninorte/utils/constants.dart';

class TareasProvider with ChangeNotifier {
  List<dynamic> _tareas = [];
  bool _cargando = false;

  List<dynamic> get tareas => _tareas;
  bool get cargando => _cargando;

  Future<bool> eliminarTarea(dynamic tareaId) async {
    try {
      String? token = await getToken();
      final response = await http.delete(
        Uri.parse('$api_url/tasks/$tareaId'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        // Eliminar localmente
        tareas.removeWhere((t) => t['id'] == tareaId);
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error eliminando tarea: $e');
      return false;
    }
  }

  Future<bool> actualizarEstadoTarea(
      Map<String, dynamic> tarea, String nuevoEstado) async {
    final tareaId = tarea['id'];
    String? token = await getToken();
    final url = Uri.parse('$api_url/tasks/$tareaId');

    final Map<String, dynamic> datosActualizados =
        Map<String, dynamic>.from(tarea);
    datosActualizados['status'] = nuevoEstado;

    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(datosActualizados),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Error actualizando estado: ${response.statusCode}');
      print('Respuesta: ${response.body}');
      return false;
    }
  }

  Future<void> fetchTareasPorUsuario(int userId) async {
    String? token = await getToken();
    final apiUrl = "$api_url/tasks/$userId";
    _cargando = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(apiUrl));
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);

        if (jsonList.isNotEmpty) {
          _tareas = List<Map<String, dynamic>>.from(jsonList);
        } else {
          _tareas = [];
        }
      } else if (response.statusCode == 404) {
        print('No se encontraron tareas para este usuario');
        _tareas = [];
      } else {
        print('Error en la respuesta HTTP: ${response.statusCode}');
        _tareas = [];
      }
    } catch (e) {
      print("Error cargando tareas: $e");
      _tareas = [];
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  // Nueva función para crear/guardar una tarea asociada a un usuario
  Future<bool> crearTarea(Map<String, dynamic> nuevaTarea) async {
    String? token = await getToken();
    final url = Uri.parse('$api_url/tasks');

    // Prepara el mapa con los datos que espera el backend
    final Map<String, dynamic> tareaParaEnviar = {
      'title': nuevaTarea['title'],
      'description': nuevaTarea['description'],
      'status': nuevaTarea['status'],
      'user_id': nuevaTarea['user_id'], // El id del usuario al que pertenece
      // agrega más campos si los necesitas (due_date, etc.)
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(tareaParaEnviar),
      );

      if (response.statusCode == 201) {
        // Si se crea correctamente, agrega localmente y notifica
        final tareaCreada = jsonDecode(response.body);
        _tareas.add(tareaCreada);
        notifyListeners();
        return true;
      } else {
        print('Error creando tarea: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Excepción creando tarea: $e');
      return false;
    }
  }
}
