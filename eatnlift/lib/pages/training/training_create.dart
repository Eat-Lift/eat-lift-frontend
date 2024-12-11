import 'package:eatnlift/custom_widgets/custom_multiselect_dropdown.dart';
import 'package:eatnlift/custom_widgets/exercise_card.dart';
import 'package:eatnlift/custom_widgets/rotating_logo.dart';
import 'package:eatnlift/custom_widgets/round_button.dart';
import 'package:eatnlift/pages/training/exercise_page.dart';
import 'package:eatnlift/pages/training/training_search.dart';
import 'package:eatnlift/pages/training/workout_page.dart';
import 'package:eatnlift/services/api_training_service.dart';
import 'package:eatnlift/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';

import '../../custom_widgets/relative_sizedbox.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/messages_box.dart';
import '../../custom_widgets/custom_textfield.dart';
import '../../custom_widgets/expandable_image.dart';
import '../../custom_widgets/ying_yang_toggle.dart';

class TrainingCreatePage extends StatefulWidget {
  const TrainingCreatePage({super.key});

  @override
  TrainingCreateState createState() => TrainingCreateState();
}

class TrainingCreateState extends State<TrainingCreatePage> {
  final TextEditingController exerciseNameController = TextEditingController();
  final TextEditingController exerciseDescriptionController = TextEditingController();
  List<dynamic> selectedMuscles = [];
  List<dynamic> muscles = [
    "Pectoral",
    "Deltoides anterior",
    "Deltoides posterior",
    "Deltoides medial",
    "Biceps",
    "Triceps",
    "Dorsal",
    "Romboides",
    "Trapezi",
    "Lumbar",
    "Quadriceps",
    "Isquiotibials",
    "Adductors",
    "Planxells",
    "Gluti",
    "Abdominals",
  ];

  List<Map<String, dynamic>> selectedExercises = [];
  
  final TextEditingController workoutNameController = TextEditingController();
  final TextEditingController workoutDescriptionController = TextEditingController();

  File? _selectedImage;
  String? initialImagePath;

  bool isCreatingExercise = true;
  Map<String, dynamic> response = {};

  bool isCreating = false;

  void toggleCreateMode(bool isExerciseSelected) {
    setState(() {
      isCreatingExercise = isExerciseSelected;
    });
  }

  void _submitData() async {
    if (isCreatingExercise) {
      bool emptyField = false;
      response = {};


      if (exerciseNameController.text.trim().isEmpty) {
        response["success"] = false;
        if (response.containsKey('errors')) {
          response['errors'].add("Es requereix el nom de l'exercici");
        } else {
          response['errors'] = ["Es requereix el nom de l'exercici"];
        }
        emptyField = true;
      }

      if (selectedMuscles.isEmpty) {
        response["success"] = false;
        if (response.containsKey('errors')) {
          response['errors'].add("No hi ha cap múscul seleccionat");
        } else {
          response['errors'] = ["No hi ha cap múscul seleccionat"];
        }
        emptyField = true;
      }


      if (emptyField) {
        setState(() {});
        return;
      }


      final exercise = {
        "name": exerciseNameController.text.trim(),
        "description": exerciseDescriptionController.text.trim(),
        "trained_muscles": selectedMuscles
      };

      String? updatedImageURL;
      if (_selectedImage != null) {
        setState(() {
          isCreating = true;
        });

        final storageService = StorageService();
        updatedImageURL = await storageService.uploadImage(
          _selectedImage!,
          'exercises/${_selectedImage!.path.split('/').last}',
        );

        setState(() {
          isCreating = false;
        });

        exercise['picture'] = updatedImageURL!;
      }

      final apiService = ApiTrainingService();
      final result = await apiService.createExercise(exercise);
      setState(() {
        response = result;
      });

      if (result["success"]){
        if (mounted){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ExercisePage(exerciseId: result["exercise"], isCreating: false),
            ),
          );
        }
      }
    } else {
      bool emptyField = false;
      response = {};


      if (workoutNameController.text.trim().isEmpty) {
        response["success"] = false;
        if (response.containsKey('errors')) {
          response['errors'].add("Es requereix el nom de l'entrenament");
        } else {
          response['errors'] = ["Es requereix el nom de l'entrenmaent"];
        }
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

      final workout = {
        "name": workoutNameController.text.trim(),
        "description": workoutDescriptionController.text,
        "exercises": selectedExercises.map((item) => item["id"]).toList(),
      };

      final apiService = ApiTrainingService();
      final result = await apiService.createWorkout(workout);
      if (result["success"]) {
        if (mounted){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WorkoutPage(workoutId: result["workout"], isCreating: false),
            ),
          );
        }
      }
      else {
        setState(() {
          response = result;
        });
      }
    }
  }


  void onCheck(List<Map<String, dynamic>>? fromSearchExercises) {
    setState(() {
      selectedExercises = fromSearchExercises!;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text("Crear"),
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isCreatingExercise) ...[
                ExpandableImage(
                  initialImageUrl: initialImagePath,
                  onImageSelected: (imageFile) {
                    setState(() {
                      _selectedImage = imageFile;
                    });
                  },
                  editable: true,
                  width: 70,
                  height: 70,
                ),
              ] else ...[
                const Icon(
                  FontAwesomeIcons.heartPulse,
                  size: 100,
                  color: Colors.black,
                ),
              ],
              const RelativeSizedBox(height: 0.5),
              Text(
                isCreatingExercise ? "Crea un Exercici" : "Crea un entrenament",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                ),
              ),
              const RelativeSizedBox(height: 2),
              YinYangToggle(
                isLeftSelected: isCreatingExercise,
                leftText: "Exercici",
                rightText: "Entrenament",
                onToggle: toggleCreateMode,
                height: 57,
              ),
              const RelativeSizedBox(height: 2),
              if (isCreatingExercise) ...[
                _buildExerciseForm(),
              ] else ...[
                _buildWorkoutForm(),
              ],
              const RelativeSizedBox(height: 2),
              CustomButton(
                text: isCreatingExercise? "Crear exercici" : "Crear entrenament",
                onTap: _submitData,
              ),
              const RelativeSizedBox(height: 2),
              if (isCreating) ...[
                RotatingImage(),
                const RelativeSizedBox(height: 2),
              ]
              else ...[
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseForm() {
    return Column(
      children: [
        CustomTextfield(
          controller: exerciseNameController,
          hintText: "Nom",
          maxLength: 30,
        ),
        const RelativeSizedBox(height: 0.5),
        CustomTextfield(
          controller: exerciseDescriptionController,
          hintText: "Descripció",
          maxLength: 300,
          maxLines: 3,
        ),
        const RelativeSizedBox(height: 0.5),
        CustomMultiSelectDropdown(
          title: "Músculs",
          items: muscles,
          selectedItems: selectedMuscles,
          onSelectionChanged: (selectedItems) {
            setState((){
              selectedMuscles = selectedItems;
            });
          }, 
          itemLabel: (item) => item
        ),
      ],
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
          padding: const EdgeInsets.all(7.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: Stack(
            children: [
              selectedExercises.isNotEmpty
                  ? ListView.builder(
                      itemCount: selectedExercises.length,
                      itemBuilder: (context, index) {
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