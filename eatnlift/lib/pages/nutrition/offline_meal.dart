import 'package:eatnlift/custom_widgets/current_target_display.dart';
import 'package:eatnlift/custom_widgets/food_items_container.dart';
import 'package:eatnlift/custom_widgets/nutritient_circular_graph.dart';
import 'package:eatnlift/models/meals.dart';
import 'package:eatnlift/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../custom_widgets/relative_sizedbox.dart';
import '../../custom_widgets/rotating_logo.dart';

import '../../services/session_storage.dart';

import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class OfflineMealPage extends StatefulWidget {
  const OfflineMealPage({super.key});

  @override
  State<OfflineMealPage> createState() => _OfflineMealPageState();
}

class _OfflineMealPageState extends State<OfflineMealPage> {
  final SessionStorage sessionStorage = SessionStorage();
  String? currentUserId;
  Map<String, dynamic> userData = {};
  List<dynamic>? meals;
  Map<String, Map<String, dynamic>>? nutritionalInfo = {
    "GENERAL": {"calories": 0.0, "proteins": 0.0, "fats": 0.0, "carbohydrates": 0.0},
    "ESMORZAR": {"calories": 0.0, "proteins": 0.0, "fats": 0.0, "carbohydrates": 0.0},
    "DINAR": {"calories": 0.0, "proteins": 0.0, "fats": 0.0, "carbohydrates": 0.0},
    "BERENAR": {"calories": 0.0, "proteins": 0.0, "fats": 0.0, "carbohydrates": 0.0},
    "SOPAR": {"calories": 0.0, "proteins": 0.0, "fats": 0.0, "carbohydrates": 0.0},
  };
  bool isLoading = true;
  int key = 0;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    setState(() {
      isLoading = true;
    });
    await _fetchCurrentUserId();
    await _loadUserData();
    await _fetchMeals();
    await _calculateNutritionalInfo();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchCurrentUserId() async {
    final userId = await sessionStorage.getUserId();
    setState(() {
      currentUserId = userId;
    });
  }

  Future<void> _loadUserData() async {
    final databaseHelper = DatabaseHelper.instance;

    final localUserProfile = await databaseHelper.fetchUserProfile();

    if (localUserProfile != null) {
      userData = {
        "calories": localUserProfile.calories,
        "proteins": localUserProfile.proteins,
        "fats": localUserProfile.fats,
        "carbohydrates": localUserProfile.carbohydrates,
      };
    } else {
      userData = {
        "calories": 0,
        "proteins": 0,
        "fats": 0,
        "carbohydrates": 0,
      };
    }
  }

  Future<void> _fetchMeals() async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);

    final databaseHelper = DatabaseHelper.instance;

    final localMeals = await databaseHelper.fetchMealsByDate(formattedDate, currentUserId!);

    if (mounted) {
      setState(() {
        meals = localMeals.map((meal) {
          return {
            'id': meal['id'],
            'meal_type': meal['meal_type'],
            'date': meal['date'],
            'food_items': meal['food_items'],
          };
        }).toList();
      });
    }
  }

  Future<void> _calculateNutritionalInfo() async {
    double totalCalories = 0.0;
    double totalProteins = 0.0;
    double totalFats = 0.0;
    double totalCarbohydrates = 0.0;
    for (var meal in meals!) {
      String mealType = meal["meal_type"];

      for (var item in meal["food_items"]) {
        var food = item["food_item"];
        var quantity = item["quantity"];

        totalCalories += (food["calories"] * quantity) / 100;
        totalProteins += (food["proteins"] * quantity) / 100;
        totalFats += (food["fats"] * quantity) / 100;
        totalCarbohydrates += (food["carbohydrates"] * quantity) / 100;
      }

      nutritionalInfo?[mealType]?["calories"] = totalCalories;
      nutritionalInfo?[mealType]?["proteins"] = totalProteins;
      nutritionalInfo?[mealType]?["fats"] = totalFats;
      nutritionalInfo?[mealType]?["carbohydrates"] = totalCarbohydrates;

      nutritionalInfo?["GENERAL"]?["calories"] = totalCalories;
      nutritionalInfo?["GENERAL"]?["proteins"] = totalProteins;
      nutritionalInfo?["GENERAL"]?["fats"] = totalFats;
      nutritionalInfo?["GENERAL"]?["carbohydrates"] = totalCarbohydrates;
    }
  }

  void _onChangeQuantity(String mealType, Map<String, dynamic> foodItem, double quantity) {
    setState(() {
      final meal = meals!.firstWhereOrNull(
        (meal) => meal['meal_type'] == mealType,
      );

      if (meal != null) {
        if (meal != null) {
          final foodItems = (meal["food_items"] as List)
              .map((item) => item as Map<String, dynamic>)
              .toList();

          for (var item in foodItems) {
            if (item['id'] == foodItem['id']) {
              item['quantity'] = quantity;
            }
          }
        }
      }
      _calculateNutritionalInfo();
    });
  }

  void _onSubmittedQuantity(String mealType) {
    _editMeals(mealType);
  }

  void _onCheck(String mealType, Map<String, dynamic> foodItem) {
    setState(() {
      final meal = meals!.firstWhereOrNull(
        (meal) => meal['meal_type'] == mealType,
      );

      if (meal != null) {
        Map<String, dynamic> itemToRemove = {};

        for (var item in meal["food_items"]) {
          if (item["food_item"]["id"] == foodItem["id"]){
            itemToRemove = item;
          }
        }
        meal["food_items"].remove(itemToRemove);
      }
      _editMeals(mealType);
      _calculateNutritionalInfo();
    });
  }

  void _updateMeal(String mealType, List<Map<String, dynamic>> foodItems) {
    setState(() {
      final meal = meals!.firstWhereOrNull(
        (meal) => meal['meal_type'] == mealType,
      );

      if (meal != null) {
        meal["food_items"] = [];
        for (var foodItem in foodItems) {
          meal["food_items"].add({
            "food_item": foodItem,
            "quantity": foodItem["quantity"],
          });
        }
      }
      else {
        meals!.add(
          {"user": currentUserId,
          "meal_type": mealType,
          "date":DateFormat('yyyy-MM-dd').format(DateTime.now()),
          "food_items": foodItems.map((foodItem) => {
            "food_item": foodItem,
            "quantity": foodItem["quantity"]
          }).toList()}
        );
      }
    });
    ++key;
    _editMeals(mealType);
    _calculateNutritionalInfo();
    setState(() {});
  }

  Future<void> _editMeals(String mealType) async {
    final databaseHelper = DatabaseHelper.instance;

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);

    var existingMeal = meals!.firstWhereOrNull(
      (meal) => meal['meal_type'] == mealType,
    );

    if (existingMeal != null) {
      await databaseHelper.deleteMealByType(formattedDate, mealType, currentUserId!);
    }

    List<Map<String, dynamic>> foodItems = [];
    if (existingMeal != null) {
      for (var foodItem in existingMeal["food_items"]) {
        foodItems.add({
          "food_item_name": foodItem["food_item"]["name"],
          "quantity": foodItem["quantity"],
        });
      }
    }

    final meal = Meal(
      user: currentUserId!,
      mealType: mealType,
      date: formattedDate,
    );

    final mealId = await databaseHelper.insertMeal(meal);

    for (var foodItem in foodItems) {
      final foodItemMeal = FoodItemMeal(
        mealId: mealId,
        foodItemName: foodItem["food_item_name"],
        quantity: foodItem["quantity"].toDouble(),
      );
      await databaseHelper.insertFoodItemMeal(foodItemMeal);
    }

    final updatedMeals = await databaseHelper.fetchMealsByDate(formattedDate, currentUserId!);

    setState(() {
      meals = updatedMeals;
      ++key;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!isLoading) ...[
                    RelativeSizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            CurrentTargetDisplay(
                              current: nutritionalInfo?["GENERAL"]?["calories"].toInt(),
                              target: userData["calories"],
                              unit: 'kcals',
                              icon: Icons.local_fire_department,
                              size: 12,
                              width: 150,
                              height: 32,
                              normalColor: Colors.orange.shade700,
                            ),
                            RelativeSizedBox(height: 1),
                            CurrentTargetDisplay(
                              current: nutritionalInfo?["GENERAL"]?["proteins"].toInt(),
                              target: userData["proteins"],
                              unit: 'g',
                              icon: FontAwesomeIcons.drumstickBite,
                              size: 12,
                              width: 150,
                              height: 32,
                              normalColor: Colors.blue.shade700,
                            ),
                            RelativeSizedBox(height: 1),
                            CurrentTargetDisplay(
                              current: nutritionalInfo?["GENERAL"]?["carbohydrates"].toInt(),
                              target: userData["carbohydrates"],
                              unit: 'g',
                              icon: FontAwesomeIcons.wheatAwn,
                              size: 12,
                              width: 150,
                              height: 32,
                              normalColor: Colors.yellow.shade700,
                            ),
                            RelativeSizedBox(height: 1),
                            CurrentTargetDisplay(
                              current: nutritionalInfo?["GENERAL"]?["fats"].toInt(),
                              target: userData["fats"],
                              unit: 'g',
                              icon: Icons.water_drop,
                              size: 12,
                              width: 150,
                              height: 32,
                              normalColor: Colors.green.shade700,
                            ),
                          ],
                        ),
                        RelativeSizedBox(width: 5),
                        NutritionGraph(
                          caloriesTarget: userData["calories"].toDouble(),
                          caloriesCurrent: nutritionalInfo?["GENERAL"]?["calories"],
                          proteinsTarget: userData["proteins"].toDouble(),
                          proteinsCurrent: nutritionalInfo?["GENERAL"]?["proteins"],
                          fatsTarget: userData["fats"].toDouble(),
                          fatsCurrent: nutritionalInfo?["GENERAL"]?["fats"],
                          carbsTarget: userData["carbohydrates"].toDouble(),
                          carbsCurrent: nutritionalInfo?["GENERAL"]?["carbohydrates"],
                          size: 160,
                          barThickness: 15,
                        ),
                      ],
                    ),
                    RelativeSizedBox(height: 2),
                    FoodItemsContainer(
                      key: ValueKey(key),
                      title: "Esmorzar",
                      foodItems: meals!
                          .where((meal) => meal['meal_type'] == "ESMORZAR")
                          .map((meal) => (meal["food_items"] as List<dynamic>)
                              .cast<Map<String, dynamic>>())
                          .expand((item) => item)
                          .toList(),
                      onChangeQuantity: _onChangeQuantity,
                      onSumbittedQuantity: _onSubmittedQuantity,
                      onCheck: _onCheck,
                      updateMeal: _updateMeal,
                      offline: true,
                    ),
                    RelativeSizedBox(height: 1),
                    FoodItemsContainer(
                      key: ValueKey(key+1),
                      title: "Dinar",
                      foodItems: meals!
                          .where((meal) => meal['meal_type'] == "DINAR")
                          .map((meal) => (meal["food_items"] as List<dynamic>)
                              .cast<Map<String, dynamic>>())
                          .expand((item) => item)
                          .toList(),
                      onChangeQuantity: _onChangeQuantity,
                      onSumbittedQuantity: _onSubmittedQuantity,
                      onCheck: _onCheck,
                      updateMeal: _updateMeal,
                      offline: true,
                    ),
                    RelativeSizedBox(height: 1),
                    FoodItemsContainer(
                      key: ValueKey(key+2),
                      title: "Berenar",
                      foodItems: meals!
                          .where((meal) => meal['meal_type'] == "BERENAR")
                          .map((meal) => (meal["food_items"] as List<dynamic>)
                              .cast<Map<String, dynamic>>())
                          .expand((item) => item)
                          .toList(),
                      onChangeQuantity: _onChangeQuantity,
                      onSumbittedQuantity: _onSubmittedQuantity,
                      onCheck: _onCheck,
                      updateMeal: _updateMeal,
                      offline: true,
                    ),
                    RelativeSizedBox(height: 1),
                    FoodItemsContainer(
                      key: ValueKey(key+3),
                      title: "Sopar",
                      foodItems: meals!
                          .where((meal) => meal['meal_type'] == "SOPAR")
                          .map((meal) => (meal["food_items"] as List<dynamic>)
                              .cast<Map<String, dynamic>>())
                          .expand((item) => item)
                          .toList(),
                      onChangeQuantity: _onChangeQuantity,
                      onSumbittedQuantity: _onSubmittedQuantity,
                      onCheck: _onCheck,
                      updateMeal: _updateMeal,
                      offline: true,
                    ),
                    RelativeSizedBox(height: 5),
                  ] else ...[
                    Column(
                      children: [
                        RelativeSizedBox(height: 37),
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              RotatingImage(),
                            ],
                          ),
                        ),
                      ]
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}