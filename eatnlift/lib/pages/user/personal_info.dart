import 'package:eatnlift/custom_widgets/rotating_logo.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/relative_sizedbox.dart';
import '../../custom_widgets/messages_box.dart';
import '../../custom_widgets/custom_dropdown.dart';
import '../../custom_widgets/custom_textfield.dart';

import 'nutritional_requirements.dart';

import '../../services/session_storage.dart';
import '../../services/api_user_service.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  PersonalInfoPageState createState() => PersonalInfoPageState();
}

class PersonalInfoPageState extends State<PersonalInfoPage> {
  int? selectedHeight;
  final selectedHeightController = TextEditingController();

  double? selectedWeight;
  final selectedWeightController = TextEditingController();

  String? selectedGenre;
  final List<String> genres = ["Masculí", "Femení"];

  DateTime? selectedDate;
  final birthDateController = TextEditingController();

  String? selectedActivity;
  final List<String> activity = ["Sedentarisme", "Activitat lleugera", "Activitat moderada", "Activitat intensa", "Activitat molt intensa"];

  String? selectedGoal;
  final List<String> goal = ["Guanyar múscul", "Mantenir el pes", "Perdre greix"];

  Map<String, dynamic> response = {};

  bool isLoading = true;
  final SessionStorage sessionStorage = SessionStorage();
  Map<String, dynamic>? userData;
  bool isInitialized = false;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialized) {
      _loadUserPersonalInfo();
      isInitialized = true;
    }
  }

  Future<void> _loadUserPersonalInfo() async {
    setState(() => isLoading = true);
    final userId = await sessionStorage.getUserId();
    if (userId == null) {
      setState(() => isLoading = false);
      return;
    }

    final apiService = ApiUserService();
    final result = await apiService.getPersonalInformation(userId);
    if (result?["success"]) {
      setState(() {
        selectedWeightController.text = (result?["user"]["weight"] as double).toString();
        selectedHeightController.text = (result?["user"]["height"] as int).toString();
        selectedActivity = result?["user"]["activity"];
        final dateString = result?["user"]["birth_date"] as String?;
        if (dateString != null) {
          selectedDate = DateTime.parse(dateString);
          birthDateController.text = DateFormat('dd/MM/yyyy').format(selectedDate!);
        }
        selectedGenre = result?["user"]["genre"];
        selectedGoal = result?["user"]["goal"];
        isLoading = false;
      });
    }
    else {
      setState(() {isLoading = false;});
      return;
    }
  }

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

    selectedHeight = int.tryParse(selectedHeightController.text) ?? 0;
    selectedWeight = double.tryParse(selectedWeightController.text) ?? 0;

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
    if (selectedActivity == null) {
      response["success"] = false;
      if (response.containsKey('errors')) {
        response['errors'].add("Selecciona la teva activitat");
      } else {
        response['errors'] = ["Selecciona la teva activitat"];
      }
      emptyField = true;
    }
    if (selectedGoal == null) {
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
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text("Informació personal"),
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isLoading) ...[
                const Icon(
                  Icons.supervised_user_circle_sharp,
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

                Row(
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
                      child: CustomTextfield(
                        controller: selectedHeightController,
                        hintText: "Alçada",
                        obscureText: false,
                        maxLength: 3,
                        isNumeric: true,
                        unit: 'cm',
                        centerText: true,
                        height: 16,
                      ),
                    ),

                    RelativeSizedBox(width: 1),

                    Expanded(
                      child: CustomTextfield(
                        controller: selectedWeightController,
                        hintText: "Pes",
                        obscureText: false,
                        maxLength: 6,
                        isNumeric: true,
                        unit: 'kg',
                        centerText: true,
                        allowDecimal: true,
                        height: 16,
                      ),
                    ),
                  ]
                ),


                const RelativeSizedBox(height: 0.5),

                TextField(
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
                  ),
                  readOnly: true,
                  onTap: () => pickDate(context),
                ),
                

                RelativeSizedBox(height: 0.5),

                CustomDropdown(
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
                

                const RelativeSizedBox(height:0.5),

                CustomDropdown(
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
              ] else ...[
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      RelativeSizedBox(height: 10),
                      RotatingImage(),   
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