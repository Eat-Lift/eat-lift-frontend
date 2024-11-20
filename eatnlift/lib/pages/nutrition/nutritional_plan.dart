import 'package:eatnlift/custom_widgets/custom_number.dart';
import 'package:eatnlift/custom_widgets/expandable_text.dart';
import 'package:eatnlift/custom_widgets/food_item_card.dart';
import 'package:eatnlift/pages/nutrition/recipe_edit.dart';
import 'package:eatnlift/services/api_nutrition_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../custom_widgets/expandable_image.dart';
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
  late List<Map<String, dynamic>> recipes;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
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
    if (result["success"]){
      recipes = result["recipes"];
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text("Pla nutricional"),
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
                ),
              ]
            ]
          ),
        ),
      ),
    );
  }
}