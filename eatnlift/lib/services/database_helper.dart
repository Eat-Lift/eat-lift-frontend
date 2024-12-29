import 'package:eatnlift/models/meals.dart';
import 'package:eatnlift/models/session.dart';
import 'package:eatnlift/services/api_nutrition_service.dart';
import 'package:eatnlift/services/api_training_service.dart';
import 'package:eatnlift/services/api_user_service.dart';
import 'package:eatnlift/services/session_storage.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/exercise.dart';
import '../models/user_profile.dart';
import '../models/food_item.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE food_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        calories REAL,
        proteins REAL,
        fats REAL,
        carbohydrates REAL,
        user TEXT NOT NULL,
        UNIQUE (name, user)
      )
    ''');

    await db.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        user TEXT NOT NULL,
        trained_muscles TEXT,
        UNIQUE (name, user)
      )
    ''');

    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        calories INTEGER CHECK(calories >= 0),
        proteins INTEGER CHECK(calories >= 0),
        fats INTEGER CHECK(calories >= 0),
        carbohydrates IINTEGER CHECK(calories >= 0)
      )
    ''');

    await db.execute('''
      CREATE TABLE meals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user TEXT NOT NULL,
        meal_type TEXT NOT NULL,
        date TEXT NOT NULL,
        UNIQUE (user, meal_type, date)
      )
    ''');

    await db.execute('''
      CREATE TABLE food_item_meals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        meal_id INTEGER NOT NULL,
        food_item_name TEXT NOT NULL,
        food_item_user TEXT NOT NULL,
        quantity REAL NOT NULL,
        FOREIGN KEY (meal_id) REFERENCES meals (id) ON DELETE CASCADE,
        FOREIGN KEY (food_item_name) REFERENCES food_items (name),
        UNIQUE (meal_id, food_item_name, food_item_user)
      )
    ''');

    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user TEXT NOT NULL,
        date TEXT NOT NULL,
        UNIQUE(user, date)
      )
    ''');

    await db.execute('''
      CREATE TABLE session_exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        exercise_name TEXT NOT NULL,
        exercise_user TEXT NOT NULL,
        FOREIGN KEY (session_id) REFERENCES sessions (id) ON DELETE CASCADE,
        FOREIGN KEY (exercise_name) REFERENCES exercises (name),
        UNIQUE (session_id, exercise_name, exercise_user)
      )
    ''');

    await db.execute('''
      CREATE TABLE session_sets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_exercise_id INTEGER NOT NULL,
        weight REAL NOT NULL,
        reps INTEGER NOT NULL,
        FOREIGN KEY (session_exercise_id) REFERENCES session_exercises (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> insertFoodItem(FoodItem item) async {
    final db = await instance.database;
    await db.insert(
      'food_items', item.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<List<FoodItem>> fetchFoodItems() async {
    final db = await instance.database;
    final result = await db.query('food_items');
    return result.map((json) => FoodItem.fromJson(json)).toList();
  }

  Future<void> deleteFoodItemByNameAndUser(String name, String user) async {
    final db = await instance.database;

    await db.delete(
      'food_items',
      where: 'name = ? AND user = ?',
      whereArgs: [name, user],
    );
  }

  Future<void> updateFoodItemByNameAndUser({
    required String name,
    required String user,
    required Map<String, dynamic> updatedData,
  }) async {
    final db = await instance.database;

    final existingRecord = await db.query(
      'food_items',
      where: 'name = ? AND user = ?',
      whereArgs: [name, user],
    );

    if (existingRecord.isNotEmpty) {
      final existingData = existingRecord.first;
      final mergedData = {...existingData, ...updatedData};

      mergedData['id'] = existingData['id'];

      await db.update(
        'food_items',
        mergedData,
        where: 'name = ? AND user = ?',
        whereArgs: [name, user],
      );
    } else {
      throw Exception("No matching record found to update");
    }
  }

  Future<List<Map<String, dynamic>>> fetchFoodItemsByName(String query) async {
    final db = await database;

    return await db.query(
      'food_items',
      where: 'LOWER(name) LIKE ?',
      whereArgs: ['%${query.toLowerCase()}%'],
      limit: 50,
    );
  }

  Future<void> insertExercise(Exercise exercise) async {
    final db = await instance.database;
    await db.insert(
      'exercises',
      exercise.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Exercise>> fetchExercises() async {
    final db = await instance.database;
    final result = await db.query('exercises');
    return result.map((json) => Exercise.fromJson(json)).toList();
  }

  Future<List<Exercise>> fetchExercisesByName(String query) async {
    final db = await instance.database;

    final result = query.trim().isEmpty
        ? await db.query('exercises')
        : await db.query(
            'exercises',
            where: 'LOWER(name) LIKE ?',
            whereArgs: ['%${query.toLowerCase()}%'],
          );

    return result.map((json) => Exercise.fromJson(json)).toList();
  }

  Future<void> deleteExerciseById(int exerciseId) async {
    final db = await instance.database;
    await db.delete(
      'exercises',
      where: 'id = ?',
      whereArgs: [exerciseId],
    );
  }

  Future<void> updateExercise(Exercise exercise) async {
    final db = await instance.database;

    await db.update(
      'exercises',
      exercise.toJson(),
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
  }

  Future<List<Exercise>> searchExercises(String query) async {
    final db = await instance.database;

    final results = await db.query(
      'exercises',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );

    return results.map((row) {
      return Exercise(
        id: row['id'] as int?,
        name: row['name'] as String,
        description: row['description'] as String?,
        user: row['user'] as String,
        trainedMuscles: (row['trained_muscles'] as String).split(','),
      );
    }).toList();
  }

  Future<void> insertUserProfile(UserProfile profile) async {
    final db = await instance.database;
    await db.insert(
      'user_profile',
      profile.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserProfile?> fetchUserProfile() async {
    final db = await instance.database;
    final result = await db.query('user_profile', limit: 1);
    if (result.isNotEmpty) {
      return UserProfile.fromJson(result.first);
    }
    return null;
  }

  Future<int> insertMeal(Meal meal) async {
    final db = await instance.database;
    return await db.insert(
      'meals',
      meal.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertFoodItemMeal(FoodItemMeal itemMeal) async {
    final db = await instance.database;

    await db.insert(
      'food_item_meals',
      itemMeal.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> fetchMealsByDate(String date, String user) async {
    final db = await instance.database;

    final mealsResult = await db.query(
      'meals',
      where: 'date = ? AND user = ?',
      whereArgs: [date, user],
    );

    List<Map<String, dynamic>> mealsWithItems = [];

    for (var meal in mealsResult) {
      final mealId = meal['id'];

      final foodItemsResult = await db.rawQuery('''
        SELECT fim.quantity, 
              fi.name, fi.calories, 
              fi.proteins, fi.fats, fi.carbohydrates, fi.user
        FROM food_item_meals fim
        INNER JOIN food_items fi ON fim.food_item_name = fi.name
        WHERE fim.meal_id = ?
      ''', [mealId]);

      List<Map<String, dynamic>> foodItems = foodItemsResult.map((item) {
        return {
          'food_item': {
            'name': item['name'],
            'calories': item['calories'],
            'proteins': item['proteins'],
            'fats': item['fats'],
            'carbohydrates': item['carbohydrates'],
            'user': item['user'],
          },
          'quantity': item['quantity'],
        };
      }).toList();

      mealsWithItems.add({
        ...meal,
        'food_items': foodItems,
      });
    }

    return mealsWithItems;
  }

  Future<List<FoodItemMeal>> fetchFoodItemsByMealId(int mealId) async {
    final db = await instance.database;

    final result = await db.query(
      'food_item_meals',
      where: 'meal_id = ?',
      whereArgs: [mealId],
    );

    return result.map((json) => FoodItemMeal.fromJson(json)).toList();
  }

  Future<void> deleteFoodItemMeal(int mealId, String foodItemName) async {
    final db = await instance.database;

    await db.delete(
      'food_item_meals',
      where: 'meal_id = ? AND food_item_name = ?',
      whereArgs: [mealId, foodItemName],
    );
  }

  Future<void> deleteAllMealsForDate(String date, String user) async {
    final db = await instance.database;

    await db.delete(
      'meals',
      where: 'date = ? AND user = ?',
      whereArgs: [date, user],
    );
  }

  Future<void> deleteMealByType(String date, String mealType, String user) async {
    final db = await instance.database;

    await db.delete(
      'meals',
      where: 'date = ? AND meal_type = ? AND user = ?',
      whereArgs: [date, mealType, user],
    );
  }

  Future<void> deleteMealsNotMatchingDate(String date, String user) async {
    final db = await instance.database;

    await db.delete(
      'food_item_meals',
      where: 'meal_id IN (SELECT id FROM meals WHERE date != ? AND user = ?)',
      whereArgs: [date, user],
    );

    await db.delete(
      'meals',
      where: 'date != ? AND user = ?',
      whereArgs: [date, user],
    );
  }

  Future<int> insertSession(Session session) async {
    final db = await instance.database;
    return await db.insert('sessions', session.toJson());
  }

  Future<int> insertSessionExercise(SessionExercise sessionExercise) async {
    final db = await instance.database;
    return await db.insert('session_exercises', sessionExercise.toJson());
  }

  Future<int> insertSessionSet(SessionSet sessionSet) async {
    final db = await instance.database;
    return await db.insert('session_sets', sessionSet.toJson());
  }

  Future<List<Map<String, dynamic>>> fetchSessionsByDate(String date, String user) async {
    final db = await instance.database;

    final sessions = await db.query(
      'sessions',
      where: 'date = ? AND user = ?',
      whereArgs: [date, user],
    );

    final List<Map<String, dynamic>> sessionsWithExercises = [];

    for (var session in sessions) {
      final mutableSession = Map<String, dynamic>.from(session);

      final sessionId = session['id'];

      final sessionExercises = await db.query(
        'session_exercises',
        where: 'session_id = ?',
        whereArgs: [sessionId],
      );

      final List<Map<String, dynamic>> exercisesWithSets = [];

      for (var sessionExercise in sessionExercises) {
        final mutableSessionExercise = Map<String, dynamic>.from(sessionExercise);

        final sessionExerciseId = sessionExercise['id'];

        final sessionSets = await db.query(
          'session_sets',
          where: 'session_exercise_id = ?',
          whereArgs: [sessionExerciseId],
        );

        mutableSessionExercise['sets'] = List<Map<String, dynamic>>.from(sessionSets);

        exercisesWithSets.add(mutableSessionExercise);
      }

      mutableSession['exercises'] = exercisesWithSets;

      sessionsWithExercises.add(mutableSession);
    }

    return sessionsWithExercises;
  }
    

  Future<void> syncMeals() async {
    final databaseHelper = DatabaseHelper.instance;
    final apiService = ApiNutritionService();

    final userId = await SessionStorage().getUserId();

    final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    await databaseHelper.deleteMealsNotMatchingDate(formattedDate, userId!);

    final localMeals = await databaseHelper.fetchMealsByDate(formattedDate, userId);

    for (final meal in localMeals) {
      final foodItems = await databaseHelper.fetchFoodItemsByMealId(meal['id']);
      final List<Map<String, dynamic>> foodItemsWithBackendIds = [];

      for (final item in foodItems) {
        final foodItemName = item.foodItemName;
        final foodItemUser = item.foodItemUser;
        final searchResult = await apiService.getFoodItems(foodItemName);

        String? backendId;
        if (searchResult["success"] && (searchResult["foodItems"] as List).isNotEmpty) {
          final matchingFoodItem = (searchResult["foodItems"] as List).firstWhere(
            (backendItem) =>
                backendItem["name"] == foodItemName && backendItem["creator"].toString() == foodItemUser,
            orElse: () => null,
          );

          if (matchingFoodItem != null) {
            backendId = matchingFoodItem["id"].toString();
          }
        }

        if (backendId != null) {
          foodItemsWithBackendIds.add({
            "food_item_id": backendId,
            "quantity": item.quantity,
          });
        }
      }

      final mealData = {
        "meal_type": meal['meal_type'],
        "date": formattedDate,
        "food_items": foodItemsWithBackendIds,
      };

      await apiService.editMeal(userId, formattedDate, meal['meal_type'], mealData["food_items"]);

    }
    
  }

  Future<void> syncSessions() async {
    final databaseHelper = DatabaseHelper.instance;
    final apiService = ApiTrainingService();

    try {
      final userId = await SessionStorage().getUserId();
      final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final localSessions = await databaseHelper.fetchSessionsByDate(formattedDate, userId!);

      for (final session in localSessions) {
        final exercises = List<Map<String, dynamic>>.from(session['exercises'] as List);

        final List<Map<String, dynamic>> exercisesForSession = [];

        for (final exercise in exercises) {
          final exerciseName = exercise['exercise_name'];
          final exerciseUser = exercise['exercise_user'];

          String? backendExerciseId;
          final response = await apiService.getExercises(exerciseName);

          if (response["success"] && (response["exercises"] as List).isNotEmpty) {
            final matchingExercise = (response["exercises"] as List).firstWhere(
              (backendExercise) =>
                  backendExercise["name"] == exerciseName &&
                  backendExercise["user"].toString() == exerciseUser,
              orElse: () => null,
            );

            if (matchingExercise != null) {
              backendExerciseId = matchingExercise["id"].toString();
            }
          }

          if (backendExerciseId == null) {
            print("No matching backend exercise found for name: $exerciseName, user: $exerciseUser");
            continue;
          }

          final sets = List<Map<String, dynamic>>.from(exercise['sets'] as List);
          final List<Map<String, dynamic>> setsForExercise = sets.map((set) {
            return {
              'weight': set['weight'],
              'reps': set['reps'],
            };
          }).toList();

          exercisesForSession.add({
            'exercise': backendExerciseId,
            'sets': setsForExercise,
          });
        }

        if (exercisesForSession.isNotEmpty) {
          final sessionData = {
            'date': formattedDate,
            'exercises': exercisesForSession,
          };

          final result = await apiService.editSession(userId, sessionData);

          if (!result['success']) {
            print("Failed to sync session for $formattedDate");
          }
        }
      }
    } catch (error) {
      print("Error syncing sessions: $error");
    }
  }

  Future<void> getMeals() async {
    final databaseHelper = DatabaseHelper.instance;
    final apiService = ApiNutritionService();

    try {
      final currentUserId = await SessionStorage().getUserId();
      final String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final response = await apiService.getMeals(currentUserId!, formattedDate);

      if (response["success"]) {
        final mealsFromBackend = response["meals"] as List<dynamic>;

        for (final mealData in mealsFromBackend) {
          await databaseHelper.saveMealFromBackend(mealData);
        }
      } else {
        print("Failed to fetch meals from backend: ${response['errors']}");
      }
    } catch (error) {
      print("Error fetching meals: $error");
    }
  }


Future<void> saveMealFromBackend(Map<String, dynamic> mealData) async {
  final databaseHelper = DatabaseHelper.instance;

  try {
    final String mealType = mealData['meal_type'];
    final String date = mealData['date'];
    final String userId = mealData['user'].toString();

    final List<Map<String, dynamic>> foodItems = (mealData['food_items'] as List<dynamic>)
        .map((item) => item as Map<String, dynamic>)
        .toList();

    for (final foodItem in foodItems) {
      final foodItemDetails = foodItem['food_item'];

      final existingFoodItem =
          await databaseHelper.fetchFoodItemsByName(foodItemDetails['name']);
      if (existingFoodItem.isEmpty) {
        final newFoodItem = FoodItem(
          name: foodItemDetails['name'],
          calories: foodItemDetails['calories'] is double
              ? foodItemDetails['calories']
              : double.tryParse(foodItemDetails['calories'].toString()) ?? 0.0,
          proteins: foodItemDetails['proteins'] is double
              ? foodItemDetails['proteins']
              : double.tryParse(foodItemDetails['proteins'].toString()) ?? 0.0,
          fats: foodItemDetails['fats'] is double
              ? foodItemDetails['fats']
              : double.tryParse(foodItemDetails['fats'].toString()) ?? 0.0,
          carbohydrates: foodItemDetails['carbohydrates'] is double
              ? foodItemDetails['carbohydrates']
              : double.tryParse(foodItemDetails['carbohydrates'].toString()) ?? 0.0,
          user: foodItemDetails['creator'].toString(),
        );
        await databaseHelper.insertFoodItem(newFoodItem);
      }
    }

    final Meal localMeal = Meal(
      user: userId,
      mealType: mealType,
      date: date,
    );
    final int mealId = await databaseHelper.insertMeal(localMeal);

    for (final foodItem in foodItems) {
      final FoodItemMeal foodItemMeal = FoodItemMeal(
        mealId: mealId,
        foodItemName: foodItem['food_item']['name'],
        quantity: foodItem['quantity'] is double
            ? foodItem['quantity']
            : double.tryParse(foodItem['quantity'].toString()) ?? 0.0,
        foodItemUser: foodItem['food_item']['creator'].toString(),
      );
      await databaseHelper.insertFoodItemMeal(foodItemMeal);
    }

    print("Meal saved successfully from backend");
  } catch (error) {
    print("Error saving meal from backend: $error");
  }
}

  Future<void> getSession() async {
    final databaseHelper = DatabaseHelper.instance;
    final apiService = ApiTrainingService();

    try {
      final currentUserId = await SessionStorage().getUserId();
      final String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final response = await apiService.getSession(currentUserId!, formattedDate);

      if (response["success"]) {
        final sessionFromBackend = response["session"] as Map<String, dynamic>? ?? {};
        await databaseHelper.saveSessionFromBackend(sessionFromBackend);
      } else {
        print("Failed to fetch sessions from backend: ${response['errors']}");
      }
    } catch (error) {
      print("Error fetching sessions: $error");
    }
  }


  Future<void> saveSessionFromBackend(Map<String, dynamic> session) async {
    final databaseHelper = DatabaseHelper.instance;

    try {
      final db = await databaseHelper.database;

      final sessionId = await db.insert(
        'sessions',
        {
          'user': session['user'],
          'date': session['date'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (final sessionExercise in session['exercises']) {
        final exercise = sessionExercise['exercise'];


        final existingExercise = await db.query(
          'exercises',
          where: 'name = ? AND user = ?',
          whereArgs: [exercise['name'], exercise['user']],
        );

        if (existingExercise.isEmpty) {
          await db.insert(
            'exercises',
            {
              'name': exercise['name'],
              'description': exercise['description'],
              'user': exercise['user'],
              'trained_muscles': (exercise['trained_muscles'] as List<dynamic>).join(','),
            },
          );
        }

        final exerciseId = await db.insert(
          'session_exercises',
          {
            'session_id': sessionId,
            'exercise_name': exercise['name'],
            'exercise_user': exercise['user'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        for (final set in sessionExercise['sets']) {
          await db.insert(
            'session_sets',
            {
              'session_exercise_id': exerciseId,
              'weight': set['weight'],
              'reps': set['reps'],
            },
          );
        }
      }
      print("Session successfully inserted into the local database.");
    } catch (error) {
      print("Error inserting session into the local database: $error");
    }
  }

  Future<void> getSavedFoodItems() async {
    final databaseHelper = DatabaseHelper.instance;
    final apiService = ApiNutritionService();

    try {
      final response = await apiService.getSavedFoodItems();

      if (response["success"]) {
        final savedFoodItems = response["foodItems"] as List<dynamic>? ?? [];

        for (final foodItemData in savedFoodItems) {
          final existingFoodItem = await databaseHelper.fetchFoodItemsByName(foodItemData["name"]);

          if (existingFoodItem.isEmpty) {
            final foodItem = FoodItem(
              name: foodItemData["name"],
              calories: foodItemData["calories"] is double
                  ? foodItemData["calories"]
                  : double.tryParse(foodItemData["calories"].toString()) ?? 0.0,
              proteins: foodItemData["proteins"] is double
                  ? foodItemData["proteins"]
                  : double.tryParse(foodItemData["proteins"].toString()) ?? 0.0,
              fats: foodItemData["fats"] is double
                  ? foodItemData["fats"]
                  : double.tryParse(foodItemData["fats"].toString()) ?? 0.0,
              carbohydrates: foodItemData["carbohydrates"] is double
                  ? foodItemData["carbohydrates"]
                  : double.tryParse(foodItemData["carbohydrates"].toString()) ?? 0.0,
              user: foodItemData["creator"].toString(),
            );
            await databaseHelper.insertFoodItem(foodItem);
          }
        }
      } else {
        print("Failed to fetch saved food items: ${response['errors']}");
      }
    } catch (error) {
      print("Error fetching saved food items: $error");
    }
  }


  Future<void> getSavedExercises() async {
    final databaseHelper = DatabaseHelper.instance;
    final apiService = ApiTrainingService();

    try {
      final response = await apiService.getSavedExercises();

      if (response["success"]) {
        final savedExercises = response["exercises"] as List<dynamic>? ?? [];

        for (final exerciseData in savedExercises) {
          final existingExercise = await databaseHelper.fetchExercisesByName(exerciseData["name"]);

          if (existingExercise.isEmpty) {
            final exercise = Exercise(
              id: exerciseData["id"],
              name: exerciseData["name"],
              description: exerciseData["description"],
              user: exerciseData["user"].toString(),
              trainedMuscles: List<String>.from(exerciseData["trained_muscles"] ?? []),
            );

            await databaseHelper.insertExercise(exercise);
          }
        }
      } else {
        print("Failed to fetch saved exercises: ${response['errors']}");
      }
    } catch (error) {
      print("Error fetching saved exercises: $error");
    }
  }

  Future<void> getPersonalInformation() async {
    final databaseHelper = DatabaseHelper.instance;
    final apiService = ApiUserService();
    final currentUserId = await SessionStorage().getUserId();

    try {
      final response = await apiService.getPersonalInformation(currentUserId!);

      if (response?["success"]) {
        final userData = response?["user"] as Map<String, dynamic>;

        final userProfile = UserProfile(
          calories: userData["calories"],
          proteins: userData["proteins"],
          fats: userData["fats"],
          carbohydrates: userData["carbohydrates"],
        );

        await databaseHelper.insertUserProfile(userProfile);
      } else {
        print("Failed to fetch personal information: ${response?['errors']}");
      }
    } catch (error) {
      print("Error fetching personal information: $error");
    }
  }

  Future<void> emptyDatabase() async {
    final databaseHelper = DatabaseHelper.instance;
    final db = await databaseHelper.database;

    await db.delete('meals');
    await db.delete('session_exercises');
    await db.delete('session_sets');
    await db.delete('sessions');
    await db.delete('food_items');
    await db.delete('food_item_meals');
    await db.delete('exercises');
    await db.delete('user_profile');

  }

  Future<void> syncDatabase() async {
    await syncMeals();
    await syncSessions();
    await emptyDatabase();
    await getMeals();
    await getSession();
    await getSavedFoodItems();
    await getSavedExercises();
    await getPersonalInformation();
    await printDatabase();
  }

  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');
    await deleteDatabase(path);
  }


  Future<void> printDatabase() async {
    // Open or get the database instance
    final db = await openDatabase(
      'app_database.db',
      version: 1,
      onCreate: (db, version) async {
        await _createDB(db, version);
      },
    );

    // List of all tables to print
    final tables = [
      'food_items',
      'exercises',
      'user_profile',
      'meals',
      'food_item_meals',
      'sessions',
      'session_exercises',
      'session_sets',
    ];

    for (final table in tables) {
      try {
        // Query the table
        final results = await db.query(table);

        // Print table name and its contents
        print('Contents of $table:');
        if (results.isEmpty) {
          print('  (No data)');
        } else {
          for (var row in results) {
            print('  $row');
          }
        }
      } catch (e) {
        // Catch any errors (e.g., if the table doesn't exist)
        print('Error reading $table: $e');
      }
    }
  }

}
