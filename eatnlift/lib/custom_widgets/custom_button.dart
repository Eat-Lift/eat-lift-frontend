import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Function()? onTap;
  final int width;
  final int height;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onTap,
    this.width = 1000,
    this.height = 60,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width.toDouble(),
        height: height.toDouble(),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Icon(icon, color: Colors.white, size: 20),
              if (icon != null && text != "") const SizedBox(width: 8),
              if (text != "") ...[
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}