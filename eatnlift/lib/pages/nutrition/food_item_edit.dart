import 'package:flutter/material.dart';

import '../../custom_widgets/relative_sizedbox.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/messages_box.dart';
import '../../custom_widgets/custom_textfield.dart';

import '../../services/api_nutrition_service.dart';

class EditFoodItemPage extends StatefulWidget {
  final Map<String, dynamic> foodItem;

  const EditFoodItemPage({
    super.key,
    required this.foodItem,
  });

  @override
  EditFoodItemState createState() => EditFoodItemState();
}

class EditFoodItemState extends State<EditFoodItemPage> {
  late TextEditingController nameController;
  late TextEditingController caloriesController;
  late TextEditingController proteinsController;
  late TextEditingController fatsController;
  late TextEditingController carbohydratesController;

  Map<String, dynamic> response = {};

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.foodItem['name']);
    caloriesController = TextEditingController(text: widget.foodItem['calories'].toString());
    proteinsController = TextEditingController(text: widget.foodItem['proteins'].toString());
    fatsController = TextEditingController(text: widget.foodItem['fats'].toString());
    carbohydratesController = TextEditingController(text: widget.foodItem['carbohydrates'].toString());
  }

  void _submitData() async {
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

    final updatedFoodItem = {
      "name": nameController.text.trim(),
      "calories": calories,
      "proteins": proteins,
      "fats": fats,
      "carbohydrates": carbohydrates,
    };

    final apiService = ApiNutritionService();
    final result = await apiService.editFoodItem(updatedFoodItem, widget.foodItem['id'].toString());
    setState(() {
      response = result;
    });

    if (result["success"]) {
      _showSuccessDialog("L'aliment s'ha actualitzat correctament");
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Aliment Actualitzat"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop({
                  "id": widget.foodItem['id'],
                  "name": nameController.text.trim(),
                  "calories": double.tryParse(caloriesController.text) ?? 0,
                  "proteins": double.tryParse(proteinsController.text) ?? 0,
                  "fats": double.tryParse(fatsController.text) ?? 0,
                  "carbohydrates": double.tryParse(carbohydratesController.text) ?? 0,
                });
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
        title: const Text("Editar Aliment"),
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const RelativeSizedBox(height: 10),
              const Icon(
                Icons.fastfood,
                size: 100,
                color: Colors.black,
              ),
              const RelativeSizedBox(height: 0.5),
              Text(
                "Edita l'Aliment",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                ),
              ),
              const RelativeSizedBox(height: 2),
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
                      controller: carbohydratesController,
                      hintText: "Carbohidrats",
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
                ],
              ),
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
              ],
            ],
          ),
        ),
      ),
    );
  }
}