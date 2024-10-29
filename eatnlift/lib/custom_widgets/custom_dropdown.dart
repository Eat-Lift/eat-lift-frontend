import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final T? selectedItem;
  final Function(T) onItemSelected;
  final String Function(T) itemLabel;
  final double initialOffset;

  const CustomDropdown({
    super.key,
    required this.title,
    required this.items,
    required this.selectedItem,
    required this.onItemSelected,
    required this.itemLabel,
    this.initialOffset = 0.0,
  });

  void _showPickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(color: Colors.grey.shade400, width: 3),
          ),
          child: Container(
            width: 200,
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
                    controller: ScrollController(
                      initialScrollOffset: initialOffset,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        title: Text(
                          itemLabel(item),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        onTap: () {
                          onItemSelected(item);
                          Navigator.pop(context); // Close dialog after selection
                        },
                      );
                    },
                    separatorBuilder: (context, index) => Divider(thickness: 2),
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
          border: Border.all(color: Colors.white, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              selectedItem != null ? itemLabel(selectedItem!) : title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
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