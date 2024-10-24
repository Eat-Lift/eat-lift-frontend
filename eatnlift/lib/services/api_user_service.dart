import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiUserService{
  final String baseUrl = 'http://10.0.2.2:8000/users';

  Future<Map<String, dynamic>> signIn(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signin'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      return {
        "success": true,
        "token": responseData["token"],
        "usename": responseData["username"],
        "email": responseData["email"],
        "password": responseData["password"],
      };
    } else {
      final responseData = jsonDecode(response.body);
      return {
        "success": false,
        "usename": responseData["username"],
        "email": responseData["email"],
        "password": responseData["password"],
      };
    }
  }

  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200){
      final responseData = jsonDecode(response.body);
      String token = responseData['token'];

      return token; 
    } else {
      return null;
    }
  }
}
