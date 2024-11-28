import 'package:flutter/material.dart';

class CustomNumberText extends StatelessWidget {
  final String? title;
  final double? number;
  final String unit;

  const CustomNumberText({
    super.key,
    this.title,
    this.number,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    String formattedNumber = _formatNumber(number);

    String displayText = title != null ? "$title $formattedNumber $unit" : "$formattedNumber $unit";

    return Text(
      displayText,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.grey.shade700,
      ),
    );
  }

  String _formatNumber(double? number) {
    if (number == null) {
      return "-";
    } else if (number == number.toInt()) {
      return number.toInt().toString();
    } else {
      return number.toString();
    }
  }
}