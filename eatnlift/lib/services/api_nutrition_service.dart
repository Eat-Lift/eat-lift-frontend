import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_storage.dart';

class ApiNutritionService {
   final String baseUrl = "http://10.0.2.2:8000/nutrition";

  //Food items
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

    Future<Map<String, dynamic>> editFoodItem(Map<String, Object> foodItem, String foodItemId) async {
      final SessionStorage sessionStorage = SessionStorage();
      final token = await sessionStorage.getAccessToken();

      final response = await http.put(
        Uri.parse('$baseUrl/foodItems/$foodItemId/edit'),
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

      if (response.statusCode == 200) {
        final decodedData = utf8.decode(response.bodyBytes);
        final responseData = jsonDecode(decodedData);
        return {
          "success": true,
          "token": responseData["token"],
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

  Future<Map<String, dynamic>> getSuggestions(String query, bool isFoodItem) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final endpoint = isFoodItem ? 'foodItems' : 'recipes';
    final url = Uri.parse('$baseUrl/$endpoint/suggestions/?name=$query');

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      final decodedData = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedData);
      return {
        "success": true,
        "suggestions": List<String>.from(responseData["suggestions"]),
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

  Future<Map<String, dynamic>> getFoodItems(String query) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.get(
      Uri.parse("$baseUrl/foodItems/?name=$query"),
      headers: {
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> foodItemsJson = json.decode(response.body);
      return {
        "success": true,
        "foodItems": foodItemsJson,
      };
    } else {
      return {"success": false, "foodItems": []};
    }
  }

  Future<Map<String, dynamic>> getFoodItemSaved(String foodItemId) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.get(
      Uri.parse("$baseUrl/foodItems/$foodItemId/isSaved"),
      headers: {
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      final decodedData = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedData);
      return {
        "success": true,
        "is_saved": responseData["is_saved"],
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

  Future<Map<String, dynamic>> saveFoodItem(String foodItemId) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.post(
      Uri.parse("$baseUrl/foodItems/$foodItemId/save"),
      headers: {
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 201) {
      return {
        "success": true,
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

  Future<Map<String, dynamic>> unsaveFoodItem(String foodItemId) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.post(
      Uri.parse("$baseUrl/foodItems/$foodItemId/unsave"),
      headers: {
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 204) {
      return {
        "success": true,
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
  
  Future<Map<String, dynamic>> deleteFoodItem(String foodItemId) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.delete(
      Uri.parse("$baseUrl/foodItems/$foodItemId/delete"),
      headers: {
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 204) {
      return {
        "success": true,
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

  // Recipes
   Future<Map<String, dynamic>> createRecipe(Map<String, Object> recipe) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.post(
      Uri.parse('$baseUrl/recipes/create'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
      body: jsonEncode({
        'name': recipe["name"],
        "description": recipe["description"],
        "photo": recipe["photo"],
        "food_items": recipe["food_items"],
      }),
    );

    if (response.statusCode == 201) {
      final decodedData = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedData);
      return {
        "success": true,
        "recipeId": responseData["id"]
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

  Future<Map<String, dynamic>> getRecipe(int recipeId) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.get(
      Uri.parse('$baseUrl/recipes/$recipeId'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    final decodedData = utf8.decode(response.bodyBytes);
    final responseData = jsonDecode(decodedData);
    return {
        "success": response.statusCode == 200,
        "recipe": responseData
    };

  }

  
}