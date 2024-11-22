import 'package:flutter/material.dart';
import 'dart:math';

class NutritionGraph extends StatelessWidget {
  final double caloriesTarget;
  final double caloriesCurrent;
  final double proteinsTarget;
  final double proteinsCurrent;
  final double fatsTarget;
  final double fatsCurrent;
  final double carbsTarget;
  final double carbsCurrent;
  final double size; // Customizable size
  final double barThickness; // Customizable bar thickness

  const NutritionGraph({
    super.key, 
    required this.caloriesTarget,
    required this.caloriesCurrent,
    required this.proteinsTarget,
    required this.proteinsCurrent,
    required this.fatsTarget,
    required this.fatsCurrent,
    required this.carbsTarget,
    required this.carbsCurrent,
    this.size = 300, // Default size
    this.barThickness = 10, // Default bar thickness
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _NutritionGraphPainter(
          caloriesTarget: caloriesTarget,
          caloriesCurrent: caloriesCurrent,
          proteinsTarget: proteinsTarget,
          proteinsCurrent: proteinsCurrent,
          fatsTarget: fatsTarget,
          fatsCurrent: fatsCurrent,
          carbsTarget: carbsTarget,
          carbsCurrent: carbsCurrent,
          barThickness: barThickness,
        ),
      ),
    );
  }
}

class _NutritionGraphPainter extends CustomPainter {
  final double caloriesTarget;
  final double caloriesCurrent;
  final double proteinsTarget;
  final double proteinsCurrent;
  final double fatsTarget;
  final double fatsCurrent;
  final double carbsTarget;
  final double carbsCurrent;
  final double barThickness;

  _NutritionGraphPainter({
    required this.caloriesTarget,
    required this.caloriesCurrent,
    required this.proteinsTarget,
    required this.proteinsCurrent,
    required this.fatsTarget,
    required this.fatsCurrent,
    required this.carbsTarget,
    required this.carbsCurrent,
    required this.barThickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Helper function to draw a ring with a background
    void drawRing(
        Canvas canvas,
        Offset center,
        double radius,
        double startAngle,
        double sweepAngle,
        double thickness,
        Color backgroundColor,
        Color progressColor,
        bool isExceeded) {
      final backgroundPaint = Paint()
        ..color = isExceeded ? Colors.red : backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round;

      final progressPaint = Paint()
        ..color = isExceeded ? Colors.red : progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round;

      // Draw background
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        2 * pi,
        false,
        backgroundPaint,
      );

      // Draw progress
      if (!isExceeded) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
          progressPaint,
        );
      }
    }

    // Nutrient data with light and dark colors
    final nutrients = [
      {
        "current": caloriesCurrent,
        "target": caloriesTarget,
        "lightColor": Colors.orange.shade200,
        "darkColor": Colors.orange.shade700,
        "offset": 0.0,
      },
      {
        "current": proteinsCurrent,
        "target": proteinsTarget,
        "lightColor": Colors.blue.shade200,
        "darkColor": Colors.blue.shade700,
        "offset": barThickness + 5,
      },
      {
        "current": carbsCurrent,
        "target": carbsTarget,
        "lightColor": Colors.yellow.shade200,
        "darkColor": Colors.yellow.shade700,
        "offset": 2 * (barThickness + 5),
      },
      {
        "current": fatsCurrent,
        "target": fatsTarget,
        "lightColor": Colors.green.shade200,
        "darkColor": Colors.green.shade700,
        "offset": 3 * (barThickness + 5),
      },
    ];

    double startAngle = -pi / 2;

    for (var nutrient in nutrients) {
      final current = nutrient["current"] as double;
      final target = nutrient["target"] as double;
      final lightColor = nutrient["lightColor"] as Color;
      final darkColor = nutrient["darkColor"] as Color;
      final offset = nutrient["offset"] as double;

      final isExceeded = current > target;
      final ringRadius = radius - offset;

      double sweepAngle = 2 * pi * (current / target).clamp(0.0, 1.0);

      // Draw the ring with a background and progress
      drawRing(
        canvas,
        center,
        ringRadius,
        startAngle,
        sweepAngle,
        barThickness,
        lightColor,
        darkColor,
        isExceeded,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}