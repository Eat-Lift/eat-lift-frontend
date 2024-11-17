import 'dart:math';

import 'package:eatnlift/custom_widgets/expandable_text.dart';
import 'package:eatnlift/custom_widgets/food_item_card.dart';
import 'package:eatnlift/services/api_nutrition_service.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/expandable_image.dart';
import '../../custom_widgets/custom_textfield.dart';
import '../../custom_widgets/relative_sizedbox.dart';
import '../../custom_widgets/messages_box.dart';

import '../../services/api_user_service.dart';
import '../../services/session_storage.dart';
import '../../services/storage_service.dart';

class RecipePage extends StatefulWidget {
  final int recipeId;

  const RecipePage({
    super.key,
    required this.recipeId,
  });

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  late Map<String, dynamic>? recipeData = null;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecipeData();
  }

  void _fetchRecipeData() async {
    final apiService = ApiNutritionService();
    final recipe = await apiService.getRecipe(widget.recipeId);
    setState((){
      recipeData = recipe["recipe"];
      isLoading = false;
    });
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
              if (isLoading) ...[
                Align(
                  child: CircularProgressIndicator(),
                ),
              ]
              else ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RelativeSizedBox(height: 1),
                    Row(
                      children: [
                        ExpandableImage(
                          initialImageUrl: recipeData?["photo"],
                          width: 70,
                          height: 70,
                        ),
                        RelativeSizedBox(width: 5),
                        Text(
                          recipeData?["name"],
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 27,
                          ),
                        ),
                      ],
                    ),
                    RelativeSizedBox(height: 2),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ExpandableText(
                        text: recipeData?["description"]?.isEmpty ?? true
                            ? "Això està una mica buit"
                            : recipeData?["description"],
                      ),
                    ),
                    RelativeSizedBox(height: 2),
                    Container(
                      height: 600,
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
                                            key: ValueKey(Random().nextInt(1000000)),
                                            foodItem: foodItem,
                                            quantity: foodItem["grams"],
                                            isEditable: false,
                                            isSaveable: false,
                                            isDeleteable: false,
                                            enableQuantitySelection: true,
                                            onChangeQuantity: (updatedQuantity) {
                                              if (updatedQuantity.isEmpty) {
                                                foodItem["quantity"] = 100;
                                              }
                                              else {
                                                foodItem["quantity"] = double.parse(updatedQuantity);
                                              }
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
            ]
          ),
        ),
      ),
    );
  }
}