import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_storage.dart';

class ApiTrainingService {
  final String baseUrl = "https://eat-lift-backend.onrender.com/training";
  //final String baseUrl = "http://192.168.1.136:8000/training";
  
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
      Uri.parse('$baseUrl/exercises/$exerciseId/edit'),
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
      final decodedData = utf8.decode(response.bodyBytes);
      List<dynamic> exercises = json.decode(decodedData);
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
      final decodedData = utf8.decode(response.bodyBytes);
      Map<String, dynamic> exercise = json.decode(decodedData);
      return {
        "success": true,
        "exercise": exercise,
      };
    } else {
      return {"success": false, "exercise": []};
    }
  }

  Future<Map<String, dynamic>> getSavedExercises() async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.get(
      Uri.parse("$baseUrl/exercises/saved"),
      headers: {
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      final decodedData = utf8.decode(response.bodyBytes);
      List<dynamic> exercises = json.decode(decodedData);
      return {
        "success": true,
        "exercises": exercises,
      };
    } else {
      return {"success": false, "exercises": []};
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

Future<Map<String, dynamic>> getExerciseWeight(String exerciseId) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.get(
      Uri.parse("$baseUrl/exercises/$exerciseId/weight"),
      headers: {
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      final decodedData = utf8.decode(response.bodyBytes);
      Map<String, dynamic> weights = json.decode(decodedData);
      return {
        "success": true,
        "weight": weights,
      };
    } else {
      return {"success": false,};
    }
  }

// Workouts

Future<Map<String, dynamic>> createWorkout(Map<String, Object> workout) async {
  final SessionStorage sessionStorage = SessionStorage();
  final token = await sessionStorage.getAccessToken();

  final response = await http.post(
    Uri.parse('$baseUrl/workouts/create'),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Token $token",
    },
    body: jsonEncode({
      'name': workout["name"],
      'description': workout["description"],
      'exercises': workout["exercises"],
    }),
  );

  if (response.statusCode == 201) {
    final decodedData = utf8.decode(response.bodyBytes);
    final responseData = jsonDecode(decodedData);
    return {
      "success": true,
      "workout": responseData["id"]
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

  Future<Map<String, dynamic>> editWorkout(
      Map<String, Object> workout, String workoutId) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.put(
      Uri.parse('$baseUrl/workouts/$workoutId/edit'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
      body: jsonEncode({
        'name': workout["name"],
        'description': workout["description"],
        'exercises': workout["exercises"],
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

  Future<Map<String, dynamic>> getWorkouts(String query) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.get(
      Uri.parse("$baseUrl/workouts/?name=$query"),
      headers: {
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      final decodedData = utf8.decode(response.bodyBytes);
      List<dynamic> workouts = json.decode(decodedData);
      return {
        "success": true,
        "workouts": workouts,
      };
    } else {
      return {"success": false, "workouts": []};
    }
  }

  Future<Map<String, dynamic>> getWorkout(String workoutId) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.get(
      Uri.parse("$baseUrl/workouts/$workoutId"),
      headers: {
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      final decodedData = utf8.decode(response.bodyBytes);
      Map<String, dynamic> workout = json.decode(decodedData);
      return {
        "success": true,
        "workout": workout,
      };
    } else {
      return {"success": false, "workout": {}};
    }
  }

  Future<Map<String, dynamic>> getWorkoutSaved(String workoutId) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.get(
      Uri.parse("$baseUrl/workouts/$workoutId/isSaved"),
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

  Future<Map<String, dynamic>> saveWorkout(String workoutId) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.post(
      Uri.parse("$baseUrl/workouts/$workoutId/save"),
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

  Future<Map<String, dynamic>> unsaveWorkout(String workoutId) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.post(
      Uri.parse("$baseUrl/workouts/$workoutId/unsave"),
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

  Future<Map<String, dynamic>> deleteWorkout(String workoutId) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.delete(
      Uri.parse("$baseUrl/workouts/$workoutId/delete"),
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

  Future<Map<String, dynamic>> editRoutine(String userId, List<Map<String, dynamic>> exercises) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.post(
      Uri.parse("$baseUrl/routines/$userId/edit"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
      body: jsonEncode({
        'exercises': exercises,
      }),
    );

    if (response.statusCode == 200) {
      return {
        "success": true,
      };
    } else {
      final decodedData = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedData);

      List<String> errors = [];
      if (responseData.containsKey("errors")) {
        errors = List<String>.from(responseData["errors"]);
      } else {
        errors.add("Error desconegut. Si us plau, torna-ho a intentar.");
      }

      return {
        "success": false,
        "errors": errors,
      };
    }
  }

  Future<Map<String, dynamic>> getRoutine(String userId) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.get(
      Uri.parse("$baseUrl/routines/$userId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      final decodedData = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedData);

      return {
        "success": true,
        "exercises": responseData["exercises"],
      };
    } else {
      final decodedData = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedData);

      List<String> errors = [];
      if (responseData.containsKey("errors")) {
        errors = List<String>.from(responseData["errors"]);
      } else {
        errors.add("Error desconegut. Si us plau, torna-ho a intentar.");
      }

      return {
        "success": false,
        "errors": errors,
      };
    }
  }

  // Sessions

  Future<Map<String, dynamic>> getSession(String userId, String date) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.put(
      Uri.parse("$baseUrl/sessions/$userId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
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
        "session": responseData,
      };
    } else {
      final decodedData = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedData);

      List<String> errors = [];
      if (responseData.containsKey("errors")) {
        errors = List<String>.from(responseData["errors"]);
      } else {
        errors.add("Error desconegut. Si us plau, torna-ho a intentar.");
      }

      return {
        "success": false,
        "errors": errors,
      };
    }
  }


  Future<Map<String, dynamic>> editSession(String userId, Map<String, dynamic> sessionData) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.post(
      Uri.parse("$baseUrl/sessions/$userId/edit"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
      body: jsonEncode(
        sessionData,
      ),
    );

    if (response.statusCode == 200) {
      return {
        "success": true,
      };
    } else {
      final decodedData = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedData);

      List<String> errors = [];
      if (responseData.containsKey("errors")) {
        errors = List<String>.from(responseData["errors"]);
      } else {
        errors.add("Error desconegut. Si us plau, torna-ho a intentar.");
      }

      return {
        "success": false,
        "errors": errors,
      };
    }
  }

  Future<Map<String, dynamic>> getSessionsSummary(String userId, String date) async {
    final SessionStorage sessionStorage = SessionStorage();
    final token = await sessionStorage.getAccessToken();

    final response = await http.put(
      Uri.parse("$baseUrl/sessions/$userId/summary"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
      body: jsonEncode({
        "date": date,
      }),
    );

    if (response.statusCode == 200) {
      final decodedData = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedData);
      return responseData;
    } else {
      final decodedData = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedData);

      List<String> errors = [];
      if (responseData.containsKey("errors")) {
        errors = List<String>.from(responseData["errors"]);
      } else {
        errors.add("Error desconegut. Si us plau, torna-ho a intentar.");
      }

      return {
        "success": false,
        "errors": errors,
      };
    }
  }
}