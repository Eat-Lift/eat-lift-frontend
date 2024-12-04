import 'package:eatnlift/pages/nutrition/historic_meal.dart';
import 'package:eatnlift/pages/training/training_create.dart';
import 'package:eatnlift/pages/training/training_search.dart';
import 'package:eatnlift/services/api_nutrition_service.dart';
import 'package:eatnlift/services/api_user_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../custom_widgets/round_button.dart';
import '../../custom_widgets/relative_sizedbox.dart';
import '../../custom_widgets/rotating_logo.dart';

import '../../services/session_storage.dart';

import 'package:eatnlift/pages/nutrition/nutritional_plan.dart';
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
  Map<String, dynamic>? userData;

  bool isLoading = true;

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
    await _loadUserData();
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

  Future<void> _loadUserData() async {
    final apiService = ApiUserService();
    final result = await apiService.getPersonalInformation(currentUserId!);
    if (result?["success"]){
      userData = result?["user"];
    }
  }

  Future<Widget> _buildCalendarDialog(BuildContext context) async {
    final apiService = ApiNutritionService();
    final result = await apiService.getMealDates(currentUserId!);

    Set<DateTime> markedDates = {};

    if (result["success"]) {
      markedDates = (result["dates"] as List<dynamic>)
          .map((date) {
            DateTime parsedDate = DateTime.parse(date as String);
            return DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
          })
          .toSet();
      DateTime today = DateTime.now();
      today = DateTime(today.year, today.month, today.day);
      markedDates.remove(today);
    }

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
                      builder: (context) => HistoricMealPage(date: selectedDay),
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!isLoading && userData != null) ...[
                    RelativeSizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RoundButton(
                          icon: FontAwesomeIcons.magnifyingGlass,
                          onPressed:() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const TrainingSearchPage(isCreating: false)),
                            );
                          },
                          size: 70
                        ),
                        RelativeSizedBox(width: 3),
                        RoundButton(
                          icon: FontAwesomeIcons.plus,
                          onPressed:() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const TrainingCreatePage()),
                            );
                          },
                          size: 70
                        ),
                        RelativeSizedBox(width: 3),
                        RoundButton(
                          icon: FontAwesomeIcons.calendar,
                          onPressed:() async {
                            final dialogWidget = await _buildCalendarDialog(context);
                            if (context.mounted) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => dialogWidget,
                              );
                            }
                          },
                          size: 70
                        ),
                        RelativeSizedBox(width: 3),
                        RoundButton(
                          icon: FontAwesomeIcons.book,
                          onPressed:() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const NutritionalPlanPage()),
                            );
                          },
                          size: 70
                        ),
                      ]
                    ),
                    RelativeSizedBox(height: 3),
                  ] else ...[
                    Column(
                      children: [
                        RelativeSizedBox(height: 37),
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              RotatingImage(),
                            ],
                          ),
                        ),
                      ]
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}