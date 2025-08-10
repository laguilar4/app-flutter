import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:uninorte/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  Map<String, dynamic>? _usuario;

  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get usuario => _usuario;

  Future<bool> login(String email, String password) async {
    const apiUrl = '$api_url/login';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        // Guardar usuario en memoria
        _usuario = json['usuario'];

        // Guardar token en SharedPreferences
        if (json['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("token", json['token']);
        }

        _isAuthenticated = true;
        notifyListeners();
        return true;
      } else {
        final json = jsonDecode(response.body);
        print("Error de login: ${json['error']}");
        return false;
      }
    } catch (e) {
      print("Error de conexión: $e");
      return false;
    }
  }

  void logout() {
    _isAuthenticated = false;
    _usuario = null;
    notifyListeners();
  }
}
