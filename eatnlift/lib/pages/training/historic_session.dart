import 'package:eatnlift/custom_widgets/rotating_logo.dart';
import 'package:eatnlift/services/session_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eatnlift/custom_widgets/exercise_set_card.dart';
import 'package:eatnlift/services/api_training_service.dart';

class HistoricSessionPage extends StatefulWidget {
  final String date;

  const HistoricSessionPage({
    super.key,
    required this.date
  });

  @override
  State<HistoricSessionPage> createState() => _HistoricSessionPageState();
}

class _HistoricSessionPageState extends State<HistoricSessionPage> {
  final SessionStorage sessionStorage = SessionStorage();
  List<dynamic>? sessionExercises;
  bool isLoading = true;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    await _fetchCurrentUserId();
    await _fetchSessionData();
  }

  Future<void> _fetchCurrentUserId() async {
    final userId = await sessionStorage.getUserId();
    setState(() {
      currentUserId = userId;
    });
  }

  Future<void> _fetchSessionData() async {
    setState(() => isLoading = true);

    final apiService = ApiTrainingService();
    final response = await apiService.getSession(currentUserId!, widget.date);

    setState(() {
      sessionExercises = response["session"]["exercises"];
      isLoading = false;
    });
  }

  String _capitalizeFirstLetter(String input) {
    if (input.isEmpty) return input;
    return '${input[0].toUpperCase()}${input.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    final String capitalizedDate = _capitalizeFirstLetter(
      DateFormat('EEEE dd/MM/yyyy', 'ca').format(DateFormat('yyyy-MM-dd').parse(widget.date)),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: Text(capitalizedDate),
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: isLoading
            ? Center(child: RotatingImage(),)
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ListView.builder(
                  itemCount: sessionExercises?.length ?? 0,
                  itemBuilder: (context, index) {
                    final exerciseItem = sessionExercises![index];
                    return ExerciseSetCard(
                      key: ValueKey(exerciseItem["exercise"]['id']),
                      exerciseItem: exerciseItem,
                      onExerciseUpdated: (value) => {},
                      isEditable: false,
                    );
                  },
                ),
              ),
      ),
    );
  }
}
