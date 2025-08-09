import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uninorte/utils/constants.dart';

class TareasProvider with ChangeNotifier {
  List<dynamic> _tareas = [];
  bool _cargando = false;

  List<dynamic> get tareas => _tareas;
  bool get cargando => _cargando;

  Future<void> fetchTareasPorUsuario(int userId) async {
    final apiUrl = "$api_url/users/$userId/tasks";
    _cargando = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        if (json['tareas'] != null && json['tareas'] is List) {
          _tareas = json['tareas'];
        } else {
          _tareas = [];
        }
      } else {
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
