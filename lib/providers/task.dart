import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uninorte/utils/constants.dart';

class TareasProvider with ChangeNotifier {
  List<dynamic> _tareas = [];
  bool _cargando = false;

  List<dynamic> get tareas => _tareas;
  bool get cargando => _cargando;

  Future<bool> actualizarEstadoTarea(
      Map<String, dynamic> tarea, String nuevoEstado) async {
    final tareaId = tarea['id'];
    final url = Uri.parse('$api_url/tasks/$tareaId');

    // Clona la tarea y actualiza el estado
    final Map<String, dynamic> datosActualizados =
        Map<String, dynamic>.from(tarea);
    datosActualizados['status'] = nuevoEstado;

    // Opcional: asegúrate de enviar los campos que el backend requiere (title, description, status, due_date)
    // Si due_date es null, enviarlo como null o string vacío según espera tu backend.

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
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
}
