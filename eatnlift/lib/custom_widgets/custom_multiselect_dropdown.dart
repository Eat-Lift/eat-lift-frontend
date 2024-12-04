import 'package:flutter/material.dart';

class CustomMultiSelectDropdown<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final List<T> selectedItems;
  final Function(List<T>) onSelectionChanged;
  final String Function(T) itemLabel;
  final double width;
  final double height;

  const CustomMultiSelectDropdown({
    super.key,
    required this.title,
    required this.items,
    required this.selectedItems,
    required this.onSelectionChanged,
    required this.itemLabel,
    this.width = 200.0,
    this.height = 600.0,
  });

  @override
  CustomMultiSelectDropdownState<T> createState() =>
      CustomMultiSelectDropdownState<T>();
}

class CustomMultiSelectDropdownState<T> extends State<CustomMultiSelectDropdown<T>> {

    void _showPickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(color: Colors.grey, width: 3),
          ),
          child: Container(
            width: widget.width,
            height: widget.height,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: widget.items.length,
                        itemBuilder: (context, index) {
                          final item = widget.items[index];
                          final isSelected = widget.selectedItems.contains(item);

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.itemLabel(item),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Checkbox(
                                value: isSelected,
                                onChanged: (bool? checked) {
                                  setState(() {
                                    if (checked == true) {
                                      widget.selectedItems.add(item);
                                    } else {
                                      widget.selectedItems.remove(item);
                                    }
                                  });
                                },
                              ),
                            ],
                          );
                        },
                        separatorBuilder: (context, index) =>
                            Divider(thickness: 1, color: Colors.grey),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        widget.onSelectionChanged(widget.selectedItems);
                        Navigator.pop(context);
                      },
                      child: const Text("Done"),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPickerDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.selectedItems.isNotEmpty
                    ? widget.selectedItems
                        .map((item) => widget.itemLabel(item))
                        .join(', ')
                    : widget.title,
                style: TextStyle(
                  fontSize: 16,
                  color: widget.selectedItems.isNotEmpty
                      ? Colors.black
                      : Colors.grey[500],
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[800]),
          ],
        ),
      ),
    );
  }
}