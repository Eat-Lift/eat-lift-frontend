import 'package:flutter/material.dart';

class FoodItemCard extends StatelessWidget {
  final Map<String, dynamic> foodItem;

  const FoodItemCard({
    super.key,
    required this.foodItem
  });

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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              foodItem['name'] ?? 'Unknown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text('Caloríes: ${foodItem['calories'] ?? 'N/A'} kcal',
                style: TextStyle(color: Colors.grey[600])),
            Text('Proteïnes: ${foodItem['proteins'] ?? 'N/A'} g',
                style: TextStyle(color: Colors.grey[600])),
            Text('Greixos: ${foodItem['fats'] ?? 'N/A'} g',
                style: TextStyle(color: Colors.grey[600])),
            Text('Carbohidrats: ${foodItem['carbohydrates'] ?? 'N/A'} g',
                style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}