import 'package:flutter/material.dart';
import 'package:eatnlift/custom_widgets/relative_sizedbox.dart';
import 'package:eatnlift/custom_widgets/custom_textfield.dart';

class FoodItemCard extends StatefulWidget {
  final Map<String, dynamic> foodItem;
  final String currentUserId;
  final VoidCallback onDelete;
  final void Function(Map<String, dynamic>) onUpdate;
  final bool isSelectable;
  final bool isEditable;
  final bool isSaveable;
  final bool isDeleteable;
  final void Function(String)? onSelect;
  final bool enableQuantitySelection;

  const FoodItemCard({
    super.key,
    required this.foodItem,
    this.currentUserId = "-1",
    required this.onDelete,
    required this.onUpdate,
    this.isSelectable = false,
    this.isEditable = true,
    this.isSaveable = true,
    this.isDeleteable = true,
    this.onSelect,
    this.enableQuantitySelection = false,
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
  }

  Future<void> _fetchSavedState() async {
    // Mock fetching save state logic; replace with real API call if necessary
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() {
      isSaved = false;
      loading = false;
    });
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
                widget.onDelete();
              },
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isSelectable
          ? () {
              if (widget.onSelect != null) {
                widget.onSelect!(widget.foodItem["id"].toString());
              }
            }
          : null,
      child: Container(
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
                      },
                    ),
                  if (widget.isEditable && isCreator)
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.black),
                      tooltip: 'Edit',
                      onPressed: () {
                        widget.onUpdate(widget.foodItem);
                      },
                    ),
                  if (widget.isDeleteable && isCreator)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.black),
                      tooltip: 'Delete',
                      onPressed: _deleteFoodItem,
                    ),
                  if (widget.isSaveable && !loading)
                    IconButton(
                      icon: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: Colors.black,
                      ),
                      tooltip: isSaved ? 'Unsave' : 'Save',
                      onPressed: _toggleSave,
                    ),
                  if (loading && widget.isSaveable)
                    const CircularProgressIndicator(),
                ],
              ),
              const RelativeSizedBox(height: 0.1),
              Text(
                'Caloríes: ${widget.foodItem['calories'] ?? 'N/A'} kcal',
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text(
                'Proteïnes: ${widget.foodItem['proteins'] ?? 'N/A'} g',
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text(
                'Greixos: ${widget.foodItem['fats'] ?? 'N/A'} g',
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text(
                'Carbohidrats: ${widget.foodItem['carbohydrates'] ?? 'N/A'} g',
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