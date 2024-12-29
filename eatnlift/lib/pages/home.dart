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
    this.initialIndex = 1,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SessionStorage sessionStorage = SessionStorage();
  String? currentUserId;
  int _currentIndex = 1;
  bool internet = true; 
  bool isLoading = true;

  final List<Widget> _pages = [
    const NutritionPage(),
    const UserPage(),
    const TrainingPage(),
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
    
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
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
          body: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: SizedBox(
            height: 54,
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              showSelectedLabels: false,
              showUnselectedLabels: false,
              backgroundColor: Colors.black,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.white,
              items: [
                BottomNavigationBarItem(
                  icon: SizedBox(
                    height: 30,
                    width: 30,
                    child: _currentIndex == 0
                        ? Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.restaurant,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          )
                        : Icon(Icons.restaurant, size: 20),
                  ),
                  label: 'Nutrició',
                ),
                BottomNavigationBarItem(
                  icon: SizedBox(
                    height: 30,
                    width: 30,
                    child: _currentIndex == 1
                        ? Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.person,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          )
                        : Icon(Icons.person, size: 20),
                  ),
                  label: 'Usuari',
                ),
                BottomNavigationBarItem(
                  icon: SizedBox(
                    height: 30,
                    width: 30,
                    child: _currentIndex == 2
                        ? Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.fitness_center,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          )
                        : Icon(Icons.fitness_center, size: 20),
                  ),
                  label: 'Entrenament',
                ),
              ],
            ),


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
                      RelativeSizedBox(height: 17),
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