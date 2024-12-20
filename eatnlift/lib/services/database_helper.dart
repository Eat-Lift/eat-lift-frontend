import 'package:eatnlift/models/meals.dart';
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
        quantity REAL NOT NULL,
        FOREIGN KEY (meal_id) REFERENCES meals (id) ON DELETE CASCADE,
        FOREIGN KEY (food_item_name) REFERENCES food_items (name),
        UNIQUE (meal_id, food_item_name)
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
             fi.id AS food_item_id, fi.name, fi.calories, 
             fi.proteins, fi.fats, fi.carbohydrates, fi.user
      FROM food_item_meals fim
      INNER JOIN food_items fi ON fim.food_item_name = fi.name
      WHERE fim.meal_id = ?
    ''', [mealId]);

    List<Map<String, dynamic>> foodItems = foodItemsResult.map((item) {
      return {
        'food_item': {
          'id': item['food_item_id'],
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
}
