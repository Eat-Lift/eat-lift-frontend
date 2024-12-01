import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ApiUserService{
  //final String baseUrl = "https://eat-lift-backend.onrender.com/users";
  final String baseUrl = "http://10.0.2.2:8000/users";

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

  Future<Map<String, dynamic>> signout() async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/signout'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
      
    );

    if (response.statusCode == 200){
      return {
        "success": true,
      }; 
    } else {
      return {
        "success": false,
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

  Future<Map<String, dynamic>?> getPersonalInformation(String userId) async {
    final SessionStorage sessionStorage = SessionStorage();
    final userId = await sessionStorage.getUserId();
    final token = await sessionStorage.getAccessToken();

    final response = await http.get(
      Uri.parse('$baseUrl/$userId/getPersonalInformation'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
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

  Future<Map<String, dynamic>> submitCheck(Map<String, dynamic> check) async {
    final SessionStorage sessionStorage = SessionStorage();
    final userId = await sessionStorage.getUserId();
    final token = await sessionStorage.getAccessToken();

    final response = await http.post(
      Uri.parse('$baseUrl/checks/$userId/create'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
      body: jsonEncode(check),
    );

    if(response.statusCode == 200){
      final decodedData = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedData);
      return {
        "success": true,
        "check": responseData,
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

  Future<Map<String, dynamic>> getCheck(String date) async {
    final SessionStorage sessionStorage = SessionStorage();
    final userId = await sessionStorage.getUserId();
    final token = await sessionStorage.getAccessToken();

    final response = await http.post(
      Uri.parse('$baseUrl/checks/$userId'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
      body: jsonEncode({
        "date": date
      }),
    );

    if(response.statusCode == 200){
      final decodedData = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedData);
      return {
        "success": true,
        "check": responseData,
      };
    }
    else if (response.statusCode == 404) {
      return {
        "success": true,
        "check": [],
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

  Future<Map<String, dynamic>> getCheckDates() async {
    final SessionStorage sessionStorage = SessionStorage();
    final userId = await sessionStorage.getUserId();
    final token = await sessionStorage.getAccessToken();

    final response = await http.get(
      Uri.parse('$baseUrl/checks/$userId/dates'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if(response.statusCode == 200){
      final decodedData = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedData);
      return {
        "success": true,
        "dates": responseData,
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

  Future<Map<String, dynamic>> getChecksSummary() async {
    final SessionStorage sessionStorage = SessionStorage();
    final userId = await sessionStorage.getUserId();
    final token = await sessionStorage.getAccessToken();

    final response = await http.get(
      Uri.parse('$baseUrl/checks/$userId/summary'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if(response.statusCode == 200){
      final decodedData = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedData);
      return {
        "success": true,
        "checks": responseData,
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
