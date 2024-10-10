import 'package:flutter/material.dart';

class WrappedImage extends StatelessWidget {
  final String imageUrl;

  const WrappedImage({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 3),
        color: Colors.grey.shade200,
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Image.asset(
          imageUrl,
          height: 60,
          width: 60,
        ),
      ),
    );
  }
}