import 'package:eatnlift/custom_widgets/exercise_card.dart';
import 'package:eatnlift/custom_widgets/round_button.dart';
import 'package:eatnlift/pages/training/training_search.dart';
import 'package:eatnlift/services/api_training_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../custom_widgets/relative_sizedbox.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/messages_box.dart';
import '../../custom_widgets/custom_textfield.dart';

class EditWorkoutPage extends StatefulWidget {
  final Map<String, dynamic>? workout;
  const EditWorkoutPage({
    super.key,
    required this.workout,
  });

  @override
  EditWorkoutState createState() => EditWorkoutState();
}

class EditWorkoutState extends State<EditWorkoutPage> {
  TextEditingController workoutNameController = TextEditingController();
  TextEditingController workoutDescriptionController = TextEditingController();
  List<Map<String, dynamic>> selectedExercises = [];
  Map<String, dynamic> response = {};

  @override
  void initState() {
    super.initState();
    workoutNameController = TextEditingController(text: widget.workout?["name"]);
    workoutDescriptionController = TextEditingController(text: widget.workout?["description"]);
    selectedExercises = [];
    for (var e in widget.workout?["exercises"] as List) {
      selectedExercises.add({
        "id": e["exercise"]["id"],
        "name": e["exercise"]["name"],
        "selected": true,
      });
    }
  }

  void onCheck(List<Map<String, dynamic>>? fromSearchExercises) {
    setState(() {
      selectedExercises = fromSearchExercises!;
    });
    Navigator.pop(context);
  }

  Future<void> _submitData() async {
    bool emptyField = false;
    response = {};

    if (workoutNameController.text.trim().isEmpty) {
      response["success"] = false;
      response['errors'] = response.containsKey('errors')
          ? [...response['errors'], "Es requereix el nom de l'entrenament"]
          : ["Es requereix el nom de l'entrenament"];
      emptyField = true;
    }

    if (selectedExercises.length < 2){
      response["success"] = false;
      if (response.containsKey('errors')) {
        response['errors'].add("Es requereixen al menys 2 exercicis");
      } else {
        response['errors'] = ["Es requereixen al menys 2 exercicis"];
      }
      emptyField = true;
    }

    if (emptyField) {
      setState(() {});
      return;
    }

    final exercise = {
      "name": workoutNameController.text.trim(),
      "descripció": workoutDescriptionController.text.trim(),
      "exercises": selectedExercises.map((item) => item["id"]).toList(),
    };

    final apiService = ApiTrainingService();
    final result = await apiService.editWorkout(exercise, widget.workout!["id"].toString());
    setState(() {
      response = result;
    });

    if (result["success"]) {
      if (mounted) {
        if (result["success"]) {
          if (mounted) {
            Navigator.pop(context, true);
          }
        }
      }
    }
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text("Editar"),
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                FontAwesomeIcons.heartPulse,
                size: 100,
                color: Colors.black,
              ),
              const RelativeSizedBox(height: 0.5),
              Text(
                "Edita l'entrenament",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                ),
              ),
              const RelativeSizedBox(height: 2),
              _buildWorkoutForm(),
              const RelativeSizedBox(height: 2),
              CustomButton(
                text: "Editar entrenament",
                onTap: _submitData,
              ),
              const RelativeSizedBox(height: 2),
              if (response.isNotEmpty && !response["success"]) ...[
                MessagesBox(
                  messages: response["errors"],
                  height: 6,
                  color: Colors.red,
                ),
                const RelativeSizedBox(height: 4)
              ] else ...[
                const RelativeSizedBox(height: 10)
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextfield(
          controller: workoutNameController,
          hintText: "Nom",
          maxLength: 50,
        ),
        const RelativeSizedBox(height: 0.5),
        CustomTextfield(
          controller: workoutDescriptionController,
          hintText: "Descripció",
          maxLength: 300,
          maxLines: 3,
        ),
        const RelativeSizedBox(height: 1),
        Container(
          height: 180,
          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 7.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white, width: 3),
          ),
          constraints: BoxConstraints(
            minHeight: 0,
            maxHeight: 155,
          ),
          child: Stack(
            children: [
              selectedExercises.isNotEmpty
                  ? ListView.builder(
                      itemCount: selectedExercises.length + 1,
                      itemBuilder: (context, index) {
                        if (index == selectedExercises.length) {
                          return const RelativeSizedBox(height: 8);
                        }
                        final exercise = selectedExercises[index];
                        return Row(
                          children: [
                            Expanded(
                              child: ExerciseCard(
                                key: ValueKey(exercise['id']),
                                exercise: exercise,
                                initiallySelected: true,
                                isSelectable: true,
                                onSelect: (value, type) {
                                  setState(() {
                                    selectedExercises.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        "No hi ha exercicis afegits",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
              Positioned(
                bottom: 8,
                right: 8,
                child: RoundButton(
                  icon: FontAwesomeIcons.plus,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TrainingSearchPage(isCreating: true, selectedExercises: selectedExercises, onCheck: onCheck),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
