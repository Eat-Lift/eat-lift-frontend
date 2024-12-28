import 'package:eatnlift/custom_widgets/custom_graph.dart';
import 'package:eatnlift/custom_widgets/session_card.dart';
import 'package:eatnlift/pages/training/exercise_page.dart';
import 'package:eatnlift/pages/training/historic_session.dart';
import 'package:eatnlift/pages/training/routine.dart';
import 'package:eatnlift/pages/training/session.dart';
import 'package:eatnlift/pages/training/training_create.dart';
import 'package:eatnlift/pages/training/training_search.dart';
import 'package:eatnlift/services/api_training_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../custom_widgets/round_button.dart';
import '../../custom_widgets/relative_sizedbox.dart';
import '../../custom_widgets/rotating_logo.dart';

import '../../services/session_storage.dart';

import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  final SessionStorage sessionStorage = SessionStorage();
  String? currentUserId;
  Map<String, dynamic> sessionsSummary = {};
  List<dynamic> exercisesWeights = [];

  bool isLoading = true;

  final List<Color> graphColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    setState(() {
      isLoading = true;
    });
    await _fetchCurrentUserId();
    await _fetchSessionsData();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchCurrentUserId() async {
    final userId = await sessionStorage.getUserId();
    setState(() {
      currentUserId = userId;
    });
  }

  Future<void> _fetchSessionsData() async {
    final apiService = ApiTrainingService();
    final selectedDate = DateTime.now().toIso8601String().substring(0, 10);
    final result = await apiService.getSessionsSummary(currentUserId!, selectedDate);
    exercisesWeights = result["exercises"];
    sessionsSummary["sessions_dates"] = result["sessions_dates"];
  }

  Future<Widget> _buildCalendarDialog(BuildContext context) async {
    Set<DateTime> markedDates = {};

    markedDates = (sessionsSummary["sessions_dates"] as List<dynamic>)
        .map((date) {
          DateTime parsedDate = DateTime.parse(date as String);
          return DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
        })
        .toSet();
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);
    markedDates.remove(today);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Calendari",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TableCalendar(
              startingDayOfWeek: StartingDayOfWeek.monday,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: DateTime.now(),
              eventLoader: (date) {
                DateTime normalizedDate = DateTime(date.year, date.month, date.day);
                return markedDates.contains(normalizedDate) ? ['Event'] : [];
              },
              calendarStyle: CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  shape: BoxShape.circle,
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                DateTime today = DateTime.now();
                DateTime normalizedToday = DateTime(today.year, today.month, today.day);
                DateTime normalizedSelectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

                if (normalizedSelectedDay == normalizedToday) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoricSessionPage(date: DateFormat('yyyy-MM-dd').format(selectedDay)),
                    ),
                  );
                }
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextFormatter: (date, locale) => 
                    DateFormat('MMMM yyyy').format(date),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Close"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (!isLoading) ...[
                        RelativeSizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RoundButton(
                              icon: FontAwesomeIcons.magnifyingGlass,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const TrainingSearchPage(isCreating: false)),
                                );
                              },
                              size: 70,
                            ),
                            RelativeSizedBox(width: 3),
                            RoundButton(
                              icon: FontAwesomeIcons.plus,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const TrainingCreatePage()),
                                );
                              },
                              size: 70,
                            ),
                            RelativeSizedBox(width: 3),
                            RoundButton(
                              icon: FontAwesomeIcons.calendar,
                              onPressed: () async {
                                final dialogWidget = await _buildCalendarDialog(context);
                                if (context.mounted) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) => dialogWidget,
                                  );
                                }
                              },
                              size: 70,
                            ),
                            RelativeSizedBox(width: 3),
                            RoundButton(
                              icon: FontAwesomeIcons.book,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const RoutinePage()),
                                );
                              },
                              size: 70,
                            ),
                          ],
                        ),
                        RelativeSizedBox(height: 4),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 3 / 4,
                          ),
                          itemCount: exercisesWeights.length,
                          itemBuilder: (context, index) {
                            final exercise = exercisesWeights[index];
                            final color = graphColors[index % graphColors.length];
                            final points = (exercise["weights"] as List).cast<double>();
                            if (points.length > 2){
                              return SingleGraphWidget(
                                title: exercise["name"], 
                                dataPoints: (exercise["weights"] as List).cast<double>(), 
                                lineColor: color, 
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ExercisePage(exerciseId: exercise["id"]),
                                    ),
                                  );
                                },
                              );
                            }
                            else {
                              return Text(
                                "No hi ha dades suficients",
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              );
                            }
                          },
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Sessions",
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              height: 230,
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                              child: sessionsSummary["sessions_dates"].isNotEmpty
                                  ? ListView.builder(
                                      itemCount: sessionsSummary["sessions_dates"].length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                                          child: SessionCard(date: sessionsSummary["sessions_dates"][index]),
                                        );
                                      },
                                    )
                                  : const Center(
                                      child: Text(
                                        "No hi ha sessions",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                        RelativeSizedBox(height: 17),
                      ] else ...[
                        Column(
                          children: [
                            RelativeSizedBox(height: 37),
                            Align(
                              alignment: Alignment.center,
                              child: RotatingImage(),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: RoundButton(
                size: 100,
                icon: FontAwesomeIcons.dumbbell,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SessionPage()),
                  ).then((_) {
                    _initializePage();
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}