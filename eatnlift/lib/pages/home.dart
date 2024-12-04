import 'package:flutter/material.dart';
import 'package:eatnlift/pages/user/user.dart';
import 'package:eatnlift/pages/nutrition/nutrition.dart';
import 'package:eatnlift/pages/training/training.dart';

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
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const TrainingPage(),
    const NutritionPage(),
    const UserPage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
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
}