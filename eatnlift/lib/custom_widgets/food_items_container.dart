import 'package:eatnlift/custom_widgets/food_item_card.dart';
import 'package:eatnlift/custom_widgets/round_button.dart';
import 'package:eatnlift/pages/nutrition/nutrition_search.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FoodItemsContainer extends StatefulWidget {
  final List<Map<String, dynamic>> foodItems;
  final String? title;
  final Function(String mealType, Map<String, dynamic> foodItem, double quantity)? onChangeQuantity;
  final Function(String mealType)? onSumbittedQuantity;
  final Function(String mealType, Map<String, dynamic> foodItem)? onCheck;
  final Function(String mealType, List<Map<String, dynamic>> foodItems)? updateMeal;
  final bool editable;
  final bool enableQuantityEdit;
  final bool isSelectable;

  const FoodItemsContainer({
    super.key,
    required this.foodItems,
    this.title,
    this.onChangeQuantity,
    this.onCheck,
    this.updateMeal,
    this.onSumbittedQuantity,
    this.editable = true,
    this.enableQuantityEdit = true,
    this.isSelectable = true,
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
    _initState();
  }

  Future<void> _initState() async {
    await _setSelectedFoodItems();
  }

  @override
  void didUpdateWidget(FoodItemsContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.foodItems != widget.foodItems) {
      _setSelectedFoodItems();
    }
  }

  Future<void> _setSelectedFoodItems() async {
    selectedFoodItems = [];
    for (var foodItem in widget.foodItems){
      selectedFoodItems.add({
        ...foodItem["food_item"],
        "quantity": foodItem["quantity"],
        "selected": true,
      });
    }
  }

  List<Map<String, dynamic>>? transformFoodItems() {
    List<Map<String, dynamic>>? foodItems = [];
    for (var foodItem in widget.foodItems){
      foodItems.add({
        ...foodItem["food_item"],
        "quantity": foodItem["quantity"],
        "selected": true,
      });
    }
    return foodItems;
  }

  void onCheck(List<Map<String, dynamic>>? fromSearchFoodItems) {
    setState(() {
      selectedFoodItems = [];
      for (var foodItem in fromSearchFoodItems!) {
          selectedFoodItems.add({
            ...foodItem,
            "quantity": foodItem["quantity"],
            "selected": true,
          });
      }
    });
    widget.updateMeal!(widget.title!.toUpperCase(), selectedFoodItems);
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
          height: 180,
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
                                key: ValueKey(foodItem["food_item"]["id"]),
                                foodItem: foodItem["food_item"],
                                onSelect: (value) {
                                  setState(() {
                                    selectedFoodItems.removeAt(index);
                                  });
                                  widget.onCheck!(widget.title!.toUpperCase(), foodItem["food_item"]);
                                },
                                enableQuantityEdit: widget.enableQuantityEdit,
                                quantity: foodItem["quantity"],
                                initiallySelected: true,
                                isSelectable: widget.isSelectable,
                                isEditable: false,
                                isSaveable: false,
                                isDeleteable: false,
                                enableQuantitySelection: true,
                                onChangeQuantity: (updatedQuantity) {
                                  if (updatedQuantity.isEmpty) {
                                    foodItem["quantity"] = 100.0;
                                  }
                                  else {
                                    foodItem["quantity"] = double.parse(updatedQuantity);
                                  }
                                  _setSelectedFoodItems();
                                  if (widget.onChangeQuantity != null) {
                                    widget.onChangeQuantity!(widget.title!.toUpperCase(), foodItem["food_item"], foodItem["quantity"]);
                                  }
                                },
                                onSubmittedQuantity: (submittedQuantity) {
                                  if (widget.onSumbittedQuantity != null) {
                                    widget.onSumbittedQuantity!(widget.title!.toUpperCase());
                                  }
                                }

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
              if (widget.editable) ...[
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: RoundButton(
                    icon: FontAwesomeIcons.plus,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NutritionSearchPage(isCreating: true, selectedFoodItems: transformFoodItems(), onCheck: onCheck),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}