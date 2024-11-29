import 'package:eatnlift/custom_widgets/relative_sizedbox.dart';
import 'package:flutter/material.dart';

class CustomNumberPicker<T extends num> extends StatefulWidget {
  final T minValue;
  final T maxValue;
  final T defaultValue;
  final T? step;
  final String unit;
  final double width;
  final double height;
  final String title;
  final Function(T) onItemSelected;
  final IconData icon;

  const CustomNumberPicker({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.defaultValue,
    required this.onItemSelected,
    this.step,
    this.unit = '',
    this.width = 200.0,
    this.height = 300.0,
    this.title = "Select a value",
    this.icon = Icons.arrow_drop_down,
  });

  @override
  CustomNumberPickerState<T> createState() => CustomNumberPickerState<T>();
}

class CustomNumberPickerState<T extends num> extends State<CustomNumberPicker<T>> {
  T? selectedValue;
  late T stepValue;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    selectedValue = null;
    stepValue = widget.step ?? (T == int ? 1 as T : 0.1 as T);
    
    _scrollController = ScrollController(
      initialScrollOffset: _calculateInitialScrollOffset(),
    );
  }

  double _calculateInitialScrollOffset() {
    final index = ((widget.maxValue - widget.defaultValue) / stepValue).toInt();
    return index * 55.0;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showCenteredPickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(color: Colors.grey, width: 3),
          ),
          child: Container(
            height: widget.height,
            width: widget.width,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey, width: 3),
            ),
            child: ListView.separated(
              controller: _scrollController,
              itemCount: ((widget.maxValue - widget.minValue) / stepValue).toInt() + 1,
              separatorBuilder: (context, index) => Divider(thickness: 1, color: Colors.grey),
              itemBuilder: (context, index) {
                final value = widget.maxValue - (index * stepValue) as T;
                final displayValue = value is double ? value.toStringAsFixed(1) : value.toString();
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedValue = value;
                    });
                    widget.onItemSelected(value); // Pass the selected value back
                    Navigator.pop(context);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      '$displayValue ${widget.unit}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void setSelected(T selected) {
    selectedValue = selected;
  }

  @override
  Widget build(BuildContext context) {
    final displayValue = selectedValue != null
        ? (selectedValue is double
            ? (selectedValue as double).toStringAsFixed(1)
            : selectedValue.toString())
        : widget.title;

    return GestureDetector(
      onTap: () => _showCenteredPickerDialog(context),
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
              "$displayValue ${selectedValue != null ? widget.unit : ''}",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            RelativeSizedBox(width: 1),
            Icon(widget.icon, color: Colors.grey[800]),
          ],
        ),
      ),
    );
  }
}