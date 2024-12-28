import 'package:eatnlift/custom_widgets/exercise_set_card.dart';
import 'package:eatnlift/custom_widgets/rotating_logo.dart';
import 'package:eatnlift/custom_widgets/round_button.dart';
import 'package:eatnlift/pages/training/training_search.dart';
import 'package:eatnlift/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import '../../custom_widgets/relative_sizedbox.dart';

import '../../services/session_storage.dart';

class OfflineSessionPage extends StatefulWidget {
  const OfflineSessionPage({
    super.key,
  });

  @override
  State<OfflineSessionPage> createState() => _OfflineSessionPageState();
}

class _OfflineSessionPageState extends State<OfflineSessionPage> {
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
    setState((){
      isLoading = false;
    });
  }

  Future<void> _fetchCurrentUserId() async {
    final userId = await sessionStorage.getUserId();
    currentUserId = userId;
  }

  Future<void> _fetchSessionData() async {
    final databaseHelper = DatabaseHelper.instance;

    try {
      final sessionDateStr = DateFormat('yyyy-MM-dd').format(sessionDate!);
      final db = await databaseHelper.database;

      final sessionQuery = await db.query(
        'sessions',
        where: 'date = ? AND user = ?',
        whereArgs: [sessionDateStr, currentUserId],
      );

      if (sessionQuery.isEmpty) {
        sessionExercises = [];
        return;
      }

      final sessionId = sessionQuery.first['id'];

      final exercisesQuery = await db.query(
        'session_exercises',
        where: 'session_id = ?',
        whereArgs: [sessionId],
        orderBy: 'id ASC',
      );

      List<Map<String, dynamic>> exercisesWithSets = [];

      for (final exercise in exercisesQuery) {
        final exerciseDetails = await db.query(
          'exercises',
          where: 'name = ? AND user = ?',
          whereArgs: [exercise['exercise_name'], exercise['exercise_user']],
        );

        if (exerciseDetails.isNotEmpty) {
          final setsQuery = await db.query(
            'session_sets',
            where: 'session_exercise_id = ?',
            whereArgs: [exercise['id']],
          );

          exercisesWithSets.add({
            'exercise': exerciseDetails.first,
            'sets': setsQuery.map((set) => {
              'weight': set['weight'],
              'reps': set['reps'],
            }).toList(),
          });
        }
      }

      sessionExercises = exercisesWithSets;
    } catch (error) {
      print("Error fetching session data: $error");
      sessionExercises = [];
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
        },
        "sets": [
          {"weight": 0.0, "reps": 0},
        ],
      };
    }).toList();

    for (var exercise in exercisesToAdd) {
      exercise["sets"] = [{"weight": 0.0, "reps": 0}];
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

    final databaseHelper = DatabaseHelper.instance;

    try {
      final db = await databaseHelper.database;


      final sessionDateStr = DateFormat('yyyy-MM-dd').format(sessionDate!);


      final existingSession = await db.query(
        'sessions',
        where: 'date = ? AND user = ?',
        whereArgs: [sessionDateStr, currentUserId],
      );

      int sessionId;
      if (existingSession.isNotEmpty) {
        sessionId = existingSession.first['id'] as int;

        await db.delete(
          'session_sets',
          where: 'session_exercise_id IN (SELECT id FROM session_exercises WHERE session_id = ?)',
          whereArgs: [sessionId],
        );
        await db.delete(
          'session_exercises',
          where: 'session_id = ?',
          whereArgs: [sessionId],
        );
      } else {
        sessionId = await db.insert(
          'sessions',
          {'user': currentUserId, 'date': sessionDateStr},
        );
      }

      for (final sessionExercise in sessionExercises!) {
        final exerciseData = sessionExercise['exercise'];

        final existingExercise = await db.query(
          'exercises',
          where: 'name = ? AND user = ?',
          whereArgs: [exerciseData['name'], currentUserId],
        );

        if (existingExercise.isEmpty) {
          await db.insert(
            'exercises',
            {
              'name': exerciseData['name'],
              'description': exerciseData['description'] ?? '',
              'user': currentUserId,
              'trained_muscles': (exerciseData['trained_muscles'] as List<dynamic>).join(','),
            },
          );
        }

        final sessionExerciseId = await db.insert(
          'session_exercises',
          {
            'session_id': sessionId,
            'exercise_name': exerciseData['name'],
            'exercise_user': currentUserId,
          },
        );

        for (final set in sessionExercise['sets']) {
          await db.insert(
            'session_sets',
            {
              'session_exercise_id': sessionExerciseId,
              'weight': set['weight'],
              'reps': set['reps'],
            },
          );
        }
      }

      print('Session data saved locally.');
    } catch (error) {
      print('Error saving session data: $error');
    } finally {
      _isSubmitting = false;
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: Text("Entrenament"),
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
                                offline: true,
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
                          RelativeSizedBox(height: 15),
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
                        offline: true,
                        searchWorkouts: false,
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