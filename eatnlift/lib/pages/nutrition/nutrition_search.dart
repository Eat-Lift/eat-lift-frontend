import 'package:eatnlift/custom_widgets/food_item_card.dart';
import 'package:eatnlift/custom_widgets/recipe_card.dart';
import 'package:eatnlift/custom_widgets/round_button.dart';
import 'package:eatnlift/services/session_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../custom_widgets/ying_yang_toggle.dart';
import '../../custom_widgets/custom_textfield.dart';
import '../../custom_widgets/relative_sizedbox.dart';
import '../../services/api_nutrition_service.dart';
import 'dart:async';

class NutritionSearchPage extends StatefulWidget {
  final List<Map<String,dynamic>>? selectedFoodItems;
  final Function(List<Map<String,dynamic>>?)? onCheck;
  final bool isCreating;

  const NutritionSearchPage({
    super.key,
    this.selectedFoodItems,
    this.onCheck,
    this.isCreating = false,
  });

  @override
  NutritionSearchPageState createState() => NutritionSearchPageState();
}

class NutritionSearchPageState extends State<NutritionSearchPage> {
  final SessionStorage sessionStorage = SessionStorage();
  final TextEditingController searchController = TextEditingController();
  final ApiNutritionService apiNutritionService = ApiNutritionService();
  bool isSearchingFoodItem = true;
  List<Map<String, dynamic>>? foodItems;
  List<Map<String, dynamic>>? recipes;
  
  List<String> suggestions = [];
  Timer? debounce;

  String currentUserId = "0";
  

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserId();
    searchController.addListener(_onSearchChanged);
  }

  Future<void> _fetchCurrentUserId() async {
    final userId = await sessionStorage.getUserId();
    setState(() {
      currentUserId = userId!;
    });
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
      if (isSearchingFoodItem) {
        _searchFoodItems();
      }
      else {
        _searchRecipes();
      }
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

  Future<void> _searchRecipes() async {
    final query = searchController.text;
    if (query.isEmpty) {
      if (mounted) setState(() => foodItems?.clear());
      return;
    }

    final response = await apiNutritionService.getRecipes(query);
    if (response["success"]) {
      if (mounted) {
        setState(() {
          foodItems = (response["recipes"] as List)
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

  void _onSelectRecipe(List<Map<String, dynamic>>? selectedFoodItems) {
    if (selectedFoodItems != null) {
      for (Map<String, dynamic> selectedFoodItem in selectedFoodItems) {
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
      }
      // Optionally, update the UI if necessary
      setState(() {});
    }
  }

  void _onDeleteFoodItem(int id) {
    setState(() {
      foodItems?.removeWhere((item) => item["id"] == id);
    });
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

  Widget _buildFoodItemList(List<Map<String, dynamic>> foodItems) {
    return ListView.builder(
      itemCount: foodItems.length,
      itemBuilder: (context, index) {
        final foodItem = foodItems[index];
        return FoodItemCard(
          foodItem: foodItem,
          onDelete: _onDeleteFoodItem,
          isDeleteable: !widget.isCreating,
          isEditable: !widget.isCreating,
          isSaveable: !widget.isCreating,
          isSelectable: widget.isCreating,
          currentUserId: currentUserId,
          enableQuantitySelection: widget.isCreating,
          onSelect: _onSelectItem,
          quantity: _getQuantity(foodItem),
          initiallySelected: widget.selectedFoodItems?.firstWhere(
                (selectedItem) => selectedItem['id'] == foodItem['id'],
                orElse: () => {'selected': false},
              )['selected'] ??
              false,
          onChangeQuantity: (updatedQuantity) {
            final selectedItem = widget.selectedFoodItems?.firstWhere(
              (selectedItem) => selectedItem['id'] == foodItem['id'],
              orElse: () => {},
            );
            if (selectedItem != null && selectedItem.isNotEmpty) {
              selectedItem["quantity"] = double.parse(updatedQuantity);
            }
          },
        );
      },
    );
  }

  Widget _buildRecipeList(List<Map<String, dynamic>> recipes) {
    return ListView.builder(
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return RecipeCard(
          recipe: recipe,
          isSelectable: widget.isCreating,
          onSelect: _onSelectRecipe,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text("Cercar"),
        actions: widget.isCreating
            ? [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: RoundButton(
                    icon: Icons.check,
                    onPressed: () {
                      if (widget.onCheck != null) {
                        widget.onCheck!(widget.selectedFoodItems);
                      }
                    },
                    size: 35,
                  ),
                ),
              ]
            : null,
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
                child: Builder(
                  builder: (context) {
                    if (isSearchingFoodItem) {
                      if (foodItems != null && foodItems!.isNotEmpty) {
                        return _buildFoodItemList(foodItems!);
                      } else {
                        return const Center(
                          child: Text(
                            "No hi ha resultats. Prova amb una altra cerca",
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }
                    } else {
                      if (foodItems != null && foodItems!.isNotEmpty) {
                        return _buildRecipeList(foodItems!);
                      } else {
                        return const Center(
                          child: Text(
                            "No hi ha resultats. Prova amb una altra cerca",
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }
                    }
                  },
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