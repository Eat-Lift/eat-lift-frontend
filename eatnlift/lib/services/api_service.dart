import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://localhost:8000';

  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
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
