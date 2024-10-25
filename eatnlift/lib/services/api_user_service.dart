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
        "successful": true,
        "token": responseData["token"],
      };
    } else {
      final responseData = jsonDecode(response.body);
      List<String> errors = [];
      if (responseData["username"] != null) {
        errors.addAll(List<String>.from(responseData["username"]));
      }
      if (responseData["email"] != null) {
        errors.addAll(List<String>.from(responseData["email"]));
      }
      if (responseData["password"] != null) {
        errors.addAll(List<String>.from(responseData["password"]));
      }
      return {
        "successful": false,
        "errors": errors,
      };
    }
  }

  Future<Map<String, dynamic>> logIn(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200){
      final responseData = jsonDecode(response.body);
      return {
        "success": true,
        "token": responseData["token"],
      }; 
    } else {
      final responseData = jsonDecode(response.body);
      List<String> errors = [];
      if (responseData["detail"] != null) {
        errors.add(responseData["detail"]);
      }
      if (responseData["error"] != null) {
        errors.add(responseData["error"]);
      }
      return {
        "successful": false,
        "errors": errors,
      };
    }
  }
}
