import 'package:eatnlift/custom_widgets/custom_textfield.dart';
import 'package:eatnlift/custom_widgets/round_button.dart';
import 'package:eatnlift/pages/training/exercise_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ExerciseSetCard extends StatefulWidget {
  final Map<String, dynamic> exerciseItem;
  final Function(Map<String, dynamic>) onExerciseUpdated;
  final bool isEditable;

  const ExerciseSetCard({
    super.key,
    required this.exerciseItem,
    required this.onExerciseUpdated,
    this.isEditable = true,
  });

  @override
  ExerciseSetCardState createState() => ExerciseSetCardState();
}

class ExerciseSetCardState extends State<ExerciseSetCard> {
  late List<Map<String, dynamic>> setsList;

  late List<TextEditingController> weightControllers;
  late List<TextEditingController> repsControllers;

  @override
  void initState() {
    super.initState();

    setsList = List<Map<String, dynamic>>.from(widget.exerciseItem["sets"]);

    weightControllers = setsList
        .map((set) => TextEditingController(text: set["weight"].toString()))
        .toList();

    repsControllers = setsList
        .map((set) => TextEditingController(text: set["reps"].toString()))
        .toList();
  }

  @override
  void dispose() {

    for (var controller in weightControllers) {
      controller.dispose();
    }
    for (var controller in repsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateExercise() {
    List<Map<String, dynamic>> updatedSets = [];
    for (int i = 0; i < setsList.length; i++) {
      double weight = double.tryParse(weightControllers[i].text) ?? 0.0;
      int reps = int.tryParse(repsControllers[i].text) ?? 0;
      updatedSets.add({"weight": weight, "reps": reps});
    }

    Map<String, dynamic> updatedExerciseItem = {
      "exercise": widget.exerciseItem["exercise"],
      "sets": updatedSets,
    };

    setsList = updatedExerciseItem["sets"];
    widget.onExerciseUpdated(updatedExerciseItem);
  }


  void _addSet() {
    if (setsList.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Has arribat al nombre màxim de sèries per exercici'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      double lastWeight = 0.0;
      int lastReps = 0;

      if (setsList.isNotEmpty) {
        final lastIndex = setsList.length - 1;
        lastWeight = setsList[lastIndex]["weight"];
        lastReps = setsList[lastIndex]["reps"];
      }

      setsList.add({"weight": lastWeight, "reps": lastReps});

      weightControllers.add(TextEditingController(text: lastWeight.toString()));
      repsControllers.add(TextEditingController(text: lastReps.toString()));
    });

    _updateExercise();
  }

  void _removeSet(int index) {
    bool isLastSet = setsList.length == 1;

    if (isLastSet) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Eliminar sèrie'),
          content: const Text(
              'Eliminar aquesta sèrie també eliminarà l\'exercici. Estàs segur que vols continuar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel·lar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  setsList.removeAt(index);

                  weightControllers[index].dispose();
                  repsControllers[index].dispose();

                  weightControllers.removeAt(index);
                  repsControllers.removeAt(index);
                });

                _updateExercise();

                Navigator.of(context).pop();
              },
              child: const Text(
                'Eliminar',
              ),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        setsList.removeAt(index);

        weightControllers[index].dispose();
        repsControllers[index].dispose();

        weightControllers.removeAt(index);
        repsControllers.removeAt(index);
      });

      _updateExercise();
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exerciseItem["exercise"] as Map<String, dynamic>;
    final exerciseName = exercise["name"] as String;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ExercisePage(exerciseId: exercise["id"]),
              ),
            ),
            child: Text(
              exerciseName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          const SizedBox(height: 12),
          ...setsList.asMap().entries.map((entry) {
            int setIndex = entry.key;
            bool isLastSet = setIndex == setsList.length - 1;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Text(
                    "Sèrie ${setIndex + 1}:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(width: 10),
                  widget.isEditable
                      ? Expanded(
                          child: CustomTextfield(
                            controller: weightControllers[setIndex],
                            unit: "kg",
                            hintText: "0.0",
                            centerText: true,
                            onChanged: (_) => _updateExercise(),
                            maxLength: 6,
                            isNumeric: true,
                            allowDecimal: true,
                          ),
                        )
                      : Text(
                          "${weightControllers[setIndex].text} kg",
                          style: const TextStyle(fontSize: 16),
                        ),
                  const SizedBox(width: 10),
                  widget.isEditable
                      ? Expanded(
                          child: CustomTextfield(
                            controller: repsControllers[setIndex],
                            unit: "reps",
                            hintText: "0",
                            centerText: true,
                            onChanged: (_) => _updateExercise(),
                            maxLength: 4,
                            isNumeric: true,
                            allowDecimal: false,
                          ),
                        )
                      : Text(
                          "${repsControllers[setIndex].text} reps",
                          style: const TextStyle(fontSize: 16),
                        ),
                  if (widget.isEditable && isLastSet) ...[
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _removeSet(setIndex),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.black,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 24,
                      height: 24,
                    ),
                  ]
                ],
              ),
            );
          }),
          if (widget.isEditable) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: RoundButton(
                icon: FontAwesomeIcons.plus,
                onPressed: _addSet,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
