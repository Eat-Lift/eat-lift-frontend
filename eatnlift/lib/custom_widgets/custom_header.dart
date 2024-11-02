import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPress;

  const CustomHeader({
    super.key,
    required this.title,
    this.onBackPress,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
          onPressed: onBackPress ?? () => Navigator.of(context).pop(),
        ),
        Text(
          title,
          style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 24,
          ),
        ),
      ],
    );
  }
}