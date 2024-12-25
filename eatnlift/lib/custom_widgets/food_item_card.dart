import 'package:eatnlift/custom_widgets/custom_number.dart';
import 'package:eatnlift/pages/nutrition/food_item_edit.dart';
import 'package:eatnlift/services/api_nutrition_service.dart';
import 'package:flutter/material.dart';
import 'package:eatnlift/custom_widgets/relative_sizedbox.dart';
import 'package:eatnlift/custom_widgets/custom_textfield.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/database_helper.dart';
import '../models/food_item.dart';

class FoodItemCard extends StatefulWidget {
  final Map<String, dynamic> foodItem;
  final String currentUserId;

  final bool isDeleteable;
  final Function(int id)? onDelete;

  final bool isEditable;
  
  final bool isSaveable;

  final bool isSelectable;
  final bool initiallySelected;
  final bool enableQuantitySelection;
  final bool enableQuantityEdit;
  final double quantity;
  final void Function(Map<String, dynamic>)? onSelect;
  final void Function(String)? onChangeQuantity;
  final void Function(String)? onSubmittedQuantity;

  const FoodItemCard({
    super.key,
    required this.foodItem,
    this.isSelectable = false,
    this.isEditable = false,
    this.isSaveable = false,
    this.isDeleteable = true,
    this.enableQuantitySelection = false,
    this.onSelect,
    this.quantity = 100,
    this.initiallySelected = false,
    this.onChangeQuantity,
    this.currentUserId = "0",
    this.onDelete,
    this.onSubmittedQuantity,
    this.enableQuantityEdit = true,
  });

  @override
  State<FoodItemCard> createState() => _FoodItemCardState();
}

class _FoodItemCardState extends State<FoodItemCard> {
  late bool isCreator;
  bool isSaved = false;
  bool loading = true;
  bool isSelected = false;
  final TextEditingController quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isCreator = widget.foodItem['creator'].toString() == widget.currentUserId;
    if (widget.isSaveable) {
      _fetchSavedState();
    }
    if (widget.enableQuantitySelection) {
      quantityController.text = formatNumber(widget.quantity);
    }
    else {
      quantityController.text = "100";
    }
    if (widget.isSelectable){
      isSelected = widget.initiallySelected;
    }
  }

  double safeParseDouble(String? value, [double defaultValue = 100.0]) {
    if (value == null || value.isEmpty) {
      return defaultValue;
    }
    return double.tryParse(value) ?? defaultValue;
  }

  Future<void> _fetchSavedState() async {
    final apiService = ApiNutritionService();
    final result = await apiService.getFoodItemSaved(widget.foodItem["id"].toString());
    if(result["success"]) {
      setState(() {
        isSaved = result["is_saved"];
        loading = false;
      });
    }
  }

  void _toggleSave() async {
    final apiService = ApiNutritionService();
    final databaseHelper = DatabaseHelper.instance;

    final String foodName = widget.foodItem['name'];
    final String creatorId = widget.foodItem['creator'].toString();

    if (isSaved) {
      final result = await apiService.unsaveFoodItem(widget.foodItem["id"].toString());
      if (result["success"]) {
        final db = await databaseHelper.database;
        await db.delete(
          'food_items',
          where: 'name = ? AND user = ?',
          whereArgs: [foodName, creatorId],
        );

        setState(() {
          isSaved = false;
        });
      }
    } else {
      final result = await apiService.saveFoodItem(widget.foodItem["id"].toString());
      if (result["success"]) {
        final foodItem = FoodItem(
          user: widget.foodItem["creator"].toString(),
          name: foodName,
          calories: widget.foodItem['calories'],
          proteins: widget.foodItem['proteins'],
          fats: widget.foodItem['fats'],
          carbohydrates: widget.foodItem['carbohydrates'],
        );
        await databaseHelper.insertFoodItem(foodItem);

        setState(() {
          isSaved = true;
        });
      }
    }
  }

  void _deleteFoodItem() async {
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
                final apiService = ApiNutritionService();
                final databaseHelper = DatabaseHelper.instance;

                final response = await apiService.deleteFoodItem(widget.foodItem["id"].toString());

                if (response["success"]) {
                  await databaseHelper.deleteFoodItemByNameAndUser(
                    widget.foodItem["name"],
                    widget.foodItem["creator"].toString(),
                  );

                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                } else {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error eliminant l'aliment")),
                    );
                  }
                }
              },
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }

  String formatNumber(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  Map<String, dynamic> _getSelectedFoodItem() {
    final selectedQuantity = double.tryParse(quantityController.text) ?? 100.0;
    return {
      ...widget.foodItem,
      "quantity": selectedQuantity,
      "selected": isSelected,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
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
                  Flexible(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        widget.foodItem['name'] ?? 'Desconegut',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  Spacer(),
                  if (widget.enableQuantitySelection) ...[
                    SizedBox(
                      width: 80,
                      height: 40,
                      child: widget.enableQuantityEdit
                          ? CustomTextfield(
                              controller: quantityController,
                              hintText: "100",
                              isNumeric: true,
                              maxLength: 6,
                              allowDecimal: true,
                              unit: "g",
                              centerText: true,
                              onChanged: (value) {
                                setState(() {});
                                if (widget.onChangeQuantity != null) {
                                  widget.onChangeQuantity!(value);
                                }
                              },
                              onSubmitted: (value) {
                                if (widget.onSubmittedQuantity != null) {
                                  widget.onSubmittedQuantity!(value);
                                }
                              },
                            )
                          : Padding(
                              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                              child: Text(
                                '${quantityController.text} g',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                    ),
                  ],
                  if (widget.isSelectable)
                    Checkbox(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          isSelected = value ?? false;
                          
                        });
                        if (widget.onSelect != null) {
                          widget.onSelect!(_getSelectedFoodItem());
                        }
                      },
                    ),
                ],
              ),
              const RelativeSizedBox(height: 1),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomNumber(number: (safeParseDouble(quantityController.text) / 100) * widget.foodItem['calories'], width: 283, icon: Icons.local_fire_department, unit: "kcal", isCentered: true, size: 13),
                  RelativeSizedBox(height: 0.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: CustomNumber(number: (safeParseDouble(quantityController.text) / 100) * widget.foodItem['proteins'], width: 92, icon: FontAwesomeIcons.drumstickBite, unit: "g", size: 13),
                      ),
                      RelativeSizedBox(width: 1),
                      Expanded(
                        child: CustomNumber(number: (safeParseDouble(quantityController.text) / 100) * widget.foodItem['fats'], width: 92, icon: FontAwesomeIcons.wheatAwn, unit: "g", size: 13),

                      ),
                      RelativeSizedBox(width: 1),
                      Expanded(
                        child: CustomNumber(number: (safeParseDouble(quantityController.text) / 100) * widget.foodItem['carbohydrates'], width: 92, icon: Icons.water_drop, unit: "g", size: 13),
                      ),
                    ],
                  ),
                ],
              ),
              RelativeSizedBox(height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isSaveable) ...[
                    if (!loading)
                      IconButton(
                        icon: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: Colors.black,
                        ),
                        tooltip: isSaved ? 'Unsave' : 'Save',
                        onPressed: _toggleSave,
                      ),
                    if (loading)
                      IconButton(
                        icon: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: Colors.grey.shade200,
                        ),
                        onPressed: () {},
                      ),
                    ],
                    if (widget.isEditable && isCreator)
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.black),
                        tooltip: 'Edit',
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditFoodItemPage(foodItem: widget.foodItem),
                            )
                          );
                        },
                      ),
                    if (widget.isEditable && isCreator)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.black),
                        tooltip: 'Delete',
                        onPressed: _deleteFoodItem,
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