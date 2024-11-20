import 'package:eatnlift/custom_widgets/recipes_container.dart';
import 'package:eatnlift/custom_widgets/round_button.dart';
import 'package:eatnlift/services/api_nutrition_service.dart';
import 'package:flutter/material.dart';

import '../../custom_widgets/relative_sizedbox.dart';

import '../../services/session_storage.dart';

class EditNutritionalPlanPage extends StatefulWidget {
  final List<Map<String, dynamic>> recipes;

  const EditNutritionalPlanPage({
    super.key,
    required this.recipes,
  });

  @override
  State<EditNutritionalPlanPage> createState() => _EditNutritionalPlanPageState();
}

class _EditNutritionalPlanPageState extends State<EditNutritionalPlanPage> {
  final SessionStorage sessionStorage = SessionStorage();
  String? currentUserId;
  bool isLoading = true;
  List<Map<String, dynamic>> recipes = [];

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  void submitEdit() async {
    // Change 'id' to 'recipe_id' in each recipe
    final updatedRecipes = recipes.map((recipe) {
      if (recipe.containsKey("id")) {
        recipe["recipe_id"] = recipe["id"]; // Copy the value to 'recipe_id'
        recipe.remove("id"); // Remove the old 'id' key
        recipe["meal_type"] = recipe["meal_type"].toString().toUpperCase();
      }
      return recipe;
    }).toList();

    final apiService = ApiNutritionService();
    await apiService.editNutritionalPlan(currentUserId!, updatedRecipes);
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  void onCheck(List<Map<String, dynamic>>? fromContainerRecipes, String meal_type) {
    if (fromContainerRecipes != null) {
      setState(() {        
        recipes = recipes.where((recipe) => recipe["meal_type"] != meal_type).toList();

        recipes.addAll(fromContainerRecipes);
      });
    }
  }

  Future<void> _initializePage() async {
    await _fetchCurrentUserId(); 
    setState(() {
      recipes = widget.recipes;
      isLoading = false;
    });
  }

  Future<void> _fetchCurrentUserId() async {
    final userId = await sessionStorage.getUserId();
    setState(() {
      currentUserId = userId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text("Pla nutricional"),
        actions: 
          [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: RoundButton(
                icon: Icons.check,
                onPressed: submitEdit,
                size: 35,
              ),
            ),
          ],     
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
                  children: [
                    RelativeSizedBox(height: 2),
                    RecipesContainer(
                      recipes: recipes.where((recipe) => recipe["meal_type"] == "ESMORZAR").toList(),
                      title: "Esmorzar",
                      isUpdating: true,
                      onCheck: onCheck,
                    ),
                    RelativeSizedBox(height: 2),
                    RecipesContainer(
                      recipes: recipes.where((recipe) => recipe["meal_type"] == "DINAR").toList(),
                      title: "Dinar",
                      isUpdating: true,
                      onCheck: onCheck,
                    ),
                    RelativeSizedBox(height: 2),
                    RecipesContainer(
                      recipes: recipes.where((recipe) => recipe["meal_type"] == "BERENAR").toList(),
                      title: "Berenar",
                      isUpdating: true,
                      onCheck: onCheck,
                    ),
                    RelativeSizedBox(height: 2),
                    RecipesContainer(
                      recipes: recipes.where((recipe) => recipe["meal_type"] == "SOPAR").toList(),
                      title: "Sopar",
                      isUpdating: true,
                      onCheck: onCheck,
                    ),
                    RelativeSizedBox(height: 2),
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