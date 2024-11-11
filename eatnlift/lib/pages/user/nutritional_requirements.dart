import 'package:eatnlift/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../custom_widgets/relative_sizedbox.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/messages_box.dart';
import '../../custom_widgets/custom_number_picker.dart';

import '../../services/api_user_service.dart';

import 'user.dart';

class NutritionalRequirementsPage extends StatefulWidget {
  final Map<String, dynamic> personalInfo;

  const NutritionalRequirementsPage({
    required this.personalInfo,
    super.key,
  });

  @override
  NutritionalRequirementsState createState() => NutritionalRequirementsState();
}

class NutritionalRequirementsState extends State<NutritionalRequirementsPage> {
  Map<String, dynamic> response = {};
  late int calories;
  late int proteins;
  late int fats;
  late int carbohydrates;

  final GlobalKey<CustomNumberPickerState<int>> caloriesPickerKey = GlobalKey();
  final GlobalKey<CustomNumberPickerState<int>> protiensPickerKey = GlobalKey();
  final GlobalKey<CustomNumberPickerState<int>> fatsPickerKey = GlobalKey();
  final GlobalKey<CustomNumberPickerState<int>> carbohydratesPickerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _calculateCalories();
    _calculateMacronutrients();
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;

    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  DateTime _parseDate(String dateString) {
    final parts = dateString.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    return DateTime(year, month, day);
  }

  void _calculateCalories() {
    String birthDateString = widget.personalInfo['birth_date'];
    DateTime birthDate = _parseDate(birthDateString);
    int age = _calculateAge(birthDate);
    int height = widget.personalInfo['height'] ?? 0;
    double weight = widget.personalInfo['weight'] ?? 0.0;
    String gender = widget.personalInfo['genre'] ?? 'male';
    String activityLevel = widget.personalInfo['activity'] ?? 'Sedentarisme';
    String goal = widget.personalInfo['goal'] ?? 'Mantenir el pes';

    double bmr;
    if (gender == 'Masculí') {
      bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }

    double activityMultiplier;
    switch (activityLevel) {
      case 'Activitat lleugera':
        activityMultiplier = 1.375;
        break;
      case 'Activitat moderada':
        activityMultiplier = 1.55;
        break;
      case 'Activitat intensa':
        activityMultiplier = 1.725;
        break;
      case 'Activitat molt intensa':
        activityMultiplier = 1.9;
        break;
      default:
        activityMultiplier = 1.2;
    }

    calories = (bmr * activityMultiplier).round();

    switch (goal) {
      case 'Guanyar múscul':
        calories += 200;
        break;
      case 'Perdre greix':
        calories -= 500;
    }

    caloriesPickerKey.currentState?.setSelected(calories);
  }

  void _calculateMacronutrients() {
      proteins = (2 * widget.personalInfo['weight']).round();
      fats = (0.8 * widget.personalInfo['weight']).round();
      carbohydrates = ((calories - (proteins * 4 + fats * 9)) / 4).round();
      protiensPickerKey.currentState?.setSelected(proteins);
      fatsPickerKey.currentState?.setSelected(fats);
      carbohydratesPickerKey.currentState?.setSelected(carbohydrates);
  }

  void _recalculateCalories() {
      calories = proteins * 4 + fats * 9 + carbohydrates * 4;
      caloriesPickerKey.currentState?.setSelected(calories);
  }

  void updatePersonalInformation(BuildContext context) async {
    widget.personalInfo.addAll({
      "calories": calories,
      "proteins": proteins,
      "fats": fats,
      "carbohydrates": carbohydrates,
    });

    final apiService = ApiUserService();
    final result = await apiService.updatePersonalInformation(widget.personalInfo);

    if (result["success"]){
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(initialIndex: 1),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const RelativeSizedBox(height: 1),
              const Icon(
                Icons.lock,
                size: 100,
              ),

              const RelativeSizedBox(height: 0.5),

              Text(
                "Requeriments nutricionals",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                ),
              ),

              const RelativeSizedBox(height: 5),

              Row(
                children: [
                  Expanded(
                    child: CustomNumberPicker(
                      key: caloriesPickerKey,
                      icon: Icons.local_fire_department,
                      minValue: 1500,
                      maxValue: 6000,
                      step: 50,
                      unit: 'kcal',
                      title: "$calories kcal",
                      defaultValue: calories,
                      onItemSelected: (value) {
                        setState(() {
                          calories = value;
                          _calculateMacronutrients();
                        });
                      },
                    ),
                  ),
                ],
              ),

              const RelativeSizedBox(height: 0.5),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: CustomNumberPicker(
                      key: protiensPickerKey,
                      icon: FontAwesomeIcons.drumstickBite,
                      minValue: 0,
                      maxValue: 300,
                      defaultValue: proteins,
                      unit: 'g',
                      title: "$proteins g",
                      onItemSelected: (value) {
                        setState(() {
                          proteins = value;
                          _recalculateCalories();
                        });
                      },
                    ),
                  ),

                  RelativeSizedBox(width: 1),
                  
                  Expanded(
                    child: CustomNumberPicker(
                      key: fatsPickerKey,
                      icon: Icons.water_drop,
                      minValue: 0,
                      maxValue: 150,
                      defaultValue: fats,
                      unit: 'g',
                      title: "$fats g",
                      onItemSelected: (value) {
                        setState(() {
                          fats = value;
                          _recalculateCalories();
                        });
                      },
                    ),
                  ),

                  RelativeSizedBox(width: 1),

                  Expanded(
                    child: CustomNumberPicker(
                      key: carbohydratesPickerKey,
                      icon: FontAwesomeIcons.wheatAwn,
                      minValue: 0,
                      maxValue: 1000,
                      defaultValue: carbohydrates,
                      unit: 'g',
                      title: "$carbohydrates g",
                      onItemSelected: (value) {
                        setState(() {
                          carbohydrates = value;
                          _recalculateCalories();
                        });
                      },
                    ),
                  ),
                ]
              ),
              
              const RelativeSizedBox(height: 2),

              CustomButton(
                text: "Enviar",
                onTap: () => updatePersonalInformation(context),
              ),

              const RelativeSizedBox(height: 2),

              if (response.isNotEmpty && !response["success"]) ...[
                MessagesBox(
                  messages: response["errors"],
                  height: 12,
                  color: Colors.red,
                ),
                RelativeSizedBox(height: 4)
              ]
              else ...[
                RelativeSizedBox(height: 15)
              ]
            ],
          ),
        ),
      ),
    );
  }
}