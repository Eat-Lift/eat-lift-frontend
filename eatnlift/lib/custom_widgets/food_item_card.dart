import 'package:eatnlift/custom_widgets/relative_sizedbox.dart';
import 'package:eatnlift/services/api_nutrition_service.dart';
import 'package:flutter/material.dart';

class FoodItemCard extends StatefulWidget {
  final Map<String, dynamic> foodItem;
  final String currentUserId;
  final VoidCallback onDelete;

  const FoodItemCard({
    super.key,
    required this.foodItem,
    required this.currentUserId,
    required this.onDelete,
  });

  @override
  State<FoodItemCard> createState() => _FoodItemCardState();
}

class _FoodItemCardState extends State<FoodItemCard> {
  final ApiNutritionService apiNutritionService = ApiNutritionService();
  late bool isCreator;
  bool isSaved = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    isCreator = widget.foodItem['creator'].toString() == widget.currentUserId;
    _fetchSavedState();
  }

  Future<void> _fetchSavedState() async {
    final response = await apiNutritionService.getFoodItemSaved(widget.foodItem["id"].toString());
    final bool saved = response["is_saved"];
    setState(() {
      isSaved = saved;
      loading = false;
    });
  }

  void _toggleSave() async {
    final Map<String, dynamic> response;
    if (isSaved) {
      response = await apiNutritionService.unsaveFoodItem(widget.foodItem["id"].toString());
    }
    else {
      response = await apiNutritionService.saveFoodItem(widget.foodItem["id"].toString());
    }

    if (response["success"]) {
      setState(() {
        isSaved = !isSaved;
      });
    }
  }

  void _deleteFoodItem() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmació"),
          content: const Text("Estàs segur que vols eliminar aquest aliment?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel·lar"),
            ),
            TextButton(
                onPressed: () async {
                Navigator.of(context).pop();
                final response = await apiNutritionService.deleteFoodItem(widget.foodItem["id"].toString());

                if (response["success"]){
                  widget.onDelete();
                  _showResultDialog("L'aliment s'ha eliminat correctament");
                }
                else {
                  _showResultDialog("No s'ha pogut eliminar l'aliment. Torna-ho a intentar");
                }  
              },
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }

  void _showResultDialog(String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Eliminar"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Tancar"),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.foodItem['name'] ?? 'Desconegut',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                if (isCreator) ...[
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    tooltip: 'Edit',
                    onPressed: () {
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.black),
                    tooltip: 'Delete',
                    onPressed: _deleteFoodItem,
                  ),
                ],
                if (!loading) ...[
                  IconButton(
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.black,
                    ),
                    tooltip: isSaved ? 'Unsave' : 'Save',
                    onPressed: _toggleSave,
                  ),
                ]
                else ...[
                  IconButton(
                    icon: Icon(
                      Icons.bookmark ,
                      color: Colors.grey.shade200,
                    ),
                    onPressed: (){},
                  ),
                ]
              ],
            ),
            const RelativeSizedBox(height: 0.1),
            Text(
              'Caloríes: ${widget.foodItem['calories'] ?? 'N/A'} kcal',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              'Proteïnes: ${widget.foodItem['proteins'] ?? 'N/A'} g',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              'Greixos: ${widget.foodItem['fats'] ?? 'N/A'} g',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              'Carbohidrats: ${widget.foodItem['carbohydrates'] ?? 'N/A'} g',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const RelativeSizedBox(height: 2),
          ],
        ),
      ),
    );
  }
}