import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final T? selectedItem;
  final Function(T) onItemSelected;
  final String Function(T) itemLabel;
  final double width;
  final double height;

  const CustomDropdown({
    super.key,
    required this.title,
    required this.items,
    required this.selectedItem,
    required this.onItemSelected,
    required this.itemLabel,
    this.width = 200.0,
    this.height = 300.0,
  });

  @override
  CustomDropdownState<T> createState() => CustomDropdownState<T>();
}

class CustomDropdownState<T> extends State<CustomDropdown<T>> {
  bool isSelected = false;

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: widget.items.length,
                    itemBuilder: (context, index) {
                      final item = widget.items[index];
                      return ListTile(
                        title: Text(
                          widget.itemLabel(item),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          setState(() {
                            isSelected = true;
                          });
                          widget.onItemSelected(item);
                          Navigator.pop(context);
                        },
                      );
                    },
                    separatorBuilder: (context, index) => Divider(thickness: 1, color: Colors.grey),
                  ),
                ),
              ],
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.selectedItem != null ? widget.itemLabel(widget.selectedItem as T) : widget.title,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Colors.black : Colors.grey[500],
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[800]),
          ],
        ),
      ),
    );
  }
}