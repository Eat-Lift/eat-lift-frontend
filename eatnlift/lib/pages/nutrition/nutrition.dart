import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../custom_widgets/round_button.dart';
import '../../custom_widgets/relative_sizedbox.dart';

import '../../services/api_nutrition_service.dart';
import '../../services/session_storage.dart';

import 'package:eatnlift/pages/nutrition/nutrition_create.dart';
import 'package:eatnlift/pages/nutrition/nutrition_search.dart';

class NutritionPage extends StatefulWidget {
  const NutritionPage({super.key});

  @override
  State<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  final SessionStorage sessionStorage = SessionStorage();
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      userData = {"name": "hola"};
      isLoading = false;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isLoading && userData != null) ...[
                RelativeSizedBox(height: 5),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RoundButton(
                      icon: FontAwesomeIcons.magnifyingGlass,
                      onPressed:() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NutritionSearchPage()),
                        );
                      },
                      size: 70
                    ),
                    RelativeSizedBox(width: 5),
                    RoundButton(
                      icon: FontAwesomeIcons.plus,
                      onPressed:() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NutritionCreatePage()),
                        );
                      },
                      size: 70
                    ),
                    RelativeSizedBox(width: 5),
                    RoundButton(
                      icon: FontAwesomeIcons.calendar,
                      onPressed:() {
                      },
                      size: 70
                    ),
                    RelativeSizedBox(width: 5),
                    RoundButton(
                      icon: FontAwesomeIcons.book,
                      onPressed: () => {},
                      size: 70
                    ),
                  ]
                  
                ),
              ] else ...[
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      RelativeSizedBox(height: 10),
                      CircularProgressIndicator(color: Colors.grey),   
                    ],
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}