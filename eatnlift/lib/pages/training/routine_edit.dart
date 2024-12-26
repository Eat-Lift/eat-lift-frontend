import 'package:eatnlift/custom_widgets/exercise_card.dart';
import 'package:eatnlift/custom_widgets/relative_sizedbox.dart';
import 'package:eatnlift/custom_widgets/round_button.dart';
import 'package:eatnlift/pages/training/training_search.dart';
import 'package:eatnlift/services/api_training_service.dart';
import 'package:eatnlift/services/session_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EditRoutinePage extends StatefulWidget {
  final List<dynamic> exercises;

  const EditRoutinePage({
    super.key,
    required this.exercises,
  });

  @override
  State<EditRoutinePage> createState() => _EditRoutinePageState();
}

class _EditRoutinePageState extends State<EditRoutinePage> {
  final SessionStorage sessionStorage = SessionStorage();
  late List<dynamic> exercises;
  String? currentUserId;
  

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    exercises = widget.exercises;
    await _fetchCurrentUserId();
  }

  Future<void> _fetchCurrentUserId() async {
    final userId = await sessionStorage.getUserId();
    setState(() {
      currentUserId = userId;
    });
  }

  void onCheck(List<Map<String, dynamic>>? fromSearchExercises, String weekDay) {
    setState(() {
      exercises.removeWhere((e) => e["week_day"] == weekDay);

      exercises.addAll(fromSearchExercises!
          .where((e) => e["selected"] == true)
          .map((e) => {
                "exercise": e,
                "week_day": weekDay,
              }));
    });
    Navigator.pop(context, true);
  }

  void submitEdit() async {
    List<Map<String, dynamic>> updatedExercises = exercises.map((exercise) {
      return {
        "week_day": exercise["week_day"],
        "id": exercise["exercise"]["id"],
      };
    }).toList();

    final apiService = ApiTrainingService();
    await apiService.editRoutine(currentUserId!, updatedExercises);
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text("Editar Rutina"),
        actions: 
          [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: RoundButton(
                icon: Icons.check,
                onPressed: submitEdit,
                size: 35,
              ),
            ),
          ], 
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildRoutineContent(),
        ),
      ),
    );
  }

  Widget _buildRoutineContent() {
    final weekdays = [
      "DILLUNS",
      "DIMARTS",
      "DIMECRES",
      "DIJOUS",
      "DIVENDRES",
      "DISSABTE",
      "DIUMENGE"
    ];

    return ListView(
      children: weekdays
          .map(
            (weekDay) => WeekDayEditSection(
              weekDay: weekDay,
              exercises: exercises
                  .where((exercise) => exercise["week_day"] == weekDay)
                  .toList(),
              onAddPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrainingSearchPage(
                      isCreating: true,
                      selectedExercises: List<Map<String, dynamic>>.from(exercises)
                            .where((exercise) => exercise["week_day"] == weekDay)
                            .map((exercise) => {
                                  "id": exercise["exercise"]["id"],
                                  "name": exercise["exercise"]["name"],
                                  "selected": true,
                                })
                            .toList(),
                      onCheck: (newExercises) => onCheck(newExercises, weekDay),
                    ),
                  ),
                );
                if (result) {
                  setState(() {});
                }
              },
              onExerciseRemoved: (exercise) {
                setState(() {
                  exercises.removeWhere((e) =>
                      e["exercise"]["id"] == exercise["exercise"]["id"] &&
                      e["week_day"] == exercise["week_day"]);
                });
              },
            ),
          )
          .toList(),
    );
  }
}

class WeekDayEditSection extends StatefulWidget {
  final String weekDay;
  final List<dynamic> exercises;
  final VoidCallback onAddPressed;
  final Function(dynamic) onExerciseRemoved;

  const WeekDayEditSection({
    super.key,
    required this.weekDay,
    required this.exercises,
    required this.onAddPressed,
    required this.onExerciseRemoved,
  });

  @override
  State<WeekDayEditSection> createState() => _WeekDayEditSectionState();
}

class _WeekDayEditSectionState extends State<WeekDayEditSection> {
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.0),
          child: Text(
            widget.weekDay,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 7.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white, width: 3),
              ),
              constraints: const BoxConstraints(maxHeight: 155),
              child: widget.exercises.isNotEmpty
                  ? ListView.builder(
                      itemCount: widget.exercises.length + 1,
                      itemBuilder: (context, index) {
                        if (index == widget.exercises.length) {
                          return const RelativeSizedBox(height: 8);
                        }
                        final exercise = widget.exercises[index];
                        return Column(
                          children: [
                            ExerciseCard(
                              key: ValueKey(exercise["exercise"]['id']),
                              exercise: exercise["exercise"],
                              isSelectable: true,
                              initiallySelected: exercise["selected"] ?? true,
                              onSelect: (updatedExercise, type) {
                                if (!updatedExercise["selected"]) {
                                  widget.onExerciseRemoved(exercise);
                                }
                              }
                            ),
                            if (widget.exercises.length == 1)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 70.0),
                              ),
                          ],
                        );
                      },
                    )
                  : const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 60.0),
                        child: Text(
                          "No hi ha exercicis afegits",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
            ),
            Positioned(
              bottom: 13,
              right: 10,
              child: RoundButton(
                icon: FontAwesomeIcons.plus,
                onPressed: widget.onAddPressed,
              ),
            ),
          ],
        ),
        RelativeSizedBox(height: 2),
      ],
    );
  }
}
