import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_storage.dart';

class ApiNutritionService {
   final String baseUrl = "https://eat-lift-backend.onrender.com/nutrition";
   //final String baseUrl = "http://192.168.1.136:8000/nutrition";

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

    Future<Map<String, dynamic>> getSavedFoodItems() async {
      final SessionStorage sessionStorage = SessionStorage();
      final token = await sessionStorage.getAccessToken();

      final response = await http.get(
        Uri.parse("$baseUrl/foodItems/saved"),
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
        "picture": recipe["picture"],
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

  Future<Map<String, dynamic>> editRecipe(Map<String, dynamic> recipe, String recipeId) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.put(
      Uri.parse('$baseUrl/recipes/$recipeId/edit'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
      body: jsonEncode({
        'name': recipe["name"],
        "description": recipe["description"],
        "picture": recipe["picture"],
        "food_items": recipe["food_items"],
      }),
    );

    if (response.statusCode == 200) {
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

  Future<Map<String, dynamic>> deleteRecipe(String recipeId) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.delete(
      Uri.parse("$baseUrl/recipes/$recipeId/delete"),
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

  Future<Map<String, dynamic>> getRecipes(String query) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.get(
      Uri.parse("$baseUrl/recipes/?name=$query"),
      headers: {
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> recipesJson = json.decode(response.body);
      return {
        "success": true,
        "recipes": recipesJson,
      };
    } else {
      return {"success": false, "recipes": []};
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

  Future<Map<String, dynamic>> getRecipeSaved(String recipeId) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.get(
      Uri.parse("$baseUrl/recipes/$recipeId/isSaved"),
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

  Future<Map<String, dynamic>> saveRecipe(String recipeId) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.post(
      Uri.parse("$baseUrl/recipes/$recipeId/save"),
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

  Future<Map<String, dynamic>> unsaveRecipe(String recipeId) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.post(
      Uri.parse("$baseUrl/recipes/$recipeId/unsave"),
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

  Future<Map<String, dynamic>> getNutritionalPlan(String userId) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.get(
      Uri.parse("$baseUrl/nutritionalPlans/$userId"),
      headers: {
        "Authorization": "Token $token",
        "Content-Type": "application/json", 
      },
    );

    if (response.statusCode == 200) {
      final decodedData = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedData);
      return {
        "success": true,
        "recipes": responseData,
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

  Future<Map<String, dynamic>> editNutritionalPlan(String userId, List<Map<String, dynamic>> recipes) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.post(
      Uri.parse("$baseUrl/nutritionalPlans/$userId/edit"),
      headers: {
        "Authorization": "Token $token",
        "Content-Type": "application/json", 
      },
      body: jsonEncode({
        'recipes': recipes,
      }),
    );

    if (response.statusCode == 200) {
      final decodedData = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedData);
      return {
        "success": true,
        "recipes": responseData["recipes"],
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

  Future<Map<String, dynamic>> getMeals(String userId, String date) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.post(
      Uri.parse("$baseUrl/meals/$userId"),
      headers: {
        "Authorization": "Token $token",
        "Content-Type": "application/json", 
      },
      body: jsonEncode({
        'date': date,
      }),
    );

    if (response.statusCode == 200) {
      final decodedData = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedData);
      return {
        "success": true,
        "meals": responseData,
      };
    } 
    else if (response.statusCode == 404){
      return {
        "success": true,
        "meals": []
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

  Future<Map<String, dynamic>> editMeal(String userId, String date, String mealType, List<Map<String, dynamic>> foodItems) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.post(
      Uri.parse("$baseUrl/meals/$userId/edit"),
      headers: {
        "Authorization": "Token $token",
        "Content-Type": "application/json", 
      },
      body: jsonEncode({
        'date': date,
        'meal_type': mealType,
        'food_items': foodItems
      }),
    );

    if (response.statusCode == 200) {
      final decodedData = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedData);
      return {
        "success": true,
        "meal": responseData,
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

  Future<Map<String, dynamic>> getMealDates(String userId) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.get(
      Uri.parse("$baseUrl/meals/$userId/dates"),
      headers: {
        "Authorization": "Token $token",
        "Content-Type": "application/json", 
      }
    );

    if (response.statusCode == 200) {
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
}