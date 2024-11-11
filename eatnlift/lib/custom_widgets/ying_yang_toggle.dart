import 'package:flutter/material.dart';

class YinYangToggle extends StatefulWidget {
  final bool isLeftSelected;
  final String leftText;
  final String rightText;
  final double height;
  final void Function(bool isLeftSelected) onToggle;

  const YinYangToggle({
    super.key,
    required this.isLeftSelected,
    required this.leftText,
    required this.rightText,
    required this.onToggle,
    this.height = 50.0,
  });

  @override
  YinYangToggleState createState() => YinYangToggleState();
}

class YinYangToggleState extends State<YinYangToggle> {
  late bool isLeftSelected;

  @override
  void initState() {
    super.initState();
    isLeftSelected = widget.isLeftSelected;
  }

  void toggleSelection() {
    setState(() {
      isLeftSelected = !isLeftSelected;
    });
    widget.onToggle(isLeftSelected);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleSelection,
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white, width: 3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isLeftSelected ? Colors.black : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.leftText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isLeftSelected ? Colors.white : Colors.grey[500],
                    fontSize: 14
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isLeftSelected ? Colors.grey.shade200 : Colors.black,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.rightText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isLeftSelected ? Colors.grey[500] : Colors.white,
                    fontSize: 16
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}