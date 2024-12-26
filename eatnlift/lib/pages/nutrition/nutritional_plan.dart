import 'package:eatnlift/custom_widgets/recipes_container.dart';
import 'package:eatnlift/custom_widgets/rotating_logo.dart';
import 'package:eatnlift/custom_widgets/round_button.dart';
import 'package:eatnlift/pages/nutrition/nutritional_plan_edit.dart';
import 'package:eatnlift/services/api_nutrition_service.dart';
import 'package:flutter/material.dart';

import '../../custom_widgets/relative_sizedbox.dart';

import '../../services/session_storage.dart';

class NutritionalPlanPage extends StatefulWidget {
  const NutritionalPlanPage({
    super.key,
  });

  @override
  State<NutritionalPlanPage> createState() => _NutritionalPlanPageState();
}

class _NutritionalPlanPageState extends State<NutritionalPlanPage> {
  final SessionStorage sessionStorage = SessionStorage();
  String? currentUserId;
  bool isLoading = true;
  List<Map<String, dynamic>> recipes = [];

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
    await _fetchNutritionalPlan();
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

  Future<void> _fetchNutritionalPlan() async {
    final apiService = ApiNutritionService();
    final result = await apiService.getNutritionalPlan(currentUserId!);

    if (result["success"]) {
      setState(() {
        recipes = (result["recipes"] as List)
            .expand((item) => (item["recipes"] as List))
            .map<Map<String, dynamic>>((recipe) {
              final updatedRecipe = Map<String, dynamic>.from(recipe);
              updatedRecipe["name"] = updatedRecipe.remove("recipe_name");
              updatedRecipe["id"] = updatedRecipe.remove("recipe_id");
              updatedRecipe["selected"] = true;
              return updatedRecipe;
            })
            .toList();
      });
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text("Pla nutricional"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: RoundButton(
              icon: Icons.edit,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditNutritionalPlanPage(recipes: recipes)),
                );
                if (result == true){
                  _fetchNutritionalPlan();
                }
              },
              size: 35,
            ),
          ),
        ],     
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Stack(
              children: [
                if(!isLoading) ...[
                  Column(
                    children: [
                      RelativeSizedBox(height: 1),
                      RecipesContainer(
                        recipes: recipes.where((recipe) => recipe["meal_type"] == "ESMORZAR").toList(),
                        title: "Esmorzar",
                      ),
                      RelativeSizedBox(height: 1),
                      RecipesContainer(
                        recipes: recipes.where((recipe) => recipe["meal_type"] == "DINAR").toList(),
                        title: "Dinar",
                      ),
                      RelativeSizedBox(height: 1),
                      RecipesContainer(
                        recipes: recipes.where((recipe) => recipe["meal_type"] == "BERENAR").toList(),
                        title: "Berenar",
                      ),
                      RelativeSizedBox(height: 1),
                      RecipesContainer(
                        recipes: recipes.where((recipe) => recipe["meal_type"] == "SOPAR").toList(),
                        title: "Sopar",
                      ),
                      RelativeSizedBox(height: 3),
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
      ),
    );
  }
}