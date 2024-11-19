import 'package:eatnlift/custom_widgets/custom_button.dart';
import 'package:eatnlift/pages/nutrition/recipe_page.dart';
import 'package:eatnlift/services/api_nutrition_service.dart';
import 'package:flutter/material.dart';


class RecipeCard extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final bool isSelectable;
  final void Function(List<Map<String, dynamic>>)? onSelect;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.isSelectable = false,
    this.onSelect,
  });

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  late bool isCreator;
  bool isSaved = false;
  bool loading = true;
  bool isSelected = false;
  final TextEditingController quantityController = TextEditingController();

  Future<List<Map<String, dynamic>>> _getSelectedFoodItems() async {
    final apiService = ApiNutritionService();
    final result = await apiService.getRecipe(widget.recipe["id"]);

    if (result["success"] && result["recipe"]["recipe_food_items"] is List) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("S'han afegit els aliments de la recepta."),
            duration: const Duration(seconds: 3), // Display for 3 seconds
          ),
        );
      }

      // Explicitly cast each item to Map<String, dynamic> and add "selected": true
      return (result["recipe"]["recipe_food_items"] as List)
          .map((item) => {
                ...(item as Map<String, dynamic>),
                "id": item["food_item"],
                "selected": true,
              })
          .toList();
    } else {
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipePage(recipeId: widget.recipe["id"],),
          )
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.recipe['name'] ?? 'Desconegut',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Spacer(),
                  if (widget.isSelectable)
                    CustomButton(
                      text: "Afegeix",
                      width: 80,
                      height: 30,
                      onTap: () {
                        if (widget.onSelect != null) {
                          _getSelectedFoodItems().then((selectedFoodItems) {
                            widget.onSelect!(selectedFoodItems);
                          });
                        }
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}