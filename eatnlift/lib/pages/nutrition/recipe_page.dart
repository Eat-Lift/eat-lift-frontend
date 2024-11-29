import 'package:eatnlift/custom_widgets/custom_number.dart';
import 'package:eatnlift/custom_widgets/expandable_text.dart';
import 'package:eatnlift/custom_widgets/food_item_card.dart';
import 'package:eatnlift/custom_widgets/rotating_logo.dart';
import 'package:eatnlift/pages/nutrition/recipe_edit.dart';
import 'package:eatnlift/services/api_nutrition_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../custom_widgets/expandable_image.dart';
import '../../custom_widgets/relative_sizedbox.dart';

import '../../services/session_storage.dart';

class RecipePage extends StatefulWidget {
  final int recipeId;
  final bool isCreating;

  const RecipePage({
    super.key,
    required this.recipeId,
    this.isCreating = true,
  });

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  final SessionStorage sessionStorage = SessionStorage();
  String? currentUserId;
  
  late Map<String, dynamic>? recipeData;
  bool isLoading = true;
  bool isSaved = false;

  double calories = 0;
  double proteins = 0;
  double fats = 0;
  double carbohydrates = 0;

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    setState((){
      isLoading = true;
    });
    await _fetchRecipeData();
    await _fetchCurrentUserId();
    await _fetchSaved();
    setState((){
      isLoading = false;
    });
  }

  Future<void> _fetchCurrentUserId() async {
    final userId = await sessionStorage.getUserId();
    currentUserId = userId;
  }

  Future<void> _fetchRecipeData() async {
    final apiService = ApiNutritionService();
    final recipe = await apiService.getRecipe(widget.recipeId);
    recipeData = recipe["recipe"];
    _calculateNutritionalInfo();
  }

  Future<void> _fetchSaved() async {
    final apiService = ApiNutritionService();
    final response = await apiService.getRecipeSaved(widget.recipeId.toString());
    isSaved = response["is_saved"];
  }

  void _toggleSaved() async {
    final apiService = ApiNutritionService();
    if (isSaved){
      final response = await apiService.unsaveRecipe(widget.recipeId.toString());
      if (response["success"]) {
        setState(() {
          isSaved = false;
        });
      }
    }
    else {
      final response = await apiService.saveRecipe(widget.recipeId.toString());
      if (response["success"]) {
        setState(() {
          isSaved = true;
        });
      }
    }
  }

  void _calculateNutritionalInfo() {
    calories = 0;
    proteins = 0;
    fats = 0;
    carbohydrates = 0;

    if (recipeData?["recipe_food_items"] is List) {
      for (Map<String, dynamic> foodItem in recipeData?["recipe_food_items"] ?? []) {
        calories += (foodItem["quantity"] * foodItem["calories"]) / 100;
        proteins += (foodItem["quantity"] * foodItem["proteins"]) / 100;
        fats += (foodItem["quantity"] * foodItem["fats"]) / 100;
        carbohydrates += (foodItem["quantity"] * foodItem["carbohydrates"]) / 100;
      }
    }
    setState(() {});
  }

  void _deleteRecipe() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmació"),
          content: const Text("Estàs segur que vols eliminar aquesta recepta?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel·lar"),
            ),
            TextButton(
              onPressed: () async {
                final apiService = ApiNutritionService();
                await apiService.deleteRecipe(widget.recipeId.toString());
                if (context.mounted){
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text("Recepta"),
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Stack(
            children: [
              if (!isLoading) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RelativeSizedBox(height: 1),
                    Row(
                      children: [
                        ExpandableImage(
                          initialImageUrl: recipeData?["picture"],
                          width: 70,
                          height: 70,
                        ),
                        RelativeSizedBox(width: 5),
                        Flexible(
                          child: Text(
                            recipeData?["name"] ?? '',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 22,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                    RelativeSizedBox(height: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          IconButton(
                            icon: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                              color: Colors.black,
                            ),
                            tooltip: isSaved ? 'Unsave' : 'Save',
                            onPressed: _toggleSaved,
                          ),
                          if (currentUserId == recipeData?["creator"].toString() && !widget.isCreating)
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black),
                              tooltip: 'Edit',
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditRecipePage(recipeData: recipeData),
                                  )
                                );

                                if (result == true){
                                  _fetchRecipeData();
                                }
                              },
                            ),
                          if (currentUserId == recipeData?["creator"].toString() && !widget.isCreating)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.black),
                              tooltip: 'Delete',
                              onPressed: _deleteRecipe,
                            ),
                      ],
                    ),
                    RelativeSizedBox(height: 1),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ExpandableText(
                        text: recipeData?["description"]?.isEmpty ?? true
                            ? "Això està una mica buit"
                            : recipeData?["description"],
                      ),
                    ),
                    RelativeSizedBox(height: 2),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomNumber(number: calories, width: 330, icon: Icons.local_fire_department, unit: "kcal", isCentered: true, size: 13),
                        RelativeSizedBox(height: 0.5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomNumber(number: proteins, width: 107, icon: FontAwesomeIcons.drumstickBite, unit: "g", size: 13),
                            RelativeSizedBox(width: 1),
                            CustomNumber(number: carbohydrates, width: 107, icon: FontAwesomeIcons.wheatAwn, unit: "g", size: 13),
                            RelativeSizedBox(width: 1),
                            CustomNumber(number: fats, width: 107, icon: Icons.water_drop, unit: "g", size: 13),
                          ],
                        ),
                      ],
                    ),
                    RelativeSizedBox(height: 2),
                    Container(
                      height: 320,
                      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 7.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Stack(
                        children: [
                          recipeData?["recipe_food_items"].isNotEmpty
                              ? ListView.builder(
                                  itemCount: recipeData?["recipe_food_items"].length,
                                  itemBuilder: (context, index) {
                                    final foodItem = recipeData?["recipe_food_items"][index];
                                    return Row(
                                      children: [
                                        Expanded(
                                          child: FoodItemCard(
                                            key: ValueKey(foodItem["id"]),
                                            foodItem: foodItem,
                                            quantity: foodItem["quantity"],
                                            isEditable: false,
                                            isSaveable: false,
                                            isDeleteable: false,
                                            enableQuantitySelection: true,
                                            onChangeQuantity: (updatedQuantity) {
                                              if (updatedQuantity.isEmpty) {
                                                foodItem["quantity"] = 100.0;
                                              }
                                              else {
                                                foodItem["quantity"] = double.parse(updatedQuantity);
                                              }
                                              _calculateNutritionalInfo();
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                )
                              : const Center(
                                  child: Text(
                                    "No hi ha ingredients afegits",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ]
              else ...[
                Column(
                  children: [
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
                ),
              ]
            ]
          ),
        ),
      ),
    );
  }
}