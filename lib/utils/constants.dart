import 'package:shared_preferences/shared_preferences.dart';

const api_url = "http://54.147.36.38:8080/api";

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("token");
}
