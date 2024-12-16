import 'package:eatnlift/custom_widgets/exercise_set_card.dart';
import 'package:eatnlift/custom_widgets/rotating_logo.dart';
import 'package:eatnlift/custom_widgets/round_button.dart';
import 'package:eatnlift/pages/training/training_search.dart';
import 'package:eatnlift/services/api_training_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();
    _initPage();
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
    for (var exercise in routineExercises!) {
      if (exercise["week_day"].toLowerCase() == DateFormat('EEEE', 'ca').format(sessionDate!).toLowerCase()){
        if(!sessionExercises!.any((e) => e["exercise"]["id"] == exercise["exercise"]["id"])){
          sessionExercises!.add({"exercise": exercise["exercise"], "sets": [{"weight": 0.0, "reps": 0}]});
        }
      } 
    }
  }

  void _onCheck(List<Map<String, dynamic>>? newExercises) {
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

    sessionExercises!.addAll(exercisesToAdd);

    setState(() {});
    Navigator.pop(context);
  }

  void _submitData() async {
    Map<String, dynamic> sessionData = {};
    sessionData["date"] =  DateFormat('yyyy-MM-dd').format(sessionDate!);
    sessionData["exercises"] = [];
    for (var sessionExercise in sessionExercises!) {
      sessionData["exercises"].add({"exercise": sessionExercise["exercise"]["id"], "sets": sessionExercise["sets"]});
    }
    final apiService = ApiTrainingService();
    await apiService.editSession(currentUserId!, sessionData);
    if (mounted) {
      Navigator.pop(context, true);
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
              onPressed: _submitData,
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
              padding: const EdgeInsets.symmetric(horizontal: 40),
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