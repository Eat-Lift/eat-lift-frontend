import 'package:eatnlift/custom_widgets/exercise_set_card.dart';
import 'package:eatnlift/custom_widgets/rotating_logo.dart';
import 'package:eatnlift/custom_widgets/round_button.dart';
import 'package:eatnlift/pages/training/training_search.dart';
import 'package:eatnlift/services/api_training_service.dart';
import 'package:eatnlift/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

import '../../custom_widgets/relative_sizedbox.dart';

import '../../services/session_storage.dart';

class SessionPage extends StatefulWidget {
  const SessionPage({
    super.key,
  });

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  final SessionStorage sessionStorage = SessionStorage();
  String? currentUserId;
  List<dynamic>? routineExercises;
  List<dynamic>? sessionExercises;
  
  bool isLoading = true;
  DateTime? sessionDate;

  bool _isSubmitting = false;
  Timer? _submitTimer;
  final int _submitIntervalSeconds = 30;

  @override
  void initState() {
    super.initState();
    _initPage();
    _startAutoSubmitTimer();
  }

    @override
  void dispose() {
    _submitTimer?.cancel();
    super.dispose();
  }

  void _startAutoSubmitTimer() {
    _submitTimer = Timer.periodic(
      Duration(seconds: _submitIntervalSeconds),
      (timer) => _submitData(),
    );
  }
  
  Future<void> _initPage() async {
    setState((){
      isLoading = true;
    });
    sessionDate = DateTime.now();
    await _fetchCurrentUserId();
    await _fetchSessionData();
    await _fetchRoutine();
    await _initializeExercises();
    setState((){
      isLoading = false;
    });
  }

  String _capitalizeFirstLetter(String input) {
    if (input.isEmpty) return input;
    return '${input[0].toUpperCase()}${input.substring(1)}';
  }

  Future<void> _fetchCurrentUserId() async {
    final userId = await sessionStorage.getUserId();
    currentUserId = userId;
  }

  Future<void> _fetchSessionData() async {
    final apiService = ApiTrainingService();
    final response = await apiService.getSession(currentUserId!, DateFormat('yyyy-MM-dd').format(sessionDate!));
    sessionExercises = response["session"]["exercises"];
  }

  Future<void> _fetchRoutine() async {
    final apiService = ApiTrainingService();
    final response = await apiService.getRoutine(currentUserId!);
    routineExercises = response["exercises"];
  }

  Future<void> _initializeExercises() async {
    final apiService = ApiTrainingService();
    for (var exercise in routineExercises!) {
      if (exercise["week_day"].toLowerCase() == DateFormat('EEEE', 'ca').format(sessionDate!).toLowerCase()){
        if(!sessionExercises!.any((e) => e["exercise"]["id"] == exercise["exercise"]["id"])){
          final response = await apiService.getExerciseWeight(exercise["exercise"]["id"].toString());
          sessionExercises!.add({"exercise": exercise["exercise"], "sets": [{"weight": response["weight"]["weight"], "reps": response["weight"]["reps"]}]});
        }
      } 
    }
  }

  Future<void> _onCheck(List<Map<String, dynamic>>? newExercises) async {
    if (newExercises == null) return;

    final Set<int> newExerciseIds = newExercises
        .map((exercise) => exercise["id"] as int)
        .toSet();

    sessionExercises!.removeWhere((sessionExercise) {
      final int sessionExerciseId = sessionExercise["exercise"]["id"] as int;
      return !newExerciseIds.contains(sessionExerciseId);
    });

    final Set<int> currentExerciseIds = sessionExercises!
      .map((exercise) => exercise["exercise"]["id"] as int)
      .toSet();

    final List<Map<String, dynamic>> exercisesToAdd = newExercises.where((newExercise) {
      final int newExerciseId = newExercise["id"] as int;
      return !currentExerciseIds.contains(newExerciseId);
      }).map((newExercise) {

      return {
        "exercise": {
          "id": newExercise["id"],
          "name": newExercise["name"],
          "description": newExercise["description"],
          "user": newExercise["user"],
        },
        "sets": [
          {"weight": 0.0, "reps": 0},
        ],
      };
    }).toList();

    final apiService = ApiTrainingService();
    for (var exercise in exercisesToAdd) {
      final response = await apiService.getExerciseWeight(exercise["exercise"]["id"].toString());
      exercise["sets"] = [{"weight": response["weight"]["weight"], "reps": response["weight"]["reps"]}];
    }

    sessionExercises!.addAll(exercisesToAdd);

    setState(() {});
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _submitData() async {
    if (_isSubmitting) return;
    _isSubmitting = true;

    Map<String, dynamic> sessionData = {
      "date": DateFormat('yyyy-MM-dd').format(sessionDate!),
      "exercises": sessionExercises!.map((sessionExercise) {
        return {
          "exercise": sessionExercise["exercise"]["id"],
          "sets": sessionExercise["sets"]
        };
      }).toList(),
    };

    final apiService = ApiTrainingService();
    final databaseHelper = DatabaseHelper.instance;

    try {
      await apiService.editSession(currentUserId!, sessionData);

      final db = await databaseHelper.database;

      final sessionId = await db.insert(
        'sessions',
        {
          'user': currentUserId!,
          'date': DateFormat('yyyy-MM-dd').format(sessionDate!),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (final sessionExercise in sessionExercises!) {
        final exercise = sessionExercise['exercise'];

        final existingExercise = await db.query(
          'exercises',
          where: 'name = ? AND user = ?',
          whereArgs: [exercise['name'], exercise['user']],
        );

        if (existingExercise.isEmpty) {
          await db.insert(
            'exercises',
            {
              'name': exercise['name'],
              'description': exercise['description'],
              'user': exercise['user'],
              'trained_muscles': (exercise['trained_muscles'] as List<dynamic>).join(','),
            },
          );
        }

        final exerciseId = await db.insert(
          'session_exercises',
          {
            'session_id': sessionId,
            'exercise_name': exercise['name'],
            'exercise_user': exercise['user'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        for (final set in sessionExercise['sets']) {
          await db.insert(
            'session_sets',
            {
              'session_exercise_id': exerciseId,
              'weight': set['weight'],
              'reps': set['reps'],
            },
          );
        }
      }
    } catch (error) {
      print("Error submitting data: $error");
    } finally {
      _isSubmitting = false;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final String capitalizedDate = sessionDate != null
        ? _capitalizeFirstLetter(
            DateFormat('EEEE dd/MM/yyyy', 'ca').format(sessionDate!))
        : "Entrenament";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: Text(capitalizedDate),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: RoundButton(
              icon: Icons.check,
              onPressed: () {
                _submitData();
                Navigator.pop(context, true);
              },
              size: 35,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: isLoading
                  ? Column(
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
                      ],
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: sessionExercises!.length,
                            itemBuilder: (context, index) {
                              final exerciseItem = sessionExercises![index];
                              return ExerciseSetCard(
                                key: ValueKey(exerciseItem["exercise"]['id']),
                                exerciseItem: exerciseItem,
                                onExerciseUpdated: (updatedExerciseItem) {
                                  setState(() {
                                    if (updatedExerciseItem["sets"].isEmpty) {
                                      sessionExercises!.removeAt(index);
                                    } else {
                                      sessionExercises![index] = updatedExerciseItem;
                                    }
                                  });
                                },
                              );
                            },
                          ),
                          RelativeSizedBox(height: 17),
                        ],
                      ),
                    ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: RoundButton(
                size: 100,
                icon: FontAwesomeIcons.plus,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TrainingSearchPage(
                        isCreating: true,
                        selectedExercises: List<Map<String, dynamic>>.from(sessionExercises!)
                            .map((exercise) => {
                                  "id": exercise["exercise"]["id"],
                                  "name": exercise["exercise"]["name"],
                                  "selected": true,
                                })
                            .toList(),
                        onCheck: (newExercises) => _onCheck(newExercises),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}