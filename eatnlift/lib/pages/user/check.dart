import 'package:eatnlift/custom_widgets/rotating_logo.dart';
import 'package:eatnlift/custom_widgets/wrapped_image.dart';
import 'package:eatnlift/pages/user/check_info.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/relative_sizedbox.dart';
import '../../custom_widgets/messages_box.dart';
import '../../custom_widgets/custom_textfield.dart';


import '../../services/session_storage.dart';
import '../../services/api_user_service.dart';
import 'dart:math';

class CheckPage extends StatefulWidget {
  const CheckPage({super.key});

  @override
  CheckPageState createState() => CheckPageState();
}

class CheckPageState extends State<CheckPage> {
  // Weight
  double? selectedWeight;
  final selectedWeightController = TextEditingController();

  // Bodyfat
  double? selectedBodyfat;
  final selectedBodyfatController = TextEditingController();

  // Neck
  double? selectedNeck;
  final selectedNeckController = TextEditingController();

  // Shoulders
  double? selectedShoulders;
  final selectedShouldersController = TextEditingController();

  // Arm
  double? selectedArm;
  final selectedArmController = TextEditingController();

  // Chest
  double? selectedChest;
  final selectedChestController = TextEditingController();

  // Waist
  double? selectedWaist;
  final selectedWaistController = TextEditingController();

  // Hip
  double? selectedHip;
  final selectedHipController = TextEditingController();

  // Thigh
  double? selectedThigh;
  final selectedThighController = TextEditingController();

  // Calves
  double? selectedCalf;
  final selectedCalfController = TextEditingController();

  Map<String, dynamic> response = {};

  bool isLoading = true;
  final SessionStorage sessionStorage = SessionStorage();
  Map<String, dynamic>? userData;
  bool isInitialized = false;
  String? currentUser;
  int? height;
  String? genre;

  Map<String, dynamic>? lastCheck;


  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });

    final userId = await sessionStorage.getUserId();
    if (userId == null) {
      return;
    }
    else {
      currentUser = userId;
    }

    final apiService = ApiUserService();
    final result = await apiService.getPersonalInformation(userId);
    if (result?["success"]) {
      setState(() {
        height = result?["user"]["height"];
        genre = result?["user"]["genre"];
      });
    }
    
    final resultLastCheck = await apiService.getLastCheck();
    if (resultLastCheck["success"]) {
      setState(() {
        lastCheck = resultLastCheck["check"];
        // Weight
        if (lastCheck?["weight"] != null) {
          selectedWeight = lastCheck?["weight"];
          selectedWeightController.text = lastCheck!["weight"].toString();
        }

        // Bodyfat
        if (lastCheck?["bodyfat"] != null) {
          selectedBodyfat = lastCheck?["bodyfat"];
          selectedBodyfatController.text = lastCheck!["bodyfat"].toString();
        }

        // Neck
        if (lastCheck?["neck"] != null) {
          selectedNeck = lastCheck?["neck"];
          selectedNeckController.text = lastCheck!["neck"].toString();
        }

        // Shoulders
        if (lastCheck?["shoulders"] != null) {
          selectedShoulders = lastCheck?["shoulders"];
          selectedShouldersController.text = lastCheck!["shoulders"].toString();
        }

        // Arm
        if (lastCheck?["arm"] != null) {
          selectedArm = lastCheck?["arm"];
          selectedArmController.text = lastCheck!["arm"].toString();
        }

        // Chest
        if (lastCheck?["chest"] != null) {
          selectedChest = lastCheck?["chest"];
          selectedChestController.text = lastCheck!["chest"].toString();
        }

        // Waist
        if (lastCheck?["waist"] != null) {
          selectedWaist = lastCheck?["waist"];
          selectedWaistController.text = lastCheck!["waist"].toString();
        }

        // Hip
        if (lastCheck?["hip"] != null) {
          selectedHip = lastCheck?["hip"];
          selectedHipController.text = lastCheck!["hip"].toString();
        }

        // Thigh
        if (lastCheck?["thigh"] != null) {
          selectedThigh = lastCheck?["thigh"];
          selectedThighController.text = lastCheck!["thigh"].toString();
        }

        // Calves
        if (lastCheck?["calf"] != null) {
          selectedCalf = lastCheck?["calf"];
          selectedCalfController.text = lastCheck!["calf"].toString();
        }

        isLoading = false;
      });
    }

  }

  void calcularPercentatgeDeGreix(String mock) {
    if (selectedWaistController.text.isEmpty || selectedNeckController.text.isEmpty || height == null || genre == null) {
      return;
    }
    if (genre == "Femení" && selectedHipController.text.isEmpty){
      return;
    }

    double waist = double.tryParse(selectedWaistController.text) ?? 0.0;
    double neck = double.tryParse(selectedNeckController.text) ?? 0.0;
    double hip = genre == "Femení" ? double.tryParse(selectedHipController.text) ?? 0.0 : 0.0;
    double heightInCm = height!.toDouble();

    double bodyFatPercentage;

    if (genre == "Masculí") {
      bodyFatPercentage = 86.010 * (log(waist - neck) / ln10) -
          70.041 * (log(heightInCm) / ln10) +
          36.76;
    } else if (genre == "Femení") {
      if (hip == 0.0) {
        return;
      }
      bodyFatPercentage = 163.205 * (log(waist + hip - neck) / ln10) -
          97.684 * (log(heightInCm) / ln10) -
          78.387;
    } else {
      return;
    }
    
    if (!bodyFatPercentage.isNaN) {
      setState(() {
        selectedBodyfat = bodyFatPercentage;
        selectedBodyfatController.text = bodyFatPercentage.toStringAsFixed(2);
      });
    }
  }

  void submitCheck(BuildContext context) async {
    bool emptyField = false;

    response = {};

    if (selectedWeightController.text.isEmpty) {
      response["success"] = false;
      if (response.containsKey('errors')) {
        response['errors'].add("Selecciona el teu pes");
      } else {
        response['errors'] = ["Selecciona el teu pes"];
      }
      emptyField = true;
    }

    if (emptyField) {
      setState(() {});
      return;
    }

    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    Map<String, dynamic> selectedData = {
      "date": todayDate,
    };

    if (selectedWeightController.text.isNotEmpty) {
      selectedData['weight'] = double.tryParse(selectedWeightController.text);
    }
    if (selectedBodyfatController.text.isNotEmpty) {
      selectedData['bodyfat'] = double.tryParse(selectedBodyfatController.text);
    }
    if (selectedNeckController.text.isNotEmpty) {
      selectedData['neck'] = double.tryParse(selectedNeckController.text);
    }
    if (selectedShouldersController.text.isNotEmpty) {
      selectedData['shoulders'] = double.tryParse(selectedShouldersController.text);
    }
    if (selectedArmController.text.isNotEmpty) {
      selectedData['arm'] = double.tryParse(selectedArmController.text);
    }
    if (selectedChestController.text.isNotEmpty) {
      selectedData['chest'] = double.tryParse(selectedChestController.text);
    }
    if (selectedWaistController.text.isNotEmpty) {
      selectedData['waist'] = double.tryParse(selectedWaistController.text);
    }
    if (selectedHipController.text.isNotEmpty) {
      selectedData['hip'] = double.tryParse(selectedHipController.text);
    }
    if (selectedThighController.text.isNotEmpty) {
      selectedData['thigh'] = double.tryParse(selectedThighController.text);
    }
    if (selectedCalfController.text.isNotEmpty) {
      selectedData['calf'] = double.tryParse(selectedCalfController.text);
    }

    final apiService = ApiUserService();
    final result = await apiService.submitCheck(selectedData);

    if (result["success"] == true) {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CheckInfoPage(date: todayDate),
          ),
        );
      }
    } else {
      setState(() {
        response = {
          "success": false,
          "errors": result["errors"] ?? ["Error en enviar la revisió"],
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text("Revisió"),   
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isLoading) ...[
                const Icon(
                  Icons.monitor_weight_rounded,
                  size: 100,
                ),
                
                Text(
                  "Revisió",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                  ),
                ),

                const RelativeSizedBox(height: 2),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [  
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
                RelativeSizedBox(height: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [  
                    Expanded(
                      child: CustomTextfield(
                        controller: selectedNeckController,
                        hintText: "Coll",
                        obscureText: false,
                        maxLength: 6,
                        isNumeric: true,
                        unit: 'cm',
                        centerText: true,
                        allowDecimal: true,
                        height: 16,
                        onSubmitted: calcularPercentatgeDeGreix,
                      ),
                    ),
                    RelativeSizedBox(width: 1),
                    WrappedImage(imageUrl: 'lib/assets/images/Neck.png', size: 50, padding: 0),
                    RelativeSizedBox(width: 1),
                    Expanded(
                      child: CustomTextfield(
                        controller: selectedWaistController,
                        hintText: "Cintura",
                        obscureText: false,
                        maxLength: 6,
                        isNumeric: true,
                        unit: 'cm',
                        centerText: true,
                        allowDecimal: true,
                        height: 16,
                        onSubmitted: calcularPercentatgeDeGreix,
                      ),
                    ),
                    RelativeSizedBox(width: 1),
                    WrappedImage(imageUrl: 'lib/assets/images/Waist.png', size: 50, padding: 0),
                  ]
                ),
                RelativeSizedBox(height: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [  
                    Expanded(
                      child: CustomTextfield(
                        controller: selectedShouldersController,
                        hintText: "Espatlles",
                        obscureText: false,
                        maxLength: 6,
                        isNumeric: true,
                        unit: 'cm',
                        centerText: true,
                        allowDecimal: true,
                        height: 16,
                      ),
                    ),
                    RelativeSizedBox(width: 1),
                    WrappedImage(imageUrl: 'lib/assets/images/Shoulders.png', size: 50, padding: 0),
                    RelativeSizedBox(width: 1),
                    Expanded(
                      child: CustomTextfield(
                        controller: selectedHipController,
                        hintText: "Maluc",
                        obscureText: false,
                        maxLength: 6,
                        isNumeric: true,
                        unit: 'cm',
                        centerText: true,
                        allowDecimal: true,
                        height: 16,
                        onSubmitted: calcularPercentatgeDeGreix,
                      ),
                    ),
                    RelativeSizedBox(width: 1),
                    WrappedImage(imageUrl: 'lib/assets/images/Hip.png', size: 50, padding: 0),
                  ]
                ),
                RelativeSizedBox(height: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [  
                    Expanded(
                      child: CustomTextfield(
                        controller: selectedArmController,
                        hintText: "Braç",
                        obscureText: false,
                        maxLength: 6,
                        isNumeric: true,
                        unit: 'cm',
                        centerText: true,
                        allowDecimal: true,
                        height: 16,
                      ),
                    ),
                    RelativeSizedBox(width: 1),
                    WrappedImage(imageUrl: 'lib/assets/images/Arm.png', size: 50, padding: 0),
                    RelativeSizedBox(width: 1),
                    Expanded(
                      child: CustomTextfield(
                        controller: selectedThighController,
                        hintText: "Cuixa",
                        obscureText: false,
                        maxLength: 6,
                        isNumeric: true,
                        unit: 'cm',
                        centerText: true,
                        allowDecimal: true,
                        height: 16,
                      ),
                    ),
                    RelativeSizedBox(width: 1),
                    WrappedImage(imageUrl: 'lib/assets/images/Thigh.png', size: 50, padding: 0),
                  ]
                ),
                RelativeSizedBox(height: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [  
                    Expanded(
                      child: CustomTextfield(
                        controller: selectedChestController,
                        hintText: "Pit",
                        obscureText: false,
                        maxLength: 6,
                        isNumeric: true,
                        unit: 'cm',
                        centerText: true,
                        allowDecimal: true,
                        height: 16,
                      ),
                    ),
                    RelativeSizedBox(width: 1),
                    WrappedImage(imageUrl: 'lib/assets/images/Chest.png', size: 50, padding: 0),
                    RelativeSizedBox(width: 1),
                    Expanded(
                      child: CustomTextfield(
                        controller: selectedCalfController,
                        hintText: "Panxells",
                        obscureText: false,
                        maxLength: 6,
                        isNumeric: true,
                        unit: 'cm',
                        centerText: true,
                        allowDecimal: true,
                        height: 16,
                      ),
                    ),
                    RelativeSizedBox(width: 1),
                    WrappedImage(imageUrl: 'lib/assets/images/Calf.png', size: 50, padding: 0),
                  ]
                ),
                RelativeSizedBox(height: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [  
                    Expanded(
                      child: CustomTextfield(
                        controller: selectedBodyfatController,
                        hintText: "Percentatge de greix",
                        obscureText: false,
                        maxLength: 6,
                        isNumeric: true,
                        unit: '%',
                        centerText: true,
                        allowDecimal: true,
                        height: 16,
                      ),
                    ),
                  ]
                ),

                RelativeSizedBox(height: 2),

                CustomButton(
                  text: "Enviar revisió",
                  onTap: () => submitCheck(context),
                ),

                const RelativeSizedBox(height: 2),

                if (response.isNotEmpty && !response["success"]) ...[
                  MessagesBox(
                    messages: response["errors"],
                    height: 6,
                    color: Colors.red,
                  ),
                  RelativeSizedBox(height: 2)
                ]
                else ...[
                  RelativeSizedBox(height: 5)
                ]
              ] else ...[
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      RotatingImage(),  
                      RelativeSizedBox(height: 17), 
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