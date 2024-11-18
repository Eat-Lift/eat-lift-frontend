import 'package:flutter/material.dart';

class CustomNumber extends StatefulWidget {
  final double number;
  final String? unit; // Unit field
  final IconData? icon;
  final double width; // Width parameter
  final bool isCentered; // Determine if content is centered
  final double size; // General size for font and icon

  const CustomNumber({
    super.key,
    required this.number,
    this.unit,
    this.icon,
    this.width = 100, // Default width
    this.isCentered = false, // Default to right alignment
    this.size = 17, // Default size for font and icon
  });

  @override
  State<CustomNumber> createState() => _CustomNumberState();
}

class _CustomNumberState extends State<CustomNumber> {
  String formatNumber(double number) {
    // Check if the number is an integer (e.g., 12.0) and format accordingly
    if (number == number.toInt()) {
      return number.toInt().toString();
    }
    // Otherwise, format with up to 2 decimal places
    return number.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width, // Use the width parameter
      padding: const EdgeInsets.all(5.0), // Optional padding
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8.0), // Optional rounded corners
      ),
      child: Row(
        mainAxisAlignment: widget.isCentered
            ? MainAxisAlignment.center // Center the content
            : MainAxisAlignment.end, // Align content to the right
        crossAxisAlignment: CrossAxisAlignment.center, // Center items vertically
        children: [
          Text(
            '${formatNumber(widget.number)} ${widget.unit ?? ''}', // Display number with unit
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: widget.size, // Use general size for font
            ),
          ),
          if (widget.icon != null) // Add spacing and icon size
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(
                widget.icon,
                color: Colors.white,
                size: widget.size + 3, // Use general size for icon
              ),
            ),
        ],
      ),
    );
  }
}