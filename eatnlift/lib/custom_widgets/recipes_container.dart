import 'package:eatnlift/custom_widgets/recipe_card.dart';
import 'package:eatnlift/custom_widgets/round_button.dart';
import 'package:eatnlift/pages/nutrition/nutrition_search.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RecipesContainer extends StatefulWidget {
  final List<Map<String, dynamic>> recipes;
  final double height;
  final String? title;
  final bool isUpdating;
  final Function(List<Map<String,dynamic>>?, String)? onCheck;

  const RecipesContainer({
    super.key,
    required this.recipes,
    this.height = 140,
    this.title,
    this.isUpdating = false,
    this.onCheck,
  });

  @override
  State<RecipesContainer> createState() => _RecipesContainerState();
}

class _RecipesContainerState extends State<RecipesContainer> {
  late bool isCreator;
  bool isSaved = false;
  bool loading = true;
  bool isSelected = false;
  final TextEditingController quantityController = TextEditingController();
  List<Map<String, dynamic>> selectedRecipes = [];

  @override
  void initState() {
    super.initState();
  }

  void onCheck(List<Map<String, dynamic>>? fromSearchRecipes) {
    if (fromSearchRecipes != null) {
      for (var recipe in fromSearchRecipes) {
        recipe["meal_type"] = widget.title!.toUpperCase();
      }
    }

    setState(() {
      selectedRecipes = fromSearchRecipes ?? [];
    });
    widget.onCheck!(selectedRecipes, widget.title!.toUpperCase());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,    
      children: [
          if (widget.title != null) ...[
            Text(
              widget.title ?? "",
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          Container(
            height: widget.height,
            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 7.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Stack(
            children: [
              widget.recipes.isNotEmpty
                  ? ListView.builder(
                      itemCount: widget.recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = widget.recipes[index];
                        return Row(
                          children: [
                            Expanded(
                              child: RecipeCard(
                                key: ValueKey(recipe['id']),
                                recipe: recipe,
                                isSelectable: widget.isUpdating,
                                initiallySelected: widget.recipes.firstWhere(
                                  (selectedItem) => selectedItem['id'] == recipe['id'],
                                  orElse: () => {'selected': false},
                                )['selected'] ??
                                false,
                                onSelect: (value) {
                                  setState((){
                                    selectedRecipes.removeWhere((selected) => selected['id'] == recipe['id']);
                                    widget.recipes.removeAt(index);
                                    widget.onCheck!(selectedRecipes, widget.title!.toUpperCase());
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        "No hi ha receptes afegides",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
              if (widget.isUpdating) ...[
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: RoundButton(
                    icon: FontAwesomeIcons.plus,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NutritionSearchPage(isCreating: true, onCheck: onCheck, searchFoodItems: false, selectedRecipes: widget.recipes,),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ]
    );
  }
}