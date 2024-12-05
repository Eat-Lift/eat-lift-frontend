import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_storage.dart';

class ApiTrainingService {
  final String baseUrl = "http://10.0.2.2:8000/training";
  
  // Exercises
  Future<Map<String, dynamic>> createExercise(Map<String, Object> exercise) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.post(
      Uri.parse('$baseUrl/exercises/create'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
      body: jsonEncode({
        'name': exercise["name"],
        'description': exercise["description"],
        'picture': exercise["picture"],
        'trained_muscles': exercise["trained_muscles"],
      }),
    );

    if (response.statusCode == 201) {
      final decodedData = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedData);
      return {
        "success": true,
        "exercise": responseData["id"]
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

    Future<Map<String, dynamic>> editExercise(Map<String, Object> exercise, String exerciseId) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.put(
      Uri.parse('$baseUrl/exercises/$exercise/edit'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
      body: jsonEncode({
        'name': exercise["name"],
        'description': exercise["description"],
        'picture': exercise["picture"],
        'trained_muscles': exercise["trained_muscles"],
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

  Future<Map<String, dynamic>> getExercises(String query) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.get(
      Uri.parse("$baseUrl/exercises/?name=$query"),
      headers: {
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> exercises = json.decode(response.body);
      return {
        "success": true,
        "exercises": exercises,
      };
    } else {
      return {"success": false, "exercises": []};
    }
  }

  Future<Map<String, dynamic>> getExercise(String exerciseId) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.get(
      Uri.parse("$baseUrl/exercises/$exerciseId"),
      headers: {
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> exercise = json.decode(response.body);
      return {
        "success": true,
        "exercise": exercise,
      };
    } else {
      return {"success": false, "exercise": []};
    }
  }

  Future<Map<String, dynamic>> getExerciseSaved(String exerciseId) async {
  final SessionStorage sessionStorage = SessionStorage();
  final token = await sessionStorage.getAccessToken();

  final response = await http.get(
    Uri.parse("$baseUrl/exercises/$exerciseId/isSaved"),
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

Future<Map<String, dynamic>> saveExercise(String exerciseId) async {
  final SessionStorage sessionStorage = SessionStorage();
  final token = await sessionStorage.getAccessToken();

  final response = await http.post(
    Uri.parse("$baseUrl/exercises/$exerciseId/save"),
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

Future<Map<String, dynamic>> unsaveExercise(String exerciseId) async {
  final SessionStorage sessionStorage = SessionStorage();
  final token = await sessionStorage.getAccessToken();

  final response = await http.post(
    Uri.parse("$baseUrl/exercises/$exerciseId/unsave"),
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

Future<Map<String, dynamic>> deleteExercise(String exerciseId) async {
  final SessionStorage sessionStorage = SessionStorage();
  final token = await sessionStorage.getAccessToken();

  final response = await http.delete(
    Uri.parse("$baseUrl/exercises/$exerciseId/delete"),
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


}