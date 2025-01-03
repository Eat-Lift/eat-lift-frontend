import 'package:eatnlift/custom_widgets/exercise_card.dart';
import 'package:eatnlift/custom_widgets/round_button.dart';
import 'package:eatnlift/custom_widgets/workout_card.dart';
import 'package:eatnlift/services/api_training_service.dart';
import 'package:eatnlift/services/database_helper.dart';
import 'package:eatnlift/services/session_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../custom_widgets/ying_yang_toggle.dart';
import '../../custom_widgets/custom_textfield.dart';
import '../../custom_widgets/relative_sizedbox.dart';
import 'dart:async';

class TrainingSearchPage extends StatefulWidget {
  final List<Map<String, dynamic>>? selectedExercises;
  final List<Map<String, dynamic>>? selectedWorkouts;
  final Function(List<Map<String,dynamic>>?)? onCheck;
  final bool searchExercises;
  final bool searchWorkouts;
  final bool isCreating;
  final bool offline;

  const TrainingSearchPage({
    super.key,
    this.selectedExercises,
    this.selectedWorkouts,
    this.onCheck,
    this.searchExercises = true,
    this.searchWorkouts = true,
    this.isCreating = false,
    this.offline = false,
  });

  @override
  TrainingSearchPageState createState() => TrainingSearchPageState();
}

class TrainingSearchPageState extends State<TrainingSearchPage> {
  String? currentUserId;
  final SessionStorage sessionStorage = SessionStorage();
  final TextEditingController searchController = TextEditingController();

  bool isSearchingExercises = true;

  List<Map<String, dynamic>>? exercises;
  List<Map<String, dynamic>>? workouts;

  Timer? debounce;
  
  get apiTrainingService => null;

  @override
  void initState() {
    super.initState();
    if (!widget.searchExercises && widget.searchWorkouts) {
      isSearchingExercises = false;
    }
    _fetchCurrentUserId();
    searchController.addListener(_onSearchChanged);
    if (isSearchingExercises){
      _searchExercises();
    }
    else {
      _searchWorkouts();
    }
  }

  Future<void> _fetchCurrentUserId() async {
    final userId = await sessionStorage.getUserId();
    setState(() {
      currentUserId = userId!;
    });
  }

  void toggleSearchMode(bool isExersiceSelected) {
    setState(() {
      isSearchingExercises = isExersiceSelected;
      searchController.clear();
    });
    _onSearchChanged();
  }

  void _onSearchChanged() {
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 300), () {
      if (isSearchingExercises) {
        _searchExercises();
      }
      else {
        _searchWorkouts();
      }
    });
  }

  Future<void> _searchExercises() async {
    final query = searchController.text;
    if (widget.offline) {
      final databaseHelper = DatabaseHelper.instance;
      final localExercises = await databaseHelper.searchExercises(query);
      if (mounted) {
        setState(() {
          exercises = localExercises
              .map((exercise) => {
                    "id": exercise.id,
                    "name": exercise.name,
                    "description": exercise.description,
                    "user": exercise.user,
                    "trained_muscles": exercise.trainedMuscles,
                  })
              .toList();
        });
      }
    } else {
      final apiTrainingService = ApiTrainingService();
      final response = await apiTrainingService.getExercises(query);
      if (response["success"]) {
        if (mounted) {
          setState(() {
            exercises = (response["exercises"] as List)
                .map((item) => item as Map<String, dynamic>)
                .toList();
          });
        }
      }
    }
  }

  Future<void> _searchWorkouts() async {
    final query = searchController.text;
    final apiTrainingService = ApiTrainingService();
    final response = await apiTrainingService.getWorkouts(query);
    if (response["success"]) {
      if (mounted) {
        setState(() {
          workouts = (response["workouts"] as List)
              .map((item) => item as Map<String, dynamic>)
              .toList();
        });
      }
    }
  }

  void _onSelectItem(Map<String, dynamic>? selectedItem, String type) {
    if (selectedItem == null) return;

    final List<Map<String, dynamic>>? selectedList =
        type == "exercise" ? widget.selectedExercises : widget.selectedWorkouts;

    if (selectedList == null) return;

    final String id = selectedItem["id"].toString();
    final bool isSelected = selectedItem["selected"] == true;

    final int existingIndex = selectedList.indexWhere((item) => item["id"] == id);

    if (isSelected) {
      if (existingIndex == -1) {
        selectedList.add(selectedItem);
      } else {
        selectedList[existingIndex] = selectedItem;
      }
    } else {
      selectedList.removeWhere((item) => item["id"].toString() == id);
    }

    setState(() {});
  }

  void _onAddWorkout(List<Map<String, dynamic>>? selectedExercises) {
    if (selectedExercises != null) {
      for (Map<String, dynamic> selectedExercise in selectedExercises) {
        if (selectedExercise["selected"] == true) {
          final existingIndex = widget.selectedExercises?.indexWhere(
            (item) => item["id"] == selectedExercise["id"],
          );
          if (existingIndex == null || existingIndex == -1) {
            widget.selectedExercises?.add(selectedExercise);
          } else  {
            widget.selectedExercises?[existingIndex] = selectedExercise;
          }
        } else {
          widget.selectedExercises?.removeWhere(
            (item) => item["id"] == selectedExercise["id"],
          );
        }
      }
      setState(() {});
    }
  }

  Widget _buildExerciseList(List<Map<String, dynamic>> exercises) {
    return ListView.builder(
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return ExerciseCard(
          key: ValueKey(exercise["id"]),
          exercise: exercise,
          initiallySelected: widget.selectedExercises?.firstWhere(
                (selectedItem) => selectedItem['id'] == exercise['id'],
                orElse: () => {'selected': false},
              )['selected'] ??
              false,
          isSelectable: widget.isCreating,
          isCreating: widget.isCreating,
          onSelect: _onSelectItem,
          clickable: !widget.offline,
          onTap: _onSearchChanged,
        );
      },
    );
  }

  Widget _buildWorkoutList(List<Map<String, dynamic>> workouts) {
    return ListView.builder(
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final workout = workouts[index];
        return WorkoutCard(
          key: ValueKey(workout["id"]),
          workout: workout,
          isCreating: widget.isCreating,
          isAddable: widget.isCreating,
          onAdd: _onAddWorkout,
          onTap: _onSearchChanged,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text("Cercar"),
        actions: widget.isCreating
            ? [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: RoundButton(
                    icon: Icons.check,
                    onPressed: () {
                      if (widget.onCheck != null) {
                        if (widget.searchExercises) {
                          widget.onCheck!(widget.selectedExercises);
                        }
                        else if (widget.searchWorkouts) {
                          widget.onCheck!(widget.selectedWorkouts);
                        }
                      }
                    },
                    size: 35,
                  ),
                ),
              ]
            : null,
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              if (widget.searchExercises && widget.searchWorkouts) ...[
                YinYangToggle(
                  isLeftSelected: isSearchingExercises,
                  leftText: "Exercicis",
                  rightText: "Entrenaments",
                  onToggle: toggleSearchMode,
                ),
              ],

              const RelativeSizedBox(height: 2),

              CustomTextfield(
                controller: searchController,
                hintText: isSearchingExercises ? "Cerca exercicis" : "Cerca entrenaments",
                centerText: false,
                icon: FontAwesomeIcons.magnifyingGlass,
              ),
              RelativeSizedBox(height: 1),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (isSearchingExercises) {
                      if (exercises != null && exercises!.isNotEmpty) {
                        return _buildExerciseList(exercises!);
                      } else {
                        return const Center(
                          child: Text(
                            "No hi ha resultats. Prova amb una altra cerca",
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }
                    } else {
                      if (workouts != null && workouts!.isNotEmpty) {
                        return _buildWorkoutList(workouts!);
                      } else {
                        return const Center(
                          child: Text(
                            "No hi ha resultats. Prova amb una altra cerca",
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
              const RelativeSizedBox(height: 2),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    debounce?.cancel();
    super.dispose();
  }
}