import 'package:flutter/material.dart';
import 'package:eatnlift/custom_widgets/relative_sizedbox.dart';
import 'package:eatnlift/custom_widgets/custom_textfield.dart';

class FoodItemCard extends StatefulWidget {
  final Map<String, dynamic> foodItem;
  final String currentUserId;

  final VoidCallback? onDelete;
  final bool isDeleteable;

  final void Function(Map<String, dynamic>)? onUpdate;
  final bool isEditable;
  
  final bool isSaveable;

  final bool isSelectable;
  final bool initiallySelected;
  final bool enableQuantitySelection;
  final double quantity;
  final void Function(Map<String, dynamic>)? onSelect;
  final void Function(String)? onChangeQuantity;

  const FoodItemCard({
    super.key,
    required this.foodItem,
    this.currentUserId = "-1",
    this.onDelete,
    this.onUpdate,
    this.isSelectable = false,
    this.isEditable = true,
    this.isSaveable = true,
    this.isDeleteable = true,
    this.onSelect,
    this.enableQuantitySelection = false,
    this.quantity = 100,
    this.initiallySelected = false,
    this.onChangeQuantity,
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
    await Future.delayed(const Duration(milliseconds: 200));
    if (context.mounted){
      setState(() {
        isSaved = false;
        loading = false;
      });
    }
  }

  void _toggleSave() async {
    setState(() {
      isSaved = !isSaved;
    });
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
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDelete!();
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
      // If the number has no decimals, return it as an integer string
      return value.toInt().toString();
    }
    // Otherwise, format it with 2 decimal places
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
          color: Colors.grey.shade200,
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
                  Text(
                    widget.foodItem['name'] ?? 'Desconegut',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Spacer(),
                  if (widget.enableQuantitySelection) ...[
                    SizedBox(
                      width: 80,
                      height: 40,
                      child: CustomTextfield(
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
                        }
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
                  if (widget.isEditable && isCreator)
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.black),
                      tooltip: 'Edit',
                      onPressed: () {
                        widget.onUpdate!(widget.foodItem);
                      },
                    ),
                  if (widget.isDeleteable && isCreator)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.black),
                      tooltip: 'Delete',
                      onPressed: _deleteFoodItem,
                    ),
                  if (widget.isSaveable)
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
              ),
              const RelativeSizedBox(height: 0.1),
              Text(
                'Caloríes: ${formatNumber((safeParseDouble(quantityController.text) / 100) * widget.foodItem['calories'])} kcal',
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text(
                'Proteïnes: ${formatNumber((safeParseDouble(quantityController.text) / 100) * widget.foodItem['proteins'])} g',
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text(
                'Greixos: ${formatNumber((safeParseDouble(quantityController.text) / 100) * widget.foodItem['fats'])} g',
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text(
                'Carbohidrats: ${formatNumber((safeParseDouble(quantityController.text) / 100) * widget.foodItem['carbohydrates'])} g',
                style: TextStyle(color: Colors.grey[600]),
              ),
              RelativeSizedBox(height: 1),
            ],
          ),
        ),
      ),
    );
  }
}