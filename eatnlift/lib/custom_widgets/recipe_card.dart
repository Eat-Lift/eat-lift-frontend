import 'package:eatnlift/pages/nutrition/recipe_page.dart';
import 'package:flutter/material.dart';


class RecipeCard extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const RecipeCard({
    super.key,
    required this.recipe,
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}