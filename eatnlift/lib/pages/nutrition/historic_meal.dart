import 'package:eatnlift/custom_widgets/current_target_display.dart';
import 'package:eatnlift/custom_widgets/food_items_container.dart';
import 'package:eatnlift/custom_widgets/nutritient_circular_graph.dart';
import 'package:eatnlift/custom_widgets/rotating_logo.dart';
import 'package:eatnlift/services/api_nutrition_service.dart';
import 'package:eatnlift/services/api_user_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../custom_widgets/relative_sizedbox.dart';

import '../../services/session_storage.dart';

import 'package:intl/intl.dart';

class HistoricMealPage extends StatefulWidget {
  final DateTime date;
  const HistoricMealPage({
    super.key,
    required this.date,
  });

  @override
  State<HistoricMealPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends State<HistoricMealPage> {
  final SessionStorage sessionStorage = SessionStorage();
  String? currentUserId;
  Map<String, dynamic>? userData;
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
    currentUserId = userId;
  }

  Future<void> _loadUserData() async {
    final apiService = ApiUserService();
    final result = await apiService.getPersonalInformation(currentUserId!);
    if (result?["success"]){
        userData = result?["user"];
    }
  }

  Future<void> _fetchMeals() async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(widget.date);
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
  }

  String _capitalizeFirstLetter(String input) {
    if (input.isEmpty) return input;
    return '${input[0].toUpperCase()}${input.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    final String capitalizedDate = _capitalizeFirstLetter(
      DateFormat('EEEE dd/MM/yyyy', 'ca').format(widget.date),
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: Text(capitalizedDate),
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!isLoading && userData != null) ...[
                    RelativeSizedBox(height: 1),
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
                          size: 140,
                          barThickness: 15,
                        ),
                      ],
                    ),
                    RelativeSizedBox(height: 2),
                    FoodItemsContainer(
                      size: 167,
                      key: ValueKey(key),
                      title: "Esmorzar",
                      foodItems: meals!
                          .where((meal) => meal['meal_type'] == "ESMORZAR")
                          .map((meal) => (meal["food_items"] as List<dynamic>)
                              .cast<Map<String, dynamic>>())
                          .expand((item) => item)
                          .toList(),
                      editable: false,
                      enableQuantityEdit: false,
                      isSelectable: false,
                    ),
                    RelativeSizedBox(height: 1),
                    FoodItemsContainer(
                      size: 167,
                      key: ValueKey(key+1),
                      title: "Dinar",
                      foodItems: meals!
                          .where((meal) => meal['meal_type'] == "DINAR")
                          .map((meal) => (meal["food_items"] as List<dynamic>)
                              .cast<Map<String, dynamic>>())
                          .expand((item) => item)
                          .toList(),
                      editable: false,
                      enableQuantityEdit: false,
                      isSelectable: false,
                    ),
                    RelativeSizedBox(height: 1),
                    FoodItemsContainer(
                      size: 167,
                      key: ValueKey(key+2),
                      title: "Berenar",
                      foodItems: meals!
                          .where((meal) => meal['meal_type'] == "BERENAR")
                          .map((meal) => (meal["food_items"] as List<dynamic>)
                              .cast<Map<String, dynamic>>())
                          .expand((item) => item)
                          .toList(),
                      editable: false,
                      enableQuantityEdit: false,
                      isSelectable: false,
                    ),
                    RelativeSizedBox(height: 1),
                    FoodItemsContainer(
                      size: 167,
                      key: ValueKey(key+3),
                      title: "Sopar",
                      foodItems: meals!
                          .where((meal) => meal['meal_type'] == "SOPAR")
                          .map((meal) => (meal["food_items"] as List<dynamic>)
                              .cast<Map<String, dynamic>>())
                          .expand((item) => item)
                          .toList(),
                      editable: false,
                      enableQuantityEdit: false,
                      isSelectable: false,
                    ),
                    RelativeSizedBox(height: 5),
                  ] else ...[
                    RelativeSizedBox(height: 25),
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          RelativeSizedBox(height: 10),
                          RotatingImage(),   
                        ],
                      ),
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