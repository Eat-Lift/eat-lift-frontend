import 'package:eatnlift/models/meals.dart';
import 'package:eatnlift/models/session.dart';
import 'package:eatnlift/services/api_nutrition_service.dart';
import 'package:eatnlift/services/api_training_service.dart';
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
        id INTEGER PRIMARY KEY CHECK (id = 1),
        calories INTEGER,
        proteins INTEGER,
        fats INTEGER,
        carbohydrates INTEGER
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
    await db.insert('food_items', item.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
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

    await db.update(
      'food_items',
      updatedData,
      where: 'name = ? AND user = ?',
      whereArgs: [name, user],
    );
  }

  Future<List<Map<String, dynamic>>> fetchFoodItemsByName(String query) async {
    final db = await database;

    return await db.query(
      'food_items',
      where: 'LOWER(name) LIKE ?',
      whereArgs: ['%${query.toLowerCase()}%'],
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

  Future<List<Exercise>> fetchExercisesByName(String? query) async {
    final db = await instance.database;

    final result = query == null || query.trim().isEmpty
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

  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');
    await deleteDatabase(path);
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
  

Future<void> syncSessions() async {
  final databaseHelper = DatabaseHelper.instance;
  final apiService = ApiTrainingService();

  try {
    final userId = await SessionStorage().getUserId();
    final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Fetch local sessions for today
    final localSessions = await databaseHelper.fetchSessionsByDate(formattedDate, userId!);

    for (final session in localSessions) {
      final exercises = List<Map<String, dynamic>>.from(session['exercises'] as List);

      final List<Map<String, dynamic>> exercisesForSession = [];

      for (final exercise in exercises) {
        final exerciseName = exercise['exercise_name'];
        final exerciseUser = exercise['exercise_user'];

        // Fetch exercise ID from the backend
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

        // Process sets for the exercise
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

        // Sync session to the backend
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

  Future<void> syncDatabase() async {
    await syncMeals();
    await syncSessions();
  }
}
