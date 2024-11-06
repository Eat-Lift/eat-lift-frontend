import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ApiUserService{
  final String baseUrl = 'http://10.0.2.2:8000/users';

  Future<Map<String, dynamic>> signin(String username, String email, String password) async {
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
      final decodedData = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedData);
      return {
        "success": true,
        "token": responseData["token"],
        "user": responseData["user"],
      };
    } else {
      final decodedData = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedData);
      List<String> errors = List<String>.from(responseData["errors"]);
      return {
        "success": false,
        "errors": errors,
      };
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200){
      final decodedData = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedData);
      return {
        "success": true,
        "token": responseData["token"],
        "user": responseData["user"],
      }; 
    } else {
      final decodedData = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedData);
      List<String> errors = List<String>.from(responseData["errors"]);
      return {
        "success": false,
        "errors": errors,
      };
    }
  }

  Future<Map<String, dynamic>> googleLogin() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
    final String? token;

    GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
    token = googleAuth.idToken;

    final response = await http.post(
      Uri.parse('$baseUrl/login/google'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'google_token': token,
      }),
    );

    if (response.statusCode == 200){
      final decodedData = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedData);
      return {
        "success": true,
        "token": responseData["token"],
        "user": responseData["user"],
        "signin": false,
      }; 
    }
    else if (response.statusCode == 201){
      final decodedData = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedData);
      return {
        "success": true,
        "token": responseData["token"],
        "user": responseData["user"],
        "signin": true,
      }; 
    } 
    else {
      final decodedData = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedData);
      List<String> errors = List<String>.from(responseData["errors"]);
      return {
        "success": false,
        "errors": errors,
      };
    }
  }

  Future<Map<String, dynamic>?> getUser(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$userId'),
      headers: {"Content-Type": "application/json"},
    );

    if(response.statusCode == 200){
      final decodedData = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedData);
      return {
        "success": true,
        "user": responseData["user"],
      }; 
    }
    else {
      final decodedData = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedData);
      List<String> errors = List<String>.from(responseData["errors"]);
      return {
        "success": false,
        "errors": errors,
      };
    }
  }

  Future<Map<String, dynamic>> updatePersonalInformation(Map<String, dynamic> personalInformation) async {
    final SessionStorage sessionStorage = SessionStorage();
    final userId = await sessionStorage.getUserId();
    final token = await sessionStorage.getAccessToken();

    final response = await http.put(
      Uri.parse('$baseUrl/$userId/editPersonalInformation'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
      body: jsonEncode(personalInformation),
    );

    if(response.statusCode == 200){
      return {
        "success": true,
      };
    }
    else {
      final decodedData = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedData);
      List<String> errors = List<String>.from(responseData["errors"]);
      return {
        "success": false,
        "errors": errors,
      };
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String,dynamic> profileInfo) async {
    final SessionStorage sessionStorage = SessionStorage();
    final userId = await sessionStorage.getUserId();
    final token = await sessionStorage.getAccessToken();

    final response = await http.put(
      Uri.parse('$baseUrl/$userId/editProfile'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
      body: jsonEncode(profileInfo),
    );

    if(response.statusCode == 200){
      return {
        "success": true,
      };
    }
    else {
      final decodedData = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedData);
      List<String> errors = List<String>.from(responseData["errors"]);
      return {
        "success": false,
        "errors": errors,
      };
    }
  }

  Future<Map<String, dynamic>> resetPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reset_password'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'email': email,
      }),
    );

    if(response.statusCode == 200){
      return {
        "success": true,
      };
    }
    else {
      final decodedData = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedData);
      List<String> errors = List<String>.from(responseData["errors"]);
      return {
        "success": false,
        "errors": errors,
      };
    }
  }

  Future<Map<String, dynamic>> newPassword(String code, String password, String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/new_password'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'email': email,
        'reset_code': code,
        'new_password': password,
      }),
    );

    if(response.statusCode == 200){
      return {
        "success": true,
        "messages": ["Contrasenya canviada amb èxit"]
      };
    }
    else {
      final decodedData = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedData);
      List<String> errors = List<String>.from(responseData["errors"]);
      return {
        "success": false,
        "errors": errors,
      };
    }
  }

}
