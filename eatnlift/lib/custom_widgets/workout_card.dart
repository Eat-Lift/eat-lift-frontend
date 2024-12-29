import 'package:eatnlift/custom_widgets/custom_button.dart';
import 'package:eatnlift/pages/training/workout_page.dart';
import 'package:eatnlift/services/api_training_service.dart';
import 'package:flutter/material.dart';


class WorkoutCard extends StatefulWidget {
  final Map<String, dynamic> workout;
  final bool isAddable;
  final bool isSelectable;
  final bool initiallySelected;
  final void Function(Map<String, dynamic>)? onSelect;
  final void Function(List<Map<String, dynamic>>)? onAdd;
  final bool isCreating;
  final VoidCallback? onTap;

  const WorkoutCard({
    super.key,
    required this.workout,
    this.initiallySelected = false,
    this.isSelectable = false,
    this.isAddable = false,
    this.onSelect,
    this.onAdd,
    this.isCreating = true,
    this.onTap,
  });

  @override
  State<WorkoutCard> createState() => _WorkoutCardState();
}

class _WorkoutCardState extends State<WorkoutCard> {
  bool isSelected = false;
  final TextEditingController quantityController = TextEditingController();

  Future<List<Map<String, dynamic>>> _getSelectedExercises() async {
    final apiService = ApiTrainingService();
    final result = await apiService.getWorkout(widget.workout["id"].toString());

    if (result["success"] && result["workout"]["exercises"] is List) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("S'han afegit els exercicis de l'entrenament."),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      return (result["workout"]["exercises"] as List)
          .map((item) => {
                "id": item["exercise"]["id"],
                "name": item["exercise"]["name"],
                "selected": true,
              })
          .toList();
    } else {
      return [];
    }
  }

  Map<String, dynamic> _getSelectedWorkout() {
    return {
      ...widget.workout,
      "selected": isSelected,
    };
  }

  @override
  void initState() {
    super.initState();
    if (widget.isSelectable){
      isSelected = widget.initiallySelected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkoutPage(workoutId: widget.workout["id"], isCreating: widget.isCreating),
          )
        ).then((_){
          widget.onTap!();
        });
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
                  Flexible(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        widget.workout['name'] ?? 'Desconegut',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ),
                  Spacer(),
                  if (widget.isAddable) ...[
                    CustomButton(
                      text: "Afegeix",
                      width: 80,
                      height: 30,
                      onTap: () {
                        if (widget.onAdd != null) {
                          _getSelectedExercises().then((selectedExercises) {
                            widget.onAdd!(selectedExercises);
                          });
                        }
                      },
                    ),
                  ],
                  if (widget.isSelectable) ...[
                    Checkbox(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          isSelected = value ?? false;
                        });
                        if (widget.onSelect != null) {
                          widget.onSelect!(_getSelectedWorkout());
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