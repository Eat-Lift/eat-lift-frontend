import 'package:flutter/material.dart';

class HumanBody extends StatelessWidget {
  final double height;
  final double width;
  final List<dynamic> overlayMuscles;

  const HumanBody({
    super.key,
    required this.height,
    required this.width,
    required this.overlayMuscles,
  });

  @override
  Widget build(BuildContext context) {
    const String baseImagePath = 'lib/assets/images/FullBody.png';
    final muscleOverlayImages = {
      "Pectoral": "lib/assets/images/ChestHighlight.png",
      "Deltoides anterior": "lib/assets/images/AnteriorDeltoidHighlight.png",
      "Deltoides posterior": "lib/assets/images/PosteriorDeltoidrHighlight.png",
      "Deltoides medial": "lib/assets/images/MedialDeltoidHighlight.png",
      "Biceps": "lib/assets/images/BicepsHighlight.png",
      "Triceps": "lib/assets/images/TricepsHighlight.png",
      "Dorsal": "lib/assets/images/LatsHighlight.png",
      "Trapezi": "lib/assets/images/TrapsHighlight.png",
      "Lumbar": "lib/assets/images/LowerBackHighlight.png",
      "Quadriceps": "lib/assets/images/QuadsHighlight.png",
      "Isquiotibials": "lib/assets/images/HamstringsHighlight.png",
      "Adductors": "lib/assets/images/AdductorHighlight.png",
      "Gluti": "lib/assets/images/GluteHighlight.png",
      "Abdominals": "lib/assets/images/AbsHighlight.png",
    };

    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              baseImagePath,
              fit: BoxFit.cover,
            ),
          ),
          for (String muscle in overlayMuscles)
            if (muscleOverlayImages.containsKey(muscle))
              Positioned.fill(
                child: Image.asset(
                  muscleOverlayImages[muscle]!,
                  fit: BoxFit.cover,
                  colorBlendMode: BlendMode.multiply,
                ),
              ),
        ],
      ),
    );
  }
}