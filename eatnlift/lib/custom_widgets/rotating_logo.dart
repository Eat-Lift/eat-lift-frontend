import 'package:flutter/material.dart';

class RotatingImage extends StatefulWidget {
  final String imagePath;
  final Duration duration;

  const RotatingImage({
    super.key,
    this.imagePath = "lib/assets/images/EatnliftLogo.png",
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<RotatingImage> createState() => _RotatingImageState();
}

class _RotatingImageState extends State<RotatingImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 6 * 3.1416,
          child: child,
        );
      },
      child: Image.asset(
        widget.imagePath,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
      ),
    );
  }
}