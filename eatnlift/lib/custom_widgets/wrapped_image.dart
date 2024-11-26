import 'package:flutter/material.dart';

class WrappedImage extends StatelessWidget {
  final String imageUrl;
  final int size;
  final double padding;

  const WrappedImage({
    super.key,
    required this.imageUrl,
    this.size = 60,
    this.padding = 15,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.white, width: 3),
        color: Colors.grey.shade200,
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Image.asset(
          imageUrl,
          height: size.toDouble(),
          width: size.toDouble(),
        ),
      ),
    );
  }
}