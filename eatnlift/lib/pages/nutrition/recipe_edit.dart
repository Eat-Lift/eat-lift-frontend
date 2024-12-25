import 'dart:io';

import 'package:eatnlift/custom_widgets/custom_number.dart';
import 'package:eatnlift/custom_widgets/food_item_card.dart';
import 'package:eatnlift/custom_widgets/messages_box.dart';
import 'package:eatnlift/custom_widgets/rotating_logo.dart';
import 'package:eatnlift/custom_widgets/round_button.dart';
import 'package:eatnlift/pages/nutrition/nutrition_search.dart';
import 'package:eatnlift/services/api_nutrition_service.dart';
import 'package:eatnlift/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:eatnlift/custom_widgets/relative_sizedbox.dart';
import 'package:eatnlift/custom_widgets/custom_button.dart';
import 'package:eatnlift/custom_widgets/custom_textfield.dart';
import 'package:eatnlift/custom_widgets/expandable_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EditRecipePage extends StatefulWidget {
  final Map<String, dynamic>? recipeData;

  const EditRecipePage({
    super.key,
    required this.recipeData,
  });

  @override
  State<EditRecipePage> createState() => _EditRecipePageState();
}

class _EditRecipePageState extends State<EditRecipePage> {
  late TextEditingController recipeNameController;
  late TextEditingController descriptionController;
  File? _selectedImage;
  String? initialImagePath;
  bool isCreating = false;
  List<Map<String, dynamic>> selectedFoodItems = [];

  bool isUpdating = false;
  Map<String, dynamic> response = {};

  double calories = 0;
  double proteins = 0;
  double fats = 0;
  double carbohydrates = 0;

  @override
  void initState() {
    super.initState();
    recipeNameController = TextEditingController(text: widget.recipeData?["name"]);
    descriptionController = TextEditingController(text: widget.recipeData?["description"]);
    initialImagePath = widget.recipeData?["picture"];
    if (widget.recipeData?["recipe_food_items"] is List) {
      for (var recipeFoodItem in widget.recipeData?["recipe_food_items"] ?? []) {
        if (recipeFoodItem is Map<String, dynamic>) {
          recipeFoodItem["selected"] = true;
          recipeFoodItem["id"] = recipeFoodItem["food_item"];
          selectedFoodItems.add(recipeFoodItem);
        }
      }
    }
    _calculateNutritionalInfo();
  }

  @override
  void dispose() {
    recipeNameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void onCheck(List<Map<String, dynamic>>? fromSearchFoodItems) {
    setState(() {
      selectedFoodItems = fromSearchFoodItems!;
    });
    Navigator.pop(context);
    _calculateNutritionalInfo();
  }

  void _submitUpdatedRecipe() async {
    bool emptyField = false;
    response = {};


    if (recipeNameController.text.trim().isEmpty) {
      response["success"] = false;
      if (response.containsKey('errors')) {
        response['errors'].add("Es requereix el nom de la recepta");
      } else {
        response['errors'] = ["Es requereix el nom de la recepta"];
      }
      emptyField = true;
    }

    if (selectedFoodItems.length < 2){
      response["success"] = false;
      if (response.containsKey('errors')) {
        response['errors'].add("Es requereixen al menys 2 aliments");
      } else {
        response['errors'] = ["Es requereixen al menys 2 aliments"];
      }
      emptyField = true;
    }

    if (emptyField) {
      setState(() {});
      return;
    }

    final recipe = {
      "name": recipeNameController.text.trim(),
      "description": descriptionController.text,
      "picture": widget.recipeData?["picture"],
      "food_items": selectedFoodItems.map((item) {
        return {
          "food_item": item["id"],
          "quantity": item["quantity"]
        };
      }).toList()
    };

    String? updatedImageURL;
    if (_selectedImage != null) {
      setState(() {
        isCreating = true;
      });

      final storageService = StorageService();
      updatedImageURL = await storageService.uploadImage(
        _selectedImage!,
        'recipes/${_selectedImage!.path.split('/').last}',
      );

      setState(() {
        isCreating = false;
      });

      recipe['picture'] = updatedImageURL!;
    }

    String recipeId = widget.recipeData?["id"]?.toString() ?? "0";

    final apiService = ApiNutritionService();
    final result = await apiService.editRecipe(recipe, recipeId);
    if (result["success"]) {
      if (mounted){
        Navigator.pop(context, true);
      }
    }
    else {
      setState(() {
        response = result;
      });
    }
  }

  void _calculateNutritionalInfo() {
    calories = 0;
    proteins = 0;
    fats = 0;
    carbohydrates = 0;

    for (Map<String, dynamic> foodItem in selectedFoodItems) {
      calories += (foodItem["quantity"] * foodItem["calories"]) / 100;
      proteins += (foodItem["quantity"] * foodItem["proteins"]) / 100;
      fats += (foodItem["quantity"] * foodItem["fats"]) / 100;
      carbohydrates += (foodItem["quantity"] * foodItem["carbohydrates"]) / 100;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text("Editar recepta"),
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ExpandableImage(
                initialImageUrl: initialImagePath,
                onImageSelected: (imageFile) {
                  setState(() {
                    _selectedImage = imageFile;
                  });
                },
                editable: true,
                width: 70,
                height: 70,
              ),
              const RelativeSizedBox(height: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomNumber(number: calories, width: 330, icon: Icons.local_fire_department, unit: "kcal", isCentered: true, size: 13),
                  RelativeSizedBox(height: 0.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: CustomNumber(number: proteins, width: 107, icon: FontAwesomeIcons.drumstickBite, unit: "g", size: 13),
                      ),
                      RelativeSizedBox(width: 1),
                      Expanded(
                        child: CustomNumber(number: carbohydrates, width: 107, icon: FontAwesomeIcons.wheatAwn, unit: "g", size: 13),

                      ),
                      RelativeSizedBox(width: 1),
                      Expanded(
                        child: CustomNumber(number: fats, width: 107, icon: Icons.water_drop, unit: "g", size: 13),
                      ),
                    ],
                  ),
                ],
              ),
              const RelativeSizedBox(height: 2),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextfield(
                    controller: recipeNameController,
                    hintText: "Nom",
                    maxLength: 50,
                  ),
                  const RelativeSizedBox(height: 0.5),
                  CustomTextfield(
                    controller: descriptionController,
                    hintText: "Descripció",
                    maxLength: 300,
                    maxLines: 3,
                  ),
                  const RelativeSizedBox(height: 1),
                  Container(
                    height: 180,
                    padding: const EdgeInsets.all(7.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Stack(
                      children: [
                        selectedFoodItems.isNotEmpty
                            ? ListView.builder(
                                itemCount: selectedFoodItems.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == selectedFoodItems.length) {
                                    return const RelativeSizedBox(height: 8);
                                  }
                                  final foodItem = selectedFoodItems[index];
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: FoodItemCard(
                                          key: ValueKey(foodItem["id"]),
                                          foodItem: foodItem,
                                          onSelect: (value) {
                                            setState(() {
                                              selectedFoodItems.removeAt(index);
                                            });
                                            _calculateNutritionalInfo();
                                          },
                                          quantity: foodItem["quantity"],
                                          initiallySelected: true,
                                          isSelectable: true,
                                          isEditable: false,
                                          isSaveable: false,
                                          isDeleteable: true,
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
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: RoundButton(
                            icon: FontAwesomeIcons.plus,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NutritionSearchPage(isCreating: true, selectedFoodItems: selectedFoodItems, onCheck: onCheck),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

              const RelativeSizedBox(height: 2),
              CustomButton(
                text: "Actualitzar recepta",
                onTap: _submitUpdatedRecipe,
              ),
              const RelativeSizedBox(height: 2),
              if (isCreating) ...[
                Align(
                  alignment: Alignment.center,
                  child: RotatingImage(),
                ),
                const RelativeSizedBox(height: 2),
              ]
              else ...[
                if (response.isNotEmpty && !response["success"]) ...[
                  MessagesBox(
                    messages: response["errors"],
                    height: 6,
                    color: Colors.red,
                  ),
                  const RelativeSizedBox(height: 4)
                ] else ...[
                  const RelativeSizedBox(height: 5)
                ]
              ],
            ],
          ),
        ],
          ),
        ),
      ),
    );
  }
}
