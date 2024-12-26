import 'package:eatnlift/custom_widgets/custom_multiselect_dropdown.dart';
import 'package:eatnlift/custom_widgets/rotating_logo.dart';
import 'package:eatnlift/models/exercise.dart';
import 'package:eatnlift/services/api_training_service.dart';
import 'package:eatnlift/services/database_helper.dart';
import 'package:eatnlift/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import '../../custom_widgets/relative_sizedbox.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/messages_box.dart';
import '../../custom_widgets/custom_textfield.dart';
import '../../custom_widgets/expandable_image.dart';

class EditExercisePage extends StatefulWidget {
  final Map<String, dynamic>? exercise;
  const EditExercisePage({
    super.key,
    required this.exercise,
  });

  @override
  EditExerciseState createState() => EditExerciseState();
}

class EditExerciseState extends State<EditExercisePage> {
  TextEditingController exerciseNameController = TextEditingController();
  TextEditingController exerciseDescriptionController = TextEditingController();
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
  File? _selectedImage;
  String? initialImagePath;
  bool isCreating = false;
  Map<String, dynamic> response = {};

  @override
  void initState() {
    super.initState();
    exerciseNameController = TextEditingController(text: widget.exercise?["name"]);
    exerciseDescriptionController = TextEditingController(text: widget.exercise?["description"]);
    initialImagePath = widget.exercise?["picture"];
    if (widget.exercise?["trained_muscles"] is List) {
      for (var trainedMuscle in widget.exercise?["trained_muscles"] ?? []) {
        selectedMuscles.add(trainedMuscle);
      }
    }
  }

  Future<void> _submitData() async {
    bool emptyField = false;
    response = {};

    if (exerciseNameController.text.trim().isEmpty) {
      response["success"] = false;
      response['errors'] = response.containsKey('errors')
          ? [...response['errors'], "Es requereix el nom de l'exercici"]
          : ["Es requereix el nom de l'exercici"];
      emptyField = true;
    }

    if (selectedMuscles.isEmpty) {
      response["success"] = false;
      response['errors'] = response.containsKey('errors')
          ? [...response['errors'], "No hi ha cap múscul seleccionat"]
          : ["No hi ha cap múscul seleccionat"];
      emptyField = true;
    }

    if (emptyField) {
      setState(() {});
      return;
    }

    final exercise = {
      "name": exerciseNameController.text.trim(),
      "description": exerciseDescriptionController.text.trim(),
      "trained_muscles": selectedMuscles,
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

      exercise['picture'] = updatedImageURL!;

      setState(() {
        isCreating = false;
      });
    }

    final apiService = ApiTrainingService();
    final result = await apiService.editExercise(exercise, widget.exercise!["id"].toString());

    setState(() {
      response = result;
    });

    if (result["success"]) {
      final databaseHelper = DatabaseHelper.instance;

      final updatedExercise = Exercise(
        id: widget.exercise!["id"],
        name: exercise["name"].toString(),
        description: exercise["description"].toString(),
        user: widget.exercise!["user"].toString(),
        trainedMuscles: (exercise["trained_muscles"] as List<dynamic>).map((e) => e.toString()).toList(),
      );

      await databaseHelper.updateExercise(updatedExercise);

      if (mounted) {
        Navigator.pop(context, true);
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
              const RelativeSizedBox(height: 0.5),
              const Text(
                "Edita l'exercici",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                ),
              ),
              const RelativeSizedBox(height: 2),
              _buildExerciseForm(),
              const RelativeSizedBox(height: 2),
              CustomButton(
                text: "Editar exercici",
                onTap: _submitData,
              ),
              const RelativeSizedBox(height: 2),
              if (isCreating)
                ...[
                  const RotatingImage(),
                  const RelativeSizedBox(height: 2),
                ]
              else if (response.isNotEmpty && !response["success"])
                ...[
                  MessagesBox(
                    messages: response["errors"],
                    height: 6,
                    color: Colors.red,
                  ),
                  const RelativeSizedBox(height: 4),
                ]
              else
                const RelativeSizedBox(height: 10),
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
            setState(() {
              selectedMuscles = selectedItems;
            });
          },
          itemLabel: (item) => item,
        ),
      ],
    );
  }
}
