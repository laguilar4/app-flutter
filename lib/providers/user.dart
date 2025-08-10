import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uninorte/utils/constants.dart';

class UsuariosProvider with ChangeNotifier {
  // Lista dinámica que contendrá los usuarios (cada elemento es un Map<String, dynamic>)
  List<dynamic> _usuarios = [];
  bool _cargando = false;

  List<dynamic> get usuarios => _usuarios;
  bool get cargando => _cargando;

  // Método para obtener usuarios desde el backend
  Future<void> fetchUsuarios() async {
    final apiUrl = "$api_url/users";
    String? token = await getToken();
    _cargando = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        // Aquí decodificamos como lista directamente
        final List<dynamic> data = jsonDecode(response.body);

        // Asignamos la lista directamente a _usuarios
        _usuarios = data;
      } else {
        print("⚠️ Error HTTP: ${response.statusCode}");
        _usuarios = [];
      }
    } catch (e) {
      print("❌ Error cargando usuarios: $e");
      _usuarios = [];
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}
