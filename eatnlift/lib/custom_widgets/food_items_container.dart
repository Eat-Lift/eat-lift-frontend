import 'dart:math';

import 'package:eatnlift/custom_widgets/food_item_card.dart';
import 'package:eatnlift/custom_widgets/round_button.dart';
import 'package:eatnlift/pages/nutrition/nutrition_search.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FoodItemsContainer extends StatefulWidget {
  final List<Map<String, dynamic>> foodItems;

  const FoodItemsContainer({
    super.key,
    required this.foodItems,
  });

  @override
  State<FoodItemsContainer> createState() => _FoodItemsContainerState();
}

class _FoodItemsContainerState extends State<FoodItemsContainer> {
  late bool isCreator;
  bool isSaved = false;
  bool loading = true;
  bool isSelected = false;
  final TextEditingController quantityController = TextEditingController();
  List<Map<String, dynamic>> selectedFoodItems = [];

  @override
  void initState() {
    super.initState();
  }

  void onCheck(List<Map<String, dynamic>>? fromSearchFoodItems) {
    setState(() {
      selectedFoodItems = fromSearchFoodItems!;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 340,
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 7.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 3),
        ),
        child: Stack(
        children: [
          widget.foodItems.isNotEmpty
              ? ListView.builder(
                  itemCount: widget.foodItems.length,
                  itemBuilder: (context, index) {
                    final foodItem = widget.foodItems[index];
                    return Row(
                      children: [
                        Expanded(
                          child: FoodItemCard(
                            key: ValueKey(Random().nextInt(1000000)),
                            foodItem: foodItem,
                            onSelect: (value) {
                              setState(() {
                                selectedFoodItems.removeAt(index);
                              });
                            },
                            quantity: foodItem["quantity"],
                            initiallySelected: true,
                            isSelectable: true,
                            isEditable: false,
                            isSaveable: false,
                            isDeleteable: true,
                            enableQuantitySelection: true,
                            onChangeQuantity: (updatedQuantity) {
                              if (updatedQuantity.isEmpty) {
                                foodItem["quantity"] = 100;
                              }
                              else {
                                foodItem["quantity"] = double.parse(updatedQuantity);
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  },
                )
              : const Center(
                  child: Text(
                    "No hi ha ingredients afegits",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
          Positioned(
            bottom: 8,
            right: 8,
            child: RoundButton(
              icon: FontAwesomeIcons.plus,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NutritionSearchPage(isCreating: true, selectedFoodItems: selectedFoodItems, onCheck: onCheck),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}