import 'dart:ffi';

import 'package:eatnlift/custom_widgets/ying_yang_toggle.dart';
import 'package:flutter/material.dart';

import '../../custom_widgets/relative_sizedbox.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/messages_box.dart';
import '../../custom_widgets/custom_textfield.dart';

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

  bool isCreatingFoodItem = true;
  Map<String, dynamic> response = {};

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
    } else {
      final recipe = {
        "name": nameController.text.trim(),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const RelativeSizedBox(height: 1),
              const Icon(
                Icons.fastfood,
                size: 100,
                color: Colors.black,
              ),
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
                _buildRecipeFormPlaceholder(),
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

  Widget _buildRecipeFormPlaceholder() {
    return Column(
      children: const [
        Text(
          "Aquí anirà el formulari per crear una recepta.",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ],
    );
  }
}