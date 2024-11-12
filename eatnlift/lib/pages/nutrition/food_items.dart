import 'package:flutter/material.dart';
import 'package:eatnlift/custom_widgets/food_item_card.dart';

class FoodItemsPage extends StatelessWidget {
  final List<Map<String, dynamic>> foodItems;

  const FoodItemsPage({
    super.key,
    required this.foodItems
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text("Aliments"),
      ),
      body: ListView.builder(
        itemCount: foodItems.length,
        itemBuilder: (context, index) {
          return FoodItemCard(foodItem: foodItems[index]);
        },
      ),
    );
  }
}