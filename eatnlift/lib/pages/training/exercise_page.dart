import 'package:eatnlift/custom_widgets/expandable_text.dart';
import 'package:eatnlift/custom_widgets/human_body.dart';
import 'package:eatnlift/custom_widgets/rotating_logo.dart';
import 'package:eatnlift/pages/training/exercise_edit.dart';
import 'package:eatnlift/services/api_training_service.dart';
import 'package:flutter/material.dart';

import '../../custom_widgets/expandable_image.dart';
import '../../custom_widgets/relative_sizedbox.dart';

import '../../services/session_storage.dart';

import '../../models/exercise.dart';
import '../../services/database_helper.dart';

class ExercisePage extends StatefulWidget {
  final int exerciseId;
  final bool isCreating;

  const ExercisePage({
    super.key,
    required this.exerciseId,
    this.isCreating = true,
  });

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  final SessionStorage sessionStorage = SessionStorage();
  String? currentUserId;
  
  late Map<String, dynamic>? exerciseData;
  bool isLoading = true;
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    setState((){
      isLoading = true;
    });
    await _fetchExerciseData();
    await _fetchCurrentUserId();
    await _fetchSaved();
    setState((){
      isLoading = false;
    });
  }

  Future<void> _fetchCurrentUserId() async {
    final userId = await sessionStorage.getUserId();
    currentUserId = userId;
  }

  Future<void> _fetchExerciseData() async {
    final apiService = ApiTrainingService();
    final exercise = await apiService.getExercise(widget.exerciseId.toString());
    exerciseData = exercise["exercise"];
  }

  Future<void> _fetchSaved() async {
    final apiService = ApiTrainingService();
    final response = await apiService.getExerciseSaved(widget.exerciseId.toString());
    isSaved = response["is_saved"];
  }

  void _toggleSaved() async {
    final apiService = ApiTrainingService();
    final databaseHelper = DatabaseHelper.instance;

    final String exerciseName = exerciseData!["name"];
    final String userId = exerciseData!["user"].toString();

    if (isSaved) {
      final response = await apiService.unsaveExercise(widget.exerciseId.toString());

      if (response["success"]) {
        final db = await databaseHelper.database;
        await db.delete(
          'exercises',
          where: 'name = ? AND user = ?',
          whereArgs: [exerciseName, userId],
        );

        setState(() {
          isSaved = false;
        });
      }
    } else {
      final response = await apiService.saveExercise(widget.exerciseId.toString());

      if (response["success"]) {
        final exercise = Exercise(
          name: exerciseName,
          description: exerciseData!["description"],
          user: exerciseData!["user"].toString(),
          trainedMuscles: List<String>.from(exerciseData!["trained_muscles"]),
        );

        await databaseHelper.insertExercise(exercise);

        setState(() {
          isSaved = true;
        });
      }
    }
  }

  void _deleteExercise() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmació"),
          content: const Text("Estàs segur que vols eliminar aquest exercici?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel·lar"),
            ),
            TextButton(
              onPressed: () async {
                final apiService = ApiTrainingService();
                final databaseHelper = DatabaseHelper.instance;
                try {
                  final response = await apiService.deleteExercise(widget.exerciseId.toString());

                  if (response["success"]) {
                    await databaseHelper.deleteExerciseById(widget.exerciseId);

                    if (context.mounted) {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Exercici eliminat correctament")),
                    );
                  } else {
                    throw Exception("Failed to delete exercise on the backend.");
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
              },
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text("Exercici"),
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Stack(
            children: [
              if (!isLoading) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RelativeSizedBox(height: 1),
                    Row(
                      children: [
                        ExpandableImage(
                          initialImageUrl: exerciseData?["picture"],
                          width: 70,
                          height: 70,
                        ),
                        RelativeSizedBox(width: 5),
                        Flexible(
                          child: Text(
                            exerciseData?["name"] ?? '',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 22,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                    RelativeSizedBox(height: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          IconButton(
                            icon: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                              color: Colors.black,
                            ),
                            tooltip: isSaved ? 'Unsave' : 'Save',
                            onPressed: _toggleSaved,
                          ),
                          if (currentUserId == exerciseData?["user"].toString() && !widget.isCreating)
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black),
                              tooltip: 'Edit',
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditExercisePage(exercise: exerciseData),
                                  )
                                );

                                if (result == true){
                                  _initPage();
                                }
                              },
                            ),
                          if (currentUserId == exerciseData?["user"].toString() && !widget.isCreating)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.black),
                              tooltip: 'Delete',
                              onPressed: _deleteExercise,
                            ),
                      ],
                    ),
                    RelativeSizedBox(height: 1),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ExpandableText(
                        text: exerciseData?["description"]?.isEmpty ?? true
                            ? "Això està una mica buit"
                            : exerciseData?["description"],
                      ),
                    ),
                    RelativeSizedBox(height: 2),
                    Center(
                      child: HumanBody(
                        width: 350,
                        height: 450,
                        overlayMuscles: exerciseData!["trained_muscles"],
                      ),
                    ),
                  ],
                ),
              ]
              else ...[
                Column(
                  children: [
                    RelativeSizedBox(height: 25),
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          RelativeSizedBox(height: 10),
                          RotatingImage(),   
                        ],
                      ),
                    ),
                  ]
                ),
              ]
            ]
          ),
        ),
      ),
    );
  }
}