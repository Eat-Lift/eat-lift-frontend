import 'dart:math';

import 'package:eatnlift/custom_widgets/current_target_display.dart';
import 'package:eatnlift/custom_widgets/food_items_container.dart';
import 'package:eatnlift/custom_widgets/nutritient_circular_graph.dart';
import 'package:eatnlift/services/api_nutrition_service.dart';
import 'package:eatnlift/services/api_user_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../custom_widgets/round_button.dart';
import '../../custom_widgets/relative_sizedbox.dart';

import '../../services/session_storage.dart';

import 'package:eatnlift/pages/nutrition/nutrition_create.dart';
import 'package:eatnlift/pages/nutrition/nutrition_search.dart';
import 'package:eatnlift/pages/nutrition/nutritional_plan.dart';
import 'package:intl/intl.dart';

class NutritionPage extends StatefulWidget {
  const NutritionPage({super.key});

  @override
  State<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  final SessionStorage sessionStorage = SessionStorage();
  String? currentUserId;
  Map<String, dynamic>? userData;
  List<dynamic>? meals;
  Map<String, Map<String, dynamic>>? nutritionalInfo = {
    "GENERAL": {"calories": 0.0, "proteins": 0.0, "fats": 0.0, "carbohydrates": 0.0},
    "BREAKFAST": {"calories": 0.0, "proteins": 0.0, "fats": 0.0, "carbohydrates": 0.0},
    "LUNCH": {"calories": 0.0, "proteins": 0.0, "fats": 0.0, "carbohydrates": 0.0},
    "SNACK": {"calories": 0.0, "proteins": 0.0, "fats": 0.0, "carbohydrates": 0.0},
    "DINNER": {"calories": 0.0, "proteins": 0.0, "fats": 0.0, "carbohydrates": 0.0},
  };
  bool isLoading = true;
  int key = 0;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
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
    final apiService = ApiUserService();
    final result = await apiService.getPersonalInformation(currentUserId!);
    if (result?["success"]){
      setState(() {
        userData = result?["user"];
      });
    }
  }

  Future<void> _fetchMeals() async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    final apiService = ApiNutritionService();
    final result = await apiService.getMeals(currentUserId!, formattedDate);
    if (result["success"]) {
      meals = result["meals"];
    }
  }

  Future<void> _calculateNutritionalInfo() async {
    if (meals != null) {
      for (var meal in meals!) {
        String mealType = meal["meal_type"];
        double totalCalories = 0.0;
        double totalProteins = 0.0;
        double totalFats = 0.0;
        double totalCarbohydrates = 0.0;

        for (var item in meal["food_items"]) {
          var food = item["food_item"];
          var quantity = item["quantity"];

          // Calculate totals for each nutrient
          totalCalories += (food["calories"] * quantity) / 100;
          totalProteins += (food["proteins"] * quantity) / 100;
          totalFats += (food["fats"] * quantity) / 100;
          totalCarbohydrates += (food["carbohydrates"] * quantity) / 100;
        }

        // Add to specific meal type
        nutritionalInfo?[mealType]?["calories"] += totalCalories;
        nutritionalInfo?[mealType]?["proteins"] += totalProteins;
        nutritionalInfo?[mealType]?["fats"] += totalFats;
        nutritionalInfo?[mealType]?["carbohydrates"] += totalCarbohydrates;

        // Add to GENERAL
        nutritionalInfo?["GENERAL"]?["calories"] += totalCalories;
        nutritionalInfo?["GENERAL"]?["proteins"] += totalProteins;
        nutritionalInfo?["GENERAL"]?["fats"] += totalFats;
        nutritionalInfo?["GENERAL"]?["carbohydrates"] += totalCarbohydrates;
      }
    }
  }

  void _onChangeQuantity(String mealType, Map<String, dynamic> foodItem, double quantity) {
    setState(() {
      final meal = meals!.firstWhere((meal) => meal['meal_type'] == mealType, orElse: () => null);

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
      _calculateNutritionalInfo;
    });
  }

  void _onCheck(String mealType, Map<String, dynamic> foodItem) {
    setState(() {
      final meal = meals!.firstWhere(
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
    });
  }

  void _updateMeal(String mealType, List<Map<String, dynamic>> foodItems) {
    setState(() {
      final meal = meals!.firstWhere(
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
      ++key;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (!isLoading && userData != null) ...[
                  RelativeSizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RoundButton(
                        icon: FontAwesomeIcons.magnifyingGlass,
                        onPressed:() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NutritionSearchPage()),
                          );
                        },
                        size: 70
                      ),
                      RelativeSizedBox(width: 3),
                      RoundButton(
                        icon: FontAwesomeIcons.plus,
                        onPressed:() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NutritionCreatePage()),
                          );
                        },
                        size: 70
                      ),
                      RelativeSizedBox(width: 3),
                      RoundButton(
                        icon: FontAwesomeIcons.calendar,
                        onPressed:() {
                        },
                        size: 70
                      ),
                      RelativeSizedBox(width: 3),
                      RoundButton(
                        icon: FontAwesomeIcons.book,
                        onPressed:() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NutritionalPlanPage()),
                          );
                        },
                        size: 70
                      ),
                    ]
                  ),
                  RelativeSizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          CurrentTargetDisplay(
                            current: nutritionalInfo?["GENERAL"]?["calories"].toInt(),
                            target: userData?["calories"],
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
                            target: userData?["proteins"],
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
                            target: userData?["carbohydrates"],
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
                            target: userData?["fats"],
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
                        caloriesTarget: userData?["calories"].toDouble(),
                        caloriesCurrent: nutritionalInfo?["GENERAL"]?["calories"],
                        proteinsTarget: userData?["proteins"].toDouble(),
                        proteinsCurrent: nutritionalInfo?["GENERAL"]?["proteins"],
                        fatsTarget: userData?["fats"].toDouble(),
                        fatsCurrent: nutritionalInfo?["GENERAL"]?["fats"],
                        carbsTarget: userData?["carbohydrates"].toDouble(),
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
                    onCheck: _onCheck,
                    updateMeal: _updateMeal,
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
                  ),
                ] else ...[
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        RelativeSizedBox(height: 10),
                        CircularProgressIndicator(color: Colors.grey),   
                      ],
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}