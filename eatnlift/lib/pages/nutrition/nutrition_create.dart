import 'package:eatnlift/custom_widgets/food_item_card.dart';
import 'package:eatnlift/custom_widgets/round_button.dart';
import 'package:eatnlift/pages/nutrition/nutrition_search.dart';
import 'package:eatnlift/services/session_storage.dart';
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

  List<Map<String, dynamic>> foodItems = [
    {
      "id": 1,
      "name": "Chicken Breast",
      "calories": 165,
      "proteins": 31,
      "fats": 3.6,
      "carbohydrates": 0,
      "quantity": 100
    },
    {
      "id": 2,
      "name": "Rice",
      "calories": 130,
      "proteins": 2.7,
      "fats": 0.3,
      "carbohydrates": 28,
      "quantity": 200
    }
  ];
  final TextEditingController recipeNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  File? _selectedImage;
  String? initialImagePath;

  bool isCreatingFoodItem = true;
  Map<String, dynamic> response = {};
  List<Map<String, dynamic>> selectedFoodItems = [];

  void toggleCreateMode(bool isFoodItemSelected) {
    setState(() {
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

      final calories = int.tryParse(caloriesController.text) ?? 0;
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
      final recipe = {
        "name": nameController.text.trim(),
      };
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Aliment Creat"),
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
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isCreatingFoodItem) ...[
                const Icon(
                  Icons.fastfood,
                  size: 100,
                  color: Colors.black,
                ),
              ] else ...[
                ExpandableImage(
                  initialImageUrl: initialImagePath,
                  onImageSelected: (imageFile) {
                    setState(() {
                      _selectedImage = _selectedImage;
                    });
                  },
                  editable: true,
                  width: 70,
                  height: 70,
                ),
              ],
              const RelativeSizedBox(height: 0.5),
              Text(
                isCreatingFoodItem ? "Crea un Aliment" : "Crea una Recepta",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                ),
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
                text: "Enviar",
                onTap: _submitData,
              ),
              const RelativeSizedBox(height: 2),
              if (response.isNotEmpty && !response["success"]) ...[
                MessagesBox(
                  messages: response["errors"],
                  height: 12,
                  color: Colors.red,
                ),
                const RelativeSizedBox(height: 4)
              ] else ...[
                const RelativeSizedBox(height: 15)
              ]
            ],
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
          maxLength: 30,
        ),
        const RelativeSizedBox(height: 0.5),
        CustomTextfield(
                controller: caloriesController,
                hintText: "Caloríes",
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

  Widget _buildRecipeForm() {
    return Column(
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
          height: 200,
          padding: const EdgeInsets.all(1.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: Stack(
            children: [
              foodItems.isNotEmpty
                  ? ListView.builder(
                      itemCount: foodItems.length,
                      itemBuilder: (context, index) {
                        final foodItem = foodItems[index];
                        return Row(
                          children: [
                            Expanded(
                              child: FoodItemCard(
                                foodItem: foodItem,
                                onDelete: () {
                                  setState(() {
                                    foodItems.removeAt(index);
                                  });
                                },
                                onUpdate: (updatedItem) {
                                  setState(() {
                                    foodItems[index] = updatedItem;
                                  });
                                },
                                isSelectable: true,
                                isEditable: false,
                                isSaveable: false,
                                isDeleteable: true,
                                enableQuantitySelection: true,
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        "No hi ha ingredients afegits.",
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
                        builder: (context) => const NutritionSearchPage(),
                      ),
                    );
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