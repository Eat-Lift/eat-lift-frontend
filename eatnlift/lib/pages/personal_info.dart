import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../custom_widgets/custom_button.dart';
import '../custom_widgets/relative_sizedbox.dart';
import '../custom_widgets/messages_box.dart';
import '../custom_widgets/custom_dropdown.dart';
import '../custom_widgets/custom_number_picker.dart';

import '../pages/nutritional_requirements.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  PersonalInfoPageState createState() => PersonalInfoPageState();
}

class PersonalInfoPageState extends State<PersonalInfoPage> {
  int? selectedHeight;

  double? selectedWeight;

  String? selectedGenre;
  final List<String> genres = ["Masculí", "Femení"];

  DateTime? selectedDate;
  final birthDateController = TextEditingController();

  String? selectedActivity;
  final List<String> activity = ["Sedentarisme", "Activitat lleugera", "Activitat moderada", "Activitat intensa", "Activitat molt intensa"];

  String? selectedGoal;
  final List<String> goal = ["Guanyar múscul", "Mantenir el pes", "Perdre greix"];

  Map<String, dynamic> response = {};

  Future<void> pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2002),
      firstDate: DateTime(1900),
      lastDate: DateTime(2023),
      builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.grey,
            onPrimary: Colors.white,
            onSurface: Colors.grey[800]!,
          ),
          dialogBackgroundColor: Colors.grey[200],
        ),
        child: child!,
      );
      },
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        birthDateController.text = "${pickedDate.toLocal().day}/${pickedDate.toLocal().month}/${pickedDate.toLocal().year}";
      });
    }
  }

  void updatePersonalInformation(BuildContext context) async {
    bool emptyField = false;
    
    response = {};

    if (selectedGenre == null) {
      response["success"] = false;
      if (response.containsKey('errors')) {
        response['errors'].add("Selecciona el teu gènere");
      } else {
        response['errors'] = ["Selecciona el teu gènere"];
      }
      emptyField = true;
    }
    if (selectedWeight == null) {
      response["success"] = false;
      if (response.containsKey('errors')) {
        response['errors'].add("Selecciona el teu pes");
      } else {
        response['errors'] = ["Selecciona el teu pes"];
      }
      emptyField = true;
    }
    if (selectedHeight == null) {
      response["success"] = false;
      if (response.containsKey('errors')) {
        response['errors'].add("Selecciona la teva alçada");
      } else {
        response['errors'] = ["Selecciona la teva alçada"];
      }
      emptyField = true;
    }
    if (selectedDate == null) {
      response["success"] = false;
      if (response.containsKey('errors')) {
        response['errors'].add("Selecciona la teva data de naixement");
      } else {
        response['errors'] = ["Selecciona la teva data de naixement"];
      }
      emptyField = true;
    }
    if (selectedDate == null) {
      response["success"] = false;
      if (response.containsKey('errors')) {
        response['errors'].add("Selecciona la teva activitat");
      } else {
        response['errors'] = ["Selecciona la teva activitat"];
      }
      emptyField = true;
    }
    if (selectedDate == null) {
      response["success"] = false;
      if (response.containsKey('errors')) {
        response['errors'].add("Selecciona la el teu objectiu");
      } else {
        response['errors'] = ["Selecciona la el teu objectiu"];
      }
      emptyField = true;
    }

    if (emptyField) {
      setState(() {});
      return;
    }

    Map<String, dynamic> personalInformationMap = {
      "height": selectedHeight,
      "weight": selectedWeight,
      "genre": selectedGenre,
      "birth_date": DateFormat('yyyy-MM-dd').format(selectedDate!).toString(),
      "activity": selectedActivity,
      "goal": selectedGoal,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NutritionalRequirementsPage(personalInfo: personalInformationMap),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
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
                "Informació personal",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                ),
              ),

              const RelativeSizedBox(height: 5),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Expanded(
                      child: CustomDropdown(
                        title: "Gènere",
                        items: genres,
                        height: 160,
                        selectedItem: selectedGenre,
                        onItemSelected: (value) {
                          setState(() {
                            selectedGenre = value;
                          });
                        },
                        itemLabel: (genre) => genre,
                      ),
                    ),

                    RelativeSizedBox(width: 1),
                    
                    Expanded(
                      child: CustomNumberPicker(
                        minValue: 120,
                        maxValue: 220,
                        defaultValue: 176,
                        unit: "cm",
                        title: "Alçada",
                        onItemSelected: (value) {
                          setState(() {
                            selectedHeight = value as int?;
                          });
                        },
                      ),
                    ),

                    RelativeSizedBox(width: 1),

                    Expanded(
                      child: CustomNumberPicker(
                        minValue: 40,
                        maxValue: 160,
                        defaultValue: 76,
                        unit: "kg",
                        step: 0.1,
                        title: "Pes",
                        onItemSelected: (value) {
                          setState(() {
                            selectedWeight = value as double?;
                          });
                        },
                      ),
                    ),
                  ]
                ),
              ),

              const RelativeSizedBox(height: 0.5),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Expanded(
                  child: TextField(
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    controller: birthDateController,
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.calendar_today),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 3,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 3,
                        ),
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      hintText: "Data de naixement",
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 45),
                    ),
                    readOnly: true,
                    onTap: () => pickDate(context),
                  ),
                ),
              ),

              RelativeSizedBox(height: 0.5),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child:  CustomDropdown(
                  title: "Activitat",
                  height: 375,
                  items: activity,  
                  selectedItem: selectedActivity,
                  onItemSelected: (value) {
                    setState(() {
                      selectedActivity = value;
                    });
                  },
                  itemLabel: (activity) => activity,
                ),
              ),
              

              const RelativeSizedBox(height:0.5),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child:  CustomDropdown(
                  title: "Objectiu",
                  items: goal,
                  height: 230,  
                  selectedItem: selectedGoal,
                  onItemSelected: (value) {
                    setState(() {
                      selectedGoal = value;
                    });
                  },
                  itemLabel: (goal) => goal,
                ),
              ),

              const RelativeSizedBox(height:2),

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