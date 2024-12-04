import 'package:eatnlift/custom_widgets/round_button.dart';
import 'package:eatnlift/services/api_training_service.dart';
import 'package:eatnlift/services/session_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../custom_widgets/ying_yang_toggle.dart';
import '../../custom_widgets/custom_textfield.dart';
import '../../custom_widgets/relative_sizedbox.dart';
import '../../services/api_nutrition_service.dart';
import 'dart:async';

class TrainingSearchPage extends StatefulWidget {
  final List<Map<String, dynamic>>? selectedExercises;
  final List<Map<String, dynamic>>? selectedWorkouts;
  final Function(List<Map<String,dynamic>>?)? onCheck;
  final bool searchExercises;
  final bool searchWorkouts;
  final bool isCreating;

  const TrainingSearchPage({
    super.key,
    this.selectedExercises,
    this.selectedWorkouts,
    this.onCheck,
    this.searchExercises = true,
    this.searchWorkouts = true,
    this.isCreating = false,
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
    if (query.isEmpty) {
      if (mounted) setState(() => exercises?.clear());
      return;
    }
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

  Future<void> _searchWorkouts() async {
    final query = searchController.text;
    if (query.isEmpty) {
      if (mounted) setState(() => workouts?.clear());
      return;
    }
    final apiTrainingService = ApiTrainingService();
    final response = {}; // = await apiTrainingService.getWorkouts(query);
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

    final String id = selectedItem["id"];
    final bool isSelected = selectedItem["selected"] == true;

    final int existingIndex = selectedList.indexWhere((item) => item["id"] == id);

    if (isSelected) {
      if (existingIndex == -1) {
        selectedList.add(selectedItem);
      } else {
        selectedList[existingIndex] = selectedItem;
      }
    } else {
      selectedList.removeWhere((item) => item["id"] == id);
    }

    setState(() {});
  }

  Widget _buildExerciseList(List<Map<String, dynamic>> exercises) {
    return ListView.builder(
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final foodItem = exercises[index];
        return (Text("hola"));
      },
    );
  }

  Widget _buildWorkoutList(List<Map<String, dynamic>> workouts) {
    return ListView.builder(
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final recipe = workouts[index];
        return (Text("hola"));
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
          padding: const EdgeInsets.symmetric(horizontal: 30),
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