import 'package:eatnlift/pages/training/exercise_page.dart';
import 'package:flutter/material.dart';


class ExerciseCard extends StatefulWidget {
  final Map<String, dynamic> exercise;
  final bool isSelectable;
  final bool initiallySelected;
  final void Function(Map<String, dynamic>, String)? onSelect;
  final bool isCreating;
  final bool clickable;

  const ExerciseCard({
    super.key,
    required this.exercise,
    this.initiallySelected = false,
    this.isSelectable = false,
    this.onSelect,
    this.isCreating = true,
    this.clickable = true,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  late bool isCreator;
  bool isSaved = false;
  bool loading = true;
  bool isSelected = false;
  final TextEditingController quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isSelectable){
      isSelected = widget.initiallySelected;
    }
  }

  Map<String, dynamic> _getSelectedExercise() {
    return {
      ...widget.exercise,
      "selected": isSelected,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.clickable){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExercisePage(exerciseId: widget.exercise["id"], isCreating: widget.isCreating),
            )
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.exercise['name'] ?? 'Desconegut',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Spacer(),
                  if (widget.isSelectable) ...[
                    Checkbox(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          isSelected = value ?? false;
                        });
                        if (widget.onSelect != null) {
                          widget.onSelect!(_getSelectedExercise(), "exercise");
                        }
                      },
                    ),
                  ],

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}