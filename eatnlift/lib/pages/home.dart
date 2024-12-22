import 'package:eatnlift/custom_widgets/relative_sizedbox.dart';
import 'package:eatnlift/custom_widgets/rotating_logo.dart';
import 'package:eatnlift/custom_widgets/round_button.dart';
import 'package:eatnlift/pages/nutrition/offline_meal.dart';
import 'package:eatnlift/pages/training/offline_session.dart';
import 'package:eatnlift/services/internet_checker.dart';
import 'package:eatnlift/services/session_storage.dart';
import 'package:flutter/material.dart';
import 'package:eatnlift/pages/user/user.dart';
import 'package:eatnlift/pages/nutrition/nutrition.dart';
import 'package:eatnlift/pages/training/training.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;

  const HomePage({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SessionStorage sessionStorage = SessionStorage();
  String? currentUserId;
  int _currentIndex = 0;
  bool internet = true; 
  bool isLoading = true;

  final List<Widget> _pages = [
    const TrainingPage(),
    const NutritionPage(),
    const UserPage(),
  ];

  @override
  void initState() {
    super.initState();
    _initializePage();
    _currentIndex = widget.initialIndex;
  }

  Future<void> _initializePage() async {
    setState(() {
      isLoading = true;
    });
    await _checkInternet();
    await _fetchCurrentUserId();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchCurrentUserId() async {
    final userId = await sessionStorage.getUserId();
    currentUserId = userId;
  }

  Future<void> _checkInternet() async {
    internet = await InternetChecker.getConnectivity();
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      if (internet) {
        return Scaffold(
          body: _pages[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.restaurant),
                label: 'Nutrició',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Usuari',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center),
                label: 'Entrenament',
              ),
            ],
          ),
        );
      }
      else {
        return Scaffold(
          backgroundColor: Colors.grey[300],
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: Column(
                    children: [
                      RelativeSizedBox(height: 20),
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 200,
                        color: Colors.black,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "No hi ha connexió a internet",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      RelativeSizedBox(height: 10),
                      if (currentUserId != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            RoundButton(
                              size: 100,
                              icon: FontAwesomeIcons.dumbbell,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const OfflineSessionPage(),
                                  ),
                                );
                              },
                            ),
                            RoundButton(
                              size: 100,
                              icon: Icons.restaurant,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const OfflineMealPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ]
                      else ...[
                        SizedBox(height: 100), 
                      ]
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
    else {
      return Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
          child: Column(
            children: [
              RelativeSizedBox(height: 37),
              Align(
                alignment: Alignment.center,
                child: RotatingImage(),
              ),
            ],
          ),
        ),
      );
    }
  }
}