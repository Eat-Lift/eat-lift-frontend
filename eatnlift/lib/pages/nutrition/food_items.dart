import 'package:flutter/material.dart';
import 'package:eatnlift/custom_widgets/food_item_card.dart';
import 'package:eatnlift/services/session_storage.dart';

class FoodItemsPage extends StatefulWidget {
  final List<Map<String, dynamic>> foodItems;

  const FoodItemsPage({
    super.key,
    required this.foodItems,
  });

  @override
  State<FoodItemsPage> createState() => _FoodItemsPageState();
}

class _FoodItemsPageState extends State<FoodItemsPage> {
  final SessionStorage sessionStorage = SessionStorage();
  String? currentUserId;
  Set<int> hiddenItems = {};

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserId();
  }

  Future<void> _fetchCurrentUserId() async {
    final userId = await sessionStorage.getUserId();
    setState(() {
      currentUserId = userId;
    });
  }

  void _updateFoodItem(Map<String, dynamic> updatedItem) {
    setState(() {
      final index = widget.foodItems.indexWhere((item) => item['id'] == updatedItem['id']);
      if (index != -1) {
        widget.foodItems[index] = updatedItem;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return Scaffold(
        backgroundColor: Colors.grey[300],
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text("Aliments"),
      ),
      body: ListView.builder(
        itemCount: widget.foodItems.length,
        itemBuilder: (context, index) {
          final foodItem = widget.foodItems[index];
          final isHidden = hiddenItems.contains(foodItem['id']);

          if (isHidden) return const SizedBox.shrink();

          return FoodItemCard(
            foodItem: foodItem,
            currentUserId: currentUserId!,
            onDelete: () {
              setState(() {
                hiddenItems.add(foodItem['id']);
              });
            },
            onUpdate: _updateFoodItem, 
          );
        },
      ),
    );
  }
}