import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_storage.dart';

class ApiNutritionService {
   final String baseUrl = "http://10.0.2.2:8000/nutrition";

   Future<Map<String, dynamic>> createFoodItem(Map<String, Object> foodItem) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.post(
      Uri.parse('$baseUrl/foodItems/create'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
      body: jsonEncode({
        'name': foodItem["name"],
        'calories': foodItem["calories"],
        'proteins': foodItem["proteins"],
        'fats': foodItem["fats"],
        'carbohydrates': foodItem["carbohydrates"],
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

}