import 'package:eatnlift/custom_widgets/current_target_display.dart';
import 'package:eatnlift/custom_widgets/food_items_container.dart';
import 'package:eatnlift/custom_widgets/nutritient_circular_graph.dart';
import 'package:eatnlift/models/food_item.dart';
import 'package:eatnlift/models/meals.dart';
import 'package:eatnlift/pages/nutrition/historic_meal.dart';
import 'package:eatnlift/services/api_nutrition_service.dart';
import 'package:eatnlift/services/api_user_service.dart';
import 'package:eatnlift/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../custom_widgets/round_button.dart';
import '../../custom_widgets/relative_sizedbox.dart';
import '../../custom_widgets/rotating_logo.dart';

import '../../services/session_storage.dart';

import 'package:eatnlift/pages/nutrition/nutrition_create.dart';
import 'package:eatnlift/pages/nutrition/nutrition_search.dart';
import 'package:eatnlift/pages/nutrition/nutritional_plan.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

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
    final apiService = ApiUserService();
    final result = await apiService.getPersonalInformation(currentUserId!);
    if (result?["success"]){
      userData = result?["user"];
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
  }

  void _onChangeQuantity(String mealType, Map<String, dynamic> foodItem, double quantity) {
    setState(() {
      final meal = meals!.firstWhere(
        (meal) => meal['meal_type'] == mealType,
        orElse: () => null
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
      final meal = meals!.firstWhere(
        (meal) => meal['meal_type'] == mealType,
        orElse: () => null,
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
      final meal = meals!.firstWhere(
        (meal) => meal['meal_type'] == mealType,
        orElse: () => null,
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
      ++key;
      _editMeals(mealType);
      _calculateNutritionalInfo();
    });
  }

  void _editMeals(String mealType) async {
    final databaseHelper = DatabaseHelper.instance;

    List<Map<String, dynamic>> foodItems = [];
    var meal = meals!.firstWhere(
      (meal) => meal['meal_type'] == mealType,
      orElse: () => null,
    );

    if (meal != null) {
      for (var foodItem in meal["food_items"]) {
        foodItems.add({
          "food_item_id": foodItem["food_item"]["id"],
          "quantity": foodItem["quantity"],
        });

        final foodItemExists = await databaseHelper.fetchFoodItemsByName(foodItem["food_item"]["name"]);
        if (foodItemExists.isEmpty) {
          final foodItemData = FoodItem(
            name: foodItem["food_item"]["name"],
            calories: foodItem["food_item"]["calories"] is double
                ? foodItem["food_item"]["calories"]
                : double.tryParse(foodItem["food_item"]["calories"].toString()) ?? 0.0,
            proteins: foodItem["food_item"]["proteins"] is double
                ? foodItem["food_item"]["proteins"]
                : double.tryParse(foodItem["food_item"]["proteins"].toString()) ?? 0.0,
            fats: foodItem["food_item"]["fats"] is double
                ? foodItem["food_item"]["fats"]
                : double.tryParse(foodItem["food_item"]["fats"].toString()) ?? 0.0,
            carbohydrates: foodItem["food_item"]["carbohydrates"] is double
                ? foodItem["food_item"]["carbohydrates"]
                : double.tryParse(foodItem["food_item"]["carbohydrates"].toString()) ?? 0.0,
            user: foodItem["food_item"]["creator"].toString(),
          );
          await databaseHelper.insertFoodItem(foodItemData);
        }
      }
    }

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);

    await databaseHelper.deleteMealByType(formattedDate, mealType, currentUserId!);

    final localMeal = Meal(
      user: currentUserId!,
      mealType: mealType,
      date: formattedDate,
    );
    final mealId = await databaseHelper.insertMeal(localMeal);

    for (var foodItem in meal["food_items"]) {
      final foodItemMeal = FoodItemMeal(
        mealId: mealId,
        foodItemName: foodItem["food_item"]["name"],
        quantity: foodItem["quantity"].toDouble(),
        foodItemUser: foodItem["food_item"]["creator"].toString(),
      );
      await databaseHelper.insertFoodItemMeal(foodItemMeal);
    }

    final apiService = ApiNutritionService();
    final result = await apiService.editMeal(currentUserId!, formattedDate, mealType, foodItems);
    if (result["success"]) {
      setState(() {
        meal = result[meal];
        ++key;
      });
    }
  }

  Future<Widget> _buildCalendarDialog(BuildContext context) async {
    final apiService = ApiNutritionService();
    final result = await apiService.getMealDates(currentUserId!);

    Set<DateTime> markedDates = {};

    if (result["success"]) {
      markedDates = (result["dates"] as List<dynamic>)
          .map((date) {
            DateTime parsedDate = DateTime.parse(date as String);
            return DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
          })
          .toSet();
      DateTime today = DateTime.now();
      today = DateTime(today.year, today.month, today.day);
      markedDates.remove(today);
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Calendari",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TableCalendar(
              locale: 'ca',
              startingDayOfWeek: StartingDayOfWeek.monday,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: DateTime.now(),
              eventLoader: (date) {
                DateTime normalizedDate = DateTime(date.year, date.month, date.day);
                return markedDates.contains(normalizedDate) ? ['Event'] : [];
              },
              calendarStyle: CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  shape: BoxShape.circle,
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                DateTime today = DateTime.now();
                DateTime normalizedToday = DateTime(today.year, today.month, today.day);
                DateTime normalizedSelectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

                if (normalizedSelectedDay == normalizedToday) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoricMealPage(date: selectedDay),
                    ),
                  );
                }
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextFormatter: (date, locale) => 
                    DateFormat('MMMM yyyy', 'ca').format(date),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Tanca"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    RelativeSizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RoundButton(
                          icon: FontAwesomeIcons.magnifyingGlass,
                          onPressed:() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const NutritionSearchPage(isCreating: false)),
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
                          onPressed:() async {
                            final dialogWidget = await _buildCalendarDialog(context);
                            if (context.mounted) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => dialogWidget,
                              );
                            }
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
                    RelativeSizedBox(height: 3),
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
                    ),
                    RelativeSizedBox(height: 2),
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