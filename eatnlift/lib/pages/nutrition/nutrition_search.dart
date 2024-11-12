import 'package:eatnlift/custom_widgets/custom_button.dart';
import 'package:eatnlift/pages/nutrition/food_items.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../custom_widgets/ying_yang_toggle.dart';
import '../../custom_widgets/custom_textfield.dart';
import '../../custom_widgets/relative_sizedbox.dart';
import '../../services/api_nutrition_service.dart';
import 'dart:async';

class NutritionSearchPage extends StatefulWidget {
  const NutritionSearchPage({super.key});

  @override
  NutritionSearchPageState createState() => NutritionSearchPageState();
}

class NutritionSearchPageState extends State<NutritionSearchPage> {
  final TextEditingController searchController = TextEditingController();
  final ApiNutritionService apiNutritionService = ApiNutritionService();
  bool isSearchingFoodItem = true;
  
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
      _updateSuggestions();
    });
  }

  Future<void> _updateSuggestions() async {
    final query = searchController.text;
    if (query.isEmpty) {
      setState(() => suggestions.clear());
      return;
    }

    final response = await apiNutritionService.getSuggestions(query, isSearchingFoodItem);
    if (response["success"]) {
      setState(() {
        suggestions = response["suggestions"] ?? [];
      });
    }
  }

  void _searchFoodItems() async {
    final query = searchController.text;

    final response = await apiNutritionService.getFoodItems(query);

    if (response["success"]) {
      List<Map<String, dynamic>> foodItems = (response["foodItems"] as List)
        .map((item) => item as Map<String, dynamic>)
        .toList();

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodItemsPage(foodItems: foodItems),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text("Cercar"),
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

              const RelativeSizedBox(height: 2),
              if(suggestions.isNotEmpty) ...[
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: 250,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: suggestions.length,
                            separatorBuilder: (context, index) => Divider(
                              color: Colors.grey.shade300,
                              thickness: 1,
                            ),
                            itemBuilder: (context, index) {
                              final suggestion = suggestions[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    searchController.text = suggestion;
                                    setState(() {
                                      suggestions.clear();
                                    });
                                  },
                                  child: Text(
                                    suggestion,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[500],
                                      fontSize: 14
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              Spacer(),
              CustomButton(
                text: "Enviar",
                onTap: _searchFoodItems,
              ),
              RelativeSizedBox(height: 5),
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