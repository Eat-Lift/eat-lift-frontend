// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class ApiService {
//   final String baseUrl = 'http://localhost:8000';

//   Future<Map<String, dynamic>?> login(String email, String password) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/register'),
//       body: {
//         'email': email,
//         'password': password,
//       },
//     );

//     if (response.statusCode == 200){
//       return jsonDecode(response.body);
//     } else {
//       return null;
//     }
//   }
// }
