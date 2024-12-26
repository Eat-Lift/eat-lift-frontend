import 'package:eatnlift/custom_widgets/exercise_card.dart';
import 'package:eatnlift/custom_widgets/relative_sizedbox.dart';
import 'package:eatnlift/custom_widgets/rotating_logo.dart';
import 'package:eatnlift/custom_widgets/round_button.dart';
import 'package:eatnlift/pages/training/routine_edit.dart';
import 'package:eatnlift/services/api_training_service.dart';
import 'package:flutter/material.dart';
import '../../services/session_storage.dart';

class RoutinePage extends StatefulWidget {
  const RoutinePage({super.key});

  @override
  State<RoutinePage> createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  final SessionStorage sessionStorage = SessionStorage();
  String? currentUserId;
  bool isLoading = true;
  List<dynamic> exercises = [];

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    setState(() => isLoading = true);
    await _fetchCurrentUserId();
    await _fetchRoutine();
    setState(() => isLoading = false);
  }

  Future<void> _fetchCurrentUserId() async {
    final userId = await sessionStorage.getUserId();
    setState(() => currentUserId = userId);
  }

  Future<void> _fetchRoutine() async {
    final apiService = ApiTrainingService();
    final result = await apiService.getRoutine(currentUserId!);

    if (result["success"]) {
      setState(() => exercises = result["exercises"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text("Rutina"),
         actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: RoundButton(
              icon: Icons.edit,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditRoutinePage(exercises: exercises)),
                );
                if (result == true){
                  _fetchRoutine();
                }
              },
              size: 35,
            ),
          ),
        ],    
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: isLoading
              ? _buildLoadingIndicator()
              : _buildRoutineContent(),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: const [
        SizedBox(height: 25),
        Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              SizedBox(height: 10),
              RotatingImage(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoutineContent() {
    final weekdaysWithExercises = [
      "DILLUNS",
      "DIMARTS",
      "DIMECRES",
      "DIJOUS",
      "DIVENDRES",
      "DISSABTE",
      "DIUMENGE"
    ].where((weekDay) =>
        exercises.any((exercise) => exercise["week_day"] == weekDay));

    if (weekdaysWithExercises.isEmpty) {
      return const Center(
        child: Text(
          "No tens entrenaments a la rutina",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView(
      children: weekdaysWithExercises
          .map((weekDay) => WeekDaySection(
                weekDay: weekDay,
                exercises: exercises
                    .where((exercise) => exercise["week_day"] == weekDay)
                    .toList(),
              ))
          .toList(),
    );
  }
}

class WeekDaySection extends StatelessWidget {
  final String weekDay;
  final List<dynamic> exercises;

  const WeekDaySection({
    super.key,
    required this.weekDay,
    required this.exercises,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.0),
          child: Text(
            weekDay,
            style: TextStyle(
                color: Colors.grey[700],
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
          ),
        ),
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
          child: ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return ExerciseCard(
                exercise: exercise["exercise"],
              );
            },
          ),
        ),
        RelativeSizedBox(height: 2),
      ],
    );
  }
}
