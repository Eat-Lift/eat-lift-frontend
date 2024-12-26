import 'package:eatnlift/custom_widgets/exercise_card.dart';
import 'package:eatnlift/custom_widgets/expandable_text.dart';
import 'package:eatnlift/custom_widgets/human_body.dart';
import 'package:eatnlift/custom_widgets/rotating_logo.dart';
import 'package:eatnlift/pages/training/workout_edit.dart';
import 'package:eatnlift/services/api_training_service.dart';
import 'package:flutter/material.dart';

import '../../custom_widgets/relative_sizedbox.dart';

import '../../services/session_storage.dart';

class WorkoutPage extends StatefulWidget {
  final int workoutId;
  final bool isCreating;

  const WorkoutPage({
    super.key,
    required this.workoutId,
    this.isCreating = true,
  });

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final SessionStorage sessionStorage = SessionStorage();
  String? currentUserId;
  
  late Map<String, dynamic>? workoutData;
  late Map<String, dynamic>? exercises;
  late List<dynamic>? trainedMuscles;
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
    await _fetchWorkoutData();
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

  Future<void> _fetchWorkoutData() async {
    final apiService = ApiTrainingService();
    final workout = await apiService.getWorkout(widget.workoutId.toString());
    workoutData = workout["workout"];
    exercises = {};
    exercises = {
      for (var e in workoutData?["exercises"] as List)
        e["exercise"]["id"].toString(): {
          "id": e["exercise"]["id"],
          "name": e["exercise"]["name"],
        }
    };
    trainedMuscles = [];
    for (var e in workoutData?["exercises"] as List) {
      trainedMuscles?.addAll(e["exercise"]["trained_muscles"]);
    }
  }

  Future<void> _fetchSaved() async {
    final apiService = ApiTrainingService();
    final response = await apiService.getWorkoutSaved(widget.workoutId.toString());
    isSaved = response["is_saved"];
  }

  void _toggleSaved() async {
    final apiService = ApiTrainingService();
    if (isSaved){
      final response = await apiService.unsaveWorkout(widget.workoutId.toString());
      if (response["success"]) {
        setState(() {
          isSaved = false;
        });
      }
    }
    else {
      final response = await apiService.saveWorkout(widget.workoutId.toString());
      if (response["success"]) {
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
          content: const Text("Estàs segur que vols eliminar aquest entrenament?"),
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
                await apiService.deleteWorkout(widget.workoutId.toString());
                if (context.mounted){
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
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
        title: const Text("Entrenament"),
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            children: [
              if (!isLoading) ...[
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RelativeSizedBox(height: 1),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              workoutData?["name"] ?? '',
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
                            if (currentUserId == workoutData?["user"].toString() && !widget.isCreating)
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.black),
                                tooltip: 'Edit',
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditWorkoutPage(workout: workoutData),
                                    )
                                  );

                                  if (result == true) {
                                    _initPage();
                                  }
                                },
                              ),
                            if (currentUserId == workoutData?["user"].toString() && !widget.isCreating)
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
                          text: workoutData?["description"]?.isEmpty ?? true
                              ? "Això està una mica buit"
                              : workoutData?["description"],
                        ),
                      ),
                      RelativeSizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 7.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        constraints: BoxConstraints(
                          minHeight: 0,
                          maxHeight: 162,
                        ),
                        child: exercises!.isNotEmpty
                            ? ListView.builder(
                                itemCount: exercises!.length,
                                itemBuilder: (context, index) {
                                  final exerciseKey = exercises!.keys.elementAt(index);
                                  final exercise = exercises![exerciseKey];
                                  return ExerciseCard(
                                    exercise: exercise,
                                  );
                                },
                              )
                            : 
                            Column(
                              children: [
                                RelativeSizedBox(height: 5),
                                const Center(
                                  child: Text(
                                    "No exercises found",
                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                ),
                                RelativeSizedBox(height: 5),
                              ],
                            ),
                      ),
                      RelativeSizedBox(height: 2),
                      Center(
                        child: HumanBody(
                          width: 350,
                          height: 450,
                          overlayMuscles: trainedMuscles!,
                        ),
                      ),
                      RelativeSizedBox(height: 2),
                    ],
                  )
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