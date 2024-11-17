import 'package:eatnlift/custom_widgets/custom_button.dart';
import 'package:eatnlift/custom_widgets/food_item_card.dart';
import 'package:eatnlift/custom_widgets/round_button.dart';
import 'package:eatnlift/pages/nutrition/food_items.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../custom_widgets/ying_yang_toggle.dart';
import '../../custom_widgets/custom_textfield.dart';
import '../../custom_widgets/relative_sizedbox.dart';
import '../../services/api_nutrition_service.dart';
import 'dart:async';

class NutritionSearchPage extends StatefulWidget {
  final bool isSelectable;
  final bool isSaveable;
  final List<Map<String,dynamic>>? selectedFoodItems;
  final Function(List<Map<String,dynamic>>?)? onCheck;

  const NutritionSearchPage({
    super.key,
    this.isSelectable = false,
    this.selectedFoodItems,
    this.isSaveable = true,
    this.onCheck,
  });

  @override
  NutritionSearchPageState createState() => NutritionSearchPageState();
}

class NutritionSearchPageState extends State<NutritionSearchPage> {
  final TextEditingController searchController = TextEditingController();
  final ApiNutritionService apiNutritionService = ApiNutritionService();
  bool isSearchingFoodItem = true;
  List<Map<String, dynamic>>? foodItems;
  
  List<String> suggestions = [];
  Timer? debounce;


  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  void toggleSearchMode(bool isFoodItemSelected) {
    setState(() {
      isSearchingFoodItem = isFoodItemSelected;
      suggestions.clear();
      searchController.clear();
    });
  }

  void _onSearchChanged() {
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 300), () {
      _searchFoodItems();
    });
  }


  Future<void> _searchFoodItems() async {
    final query = searchController.text;
    if (query.isEmpty) {
      if (mounted) setState(() => foodItems?.clear());
      return;
    }

    final response = await apiNutritionService.getFoodItems(query);
    if (response["success"]) {
      if (mounted) {
        setState(() {
          foodItems = (response["foodItems"] as List)
              .map((item) => item as Map<String, dynamic>)
              .toList();
        });
      }
    }
  }

  void _onSelectItem(Map<String, dynamic>? selectedFoodItem) {
    if (selectedFoodItem != null) {
      // Check the "selected" property in the selected food item
      if (selectedFoodItem["selected"] == true) {
        // If selected, add or update the item in the selectedFoodItems list
        final existingIndex = widget.selectedFoodItems?.indexWhere(
          (item) => item["id"] == selectedFoodItem["id"],
        );
        if (existingIndex == null || existingIndex == -1) {
          widget.selectedFoodItems?.add(selectedFoodItem);
        } else  {
          widget.selectedFoodItems?[existingIndex] = selectedFoodItem;
        }
      } else {
        // If not selected, remove the item from the selectedFoodItems list
        widget.selectedFoodItems?.removeWhere(
          (item) => item["id"] == selectedFoodItem["id"],
        );
      }

      // Optionally, update the UI if necessary
      setState(() {});
    }
  }

  double _getQuantity(Map<String, dynamic> foodItem) {
    final selectedItem = widget.selectedFoodItems?.firstWhere(
      (selectedItem) => selectedItem['id'] == foodItem['id'],
      orElse: () => foodItem,
    );

    final quantity = selectedItem?['quantity'];
    if (quantity is int) {
      return quantity.toDouble();
    } 
    else if (quantity is String) {
      return double.tryParse(quantity) ?? 100.0;
    }
    else if (quantity is double) {
      return quantity;
    } 
    return 100.0;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text("Cercar"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: RoundButton(
              icon: Icons.check,
              onPressed: () {
                if (widget.onCheck != null){
                  widget.onCheck!(widget.selectedFoodItems);
                }
              },
              size: 35,
            ),
          ),
        ]
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              YinYangToggle(
                isLeftSelected: isSearchingFoodItem,
                leftText: "Aliment",
                rightText: "Recepta",
                onToggle: toggleSearchMode,
              ),
              const RelativeSizedBox(height: 2),

              CustomTextfield(
                controller: searchController,
                hintText: isSearchingFoodItem ? "Cerca aliments" : "Cerca receptes",
                centerText: false,
                icon: FontAwesomeIcons.magnifyingGlass,
              ),
              RelativeSizedBox(height: 1),
              Expanded(
                child: foodItems != null && foodItems!.isNotEmpty ?
                        ListView.builder(
                          itemCount: foodItems!.length,
                          itemBuilder: (context, index) {
                            final foodItem = foodItems![index];
                            return FoodItemCard(
                              foodItem: foodItem,
                              isSaveable: widget.isSaveable,
                              onDelete: () {},
                              onUpdate: (updatedItem) {},
                              isSelectable: widget.isSelectable,
                              enableQuantitySelection: widget.isSelectable,
                              onSelect: _onSelectItem,
                              quantity: _getQuantity(foodItem),
                              initiallySelected: widget.selectedFoodItems?.firstWhere(
                                (selectedItem) => selectedItem['id'] == foodItem['id'],
                                orElse: () => {'selected': false},
                              )['selected'] ?? false,
                              onChangeQuantity: (updatedQuantity) {
                                final selectedItem = widget.selectedFoodItems?.firstWhere(
                                  (selectedItem) => selectedItem['id'] == foodItem['id'],
                                  orElse: () => {},
                                );
                                if (selectedItem!.isNotEmpty) {
                                  selectedItem["quantity"] = double.parse(updatedQuantity);
                                }
                              },
                            );
                          },
                        )
                        : const Center(
                          child: Text(
                            "No hi ha resultats. Prova amb una altra cerca.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    debounce?.cancel();
    super.dispose();
  }
}