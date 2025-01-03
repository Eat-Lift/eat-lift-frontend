import 'package:eatnlift/custom_widgets/custom_number.dart';
import 'package:eatnlift/custom_widgets/food_item_card.dart';
import 'package:eatnlift/custom_widgets/rotating_logo.dart';
import 'package:eatnlift/custom_widgets/round_button.dart';
import 'package:eatnlift/pages/nutrition/nutrition_search.dart';
import 'package:eatnlift/pages/nutrition/recipe_page.dart';
import 'package:eatnlift/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';

import '../../custom_widgets/relative_sizedbox.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/messages_box.dart';
import '../../custom_widgets/custom_textfield.dart';
import '../../custom_widgets/expandable_image.dart';
import '../../custom_widgets/ying_yang_toggle.dart';

import '../../services/api_nutrition_service.dart';

class NutritionCreatePage extends StatefulWidget {
  const NutritionCreatePage({super.key});

  @override
  NutritionCreateState createState() => NutritionCreateState();
}

class NutritionCreateState extends State<NutritionCreatePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController proteinsController = TextEditingController();
  final TextEditingController fatsController = TextEditingController();
  final TextEditingController carbohydratesController = TextEditingController();

  List<Map<String, dynamic>> selectedFoodItems = [];
  
  final TextEditingController recipeNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  File? _selectedImage;
  String? initialImagePath;

  bool isCreatingFoodItem = true;
  Map<String, dynamic> response = {};
  int key = 0;

  bool isCreating = false;

  double calories = 0;
  double proteins = 0;
  double fats = 0;
  double carbohydrates = 0;

  void toggleCreateMode(bool isFoodItemSelected) {
    setState(() {
      response = {};
      isCreatingFoodItem = isFoodItemSelected;
    });
  }

  void _submitData() async {
    if (isCreatingFoodItem) {
      bool emptyField = false;
      response = {};


      if (nameController.text.trim().isEmpty) {
        response["success"] = false;
        if (response.containsKey('errors')) {
          response['errors'].add("Es requereix el nom de l'aliment");
        } else {
          response['errors'] = ["Es requereix el nom de l'aliment"];
        }
        emptyField = true;
      }

      final calories = double.tryParse(caloriesController.text) ?? 0;
      if (caloriesController.text.isEmpty || calories <= 0) {
        response["success"] = false;
        if (response.containsKey('errors')) {
          response['errors'].add("Es requereixen les calories");
        } else {
          response['errors'] = ["Es requereixen les calories"];
        }
        emptyField = true;
      }

      final proteins = double.tryParse(proteinsController.text) ?? 0;
      if (proteinsController.text.isEmpty || proteins <= 0) {
        response["success"] = false;
        if (response.containsKey('errors')) {
          response['errors'].add("Es requereixen les proteïnes");
        } else {
          response['errors'] = ["Es requereixen les proteïnes"];
        }
        emptyField = true;
      }

      final fats = double.tryParse(fatsController.text) ?? 0;
      if (fatsController.text.isEmpty || fats <= 0) {
        response["success"] = false;
        if (response.containsKey('errors')) {
          response['errors'].add("Es requereixen els greixos");
        } else {
          response['errors'] = ["Es requereixen els greixos"];
        }
        emptyField = true;
      }

      final carbohydrates = double.tryParse(carbohydratesController.text) ?? 0;
      if (carbohydratesController.text.isEmpty || carbohydrates <= 0) {
        response["success"] = false;
        if (response.containsKey('errors')) {
          response['errors'].add("Es requereixen els carbohidrats");
        } else {
          response['errors'] = ["Es requereixen els carbohidrats"];
        }
        emptyField = true;
      }

      final estimatedCalories = (proteins * 4) + (fats * 9) + (carbohydrates * 4);
      if ((calories - estimatedCalories).abs() > 50) {
        response["success"] = false;
        if (response.containsKey('errors')) {
          response['errors'].add("Les calories no coincideixen amb els macronutrients");
        } else {
          response['errors'] = ["Les calories no coincideixen amb els macronutrients"];
        }
        emptyField = true;
      }

      if (emptyField) {
        setState(() {});
        return;
      }

      final foodItem = {
        "name": nameController.text.trim(),
        "calories": calories,
        "proteins": proteins,
        "fats": fats,
        "carbohydrates": carbohydrates,
      };

      final apiService = ApiNutritionService();
      final result = await apiService.createFoodItem(foodItem);
      setState(() {
        response = result;
      });

      if (result["success"]){
        _showSuccessDialog("L'aliment s'ha creat correctament");
      }
    } else {
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

      final apiService = ApiNutritionService();
      final result = await apiService.createRecipe(recipe);
      if (result["success"]) {
        if (mounted){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RecipePage(recipeId: result["recipeId"]),
            ),
          );
        }
      }
      else {
        setState(() {
          response = result;
        });
      }
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Aliment creat"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text("Tanca"),
            ),
          ],
        );
      },
    );
  }

  void onCheck(List<Map<String, dynamic>>? fromSearchFoodItems) {
    setState(() {
      selectedFoodItems = fromSearchFoodItems!;
    });
    Navigator.pop(context);
    _calculateNutritionalInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text("Crear"),
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isCreatingFoodItem) ...[
                  RelativeSizedBox(height: 10),
                  const Icon(
                    Icons.fastfood,
                    size: 100,
                    color: Colors.black,
                  ),
                ] else ...[
                  Align(
                    alignment: Alignment.center,
                    child: ExpandableImage(
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
                  ),
                ],
                const RelativeSizedBox(height: 0.5),
                Text(
                  isCreatingFoodItem ? "Crea un aliment" : "Crea una recepta",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                const RelativeSizedBox(height: 2),
                YinYangToggle(
                  isLeftSelected: isCreatingFoodItem,
                  leftText: "Aliment",
                  rightText: "Recepta",
                  onToggle: toggleCreateMode,
                  height: 57,
                ),
                const RelativeSizedBox(height: 2),
                if (isCreatingFoodItem) ...[
                  _buildFoodItemForm(),
                ] else ...[
                  _buildRecipeForm(),
                ],
                const RelativeSizedBox(height: 2),
                CustomButton(
                  text: isCreatingFoodItem ? "Crear aliment" : "Crear recepta",
                  onTap: _submitData,
                ),
                const RelativeSizedBox(height: 2),
                if (isCreating) ...[
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        RotatingImage(),   
                      ],
                    ),
                  ),
                  const RelativeSizedBox(height: 2),
                ] else ...[
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
          ),
        ),
      ),
    );
  }
  
  Widget _buildFoodItemForm() {
    return Column(
      children: [
        CustomTextfield(
          controller: nameController,
          hintText: "Nom",
          centerText: true,
          maxLength: 60,
        ),
        const RelativeSizedBox(height: 0.5),
        CustomTextfield(
          controller: caloriesController,
          hintText: "Caloríes",
          hintIcon: Icons.local_fire_department,
          isNumeric: true,
          maxLength: 6,
          unit: "kcal",
          centerText: true,
          allowDecimal: true,
        ),
        const RelativeSizedBox(height: 0.5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: CustomTextfield(
                controller: proteinsController,
                hintText: "Proteïnes",
                hintIcon: FontAwesomeIcons.drumstickBite,
                isNumeric: true,
                maxLength: 6,
                unit: "g",
                centerText: true,
                allowDecimal: true,
              ),
            ),
            const RelativeSizedBox(width: 1),
            Expanded(
              child: CustomTextfield(
                controller: carbohydratesController,
                hintText: "Carbohidrats",
                hintIcon: FontAwesomeIcons.wheatAwn,
                isNumeric: true,
                maxLength: 6,
                unit: "g",
                centerText: true,
                allowDecimal: true,
              ),
            ),
            const RelativeSizedBox(width: 1),
            Expanded(
              child: CustomTextfield(
                controller: fatsController,
                hintText: "Greixos",
                hintIcon: Icons.water_drop,
                isNumeric: true,
                maxLength: 6,
                unit: "g",
                centerText: true,
                allowDecimal: true,
              ),
            ),
          ],
        ),
      ],
    );
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

  Widget _buildRecipeForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        CustomTextfield(
          controller: recipeNameController,
          hintText: "Nom",
          maxLength: 60,
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
                                key: ValueKey(foodItem["id"] + key + index),
                                foodItem: foodItem,
                                onSelect: (value) {
                                  setState(() {
                                    selectedFoodItems.removeAt(index);
                                  });
                                },
                                quantity: foodItem["quantity"],
                                initiallySelected: true,
                                isSelectable: true,
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
                    ).then((_){
                      ++key;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}