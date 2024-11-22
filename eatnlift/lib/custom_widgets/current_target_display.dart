import 'package:flutter/material.dart';

class CurrentTargetDisplay extends StatelessWidget {
  final int current;
  final int target;
  final String? unit; // Unit field
  final IconData? icon; // Optional icon
  final double size; // General size for font and icon
  final double width; // Width of the widget
  final double height; // Height of the widget
  final Color normalColor; // Base background color
  final Color exceededColor; // Background color when exceeded

  const CurrentTargetDisplay({
    super.key,
    required this.current,
    required this.target,
    this.unit,
    this.icon,
    this.size = 17, // Default size for font and icon
    this.width = 150, // Default width
    this.height = 60, // Default height
    this.normalColor = Colors.green, // Default normal background color
    this.exceededColor = Colors.red, // Default exceeded background color
  });

  Color _getBackgroundColor() {
    return current > target ? exceededColor : normalColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _getBackgroundColor(), // Dynamic background color
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end, // Align everything to the right
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Current/Target Text
          Text(
            '${current.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} ${unit ?? ''}',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: size,
            ),
          ),
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(
                icon,
                color: Colors.white,
                size: size + 3, // Slightly larger icon size
              ),
            ),
        ],
      ),
    );
  }
}