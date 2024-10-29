import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../custom_widgets/custom_textfield.dart';
import '../custom_widgets/custom_button.dart';
import '../custom_widgets/relative_sizedbox.dart';
import '../custom_widgets/messages_box.dart';
import '../custom_widgets/custom_dropdown.dart';
import '../custom_widgets/custom_image_picker.dart';

import 'first_review.dart';

import '../services/api_user_service.dart';

class EditUserPage extends StatefulWidget {
  const EditUserPage({super.key});

  @override
  EditUserPageState createState() => EditUserPageState();
}

class EditUserPageState extends State<EditUserPage> {
  final ImagePicker imagePicker = ImagePicker();
  int? selectedHeight;
  String? selectedGenre;
  File? selectedImage;
  DateTime? selectedDate;
  final descriptionController = TextEditingController();
  final birthDateController = TextEditingController();
  final List<int> heights = List<int>.generate(101, (i) => 120 + i).reversed.toList();
  final List<String> genres = ["Masculí", "Femení"];

  Map<String, dynamic> response = {};

  Future<void> pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2002),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
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

  void editUser(BuildContext context) async {
    // bool emptyField = false;
    
    // response = {};

    // if (selectedHeight == null) {
    //   response["success"] = false;
    //   if (response.containsKey('errors')) {
    //     response['errors'].add("Selecciona l'alçada");
    //   } else {
    //     response['errors'] = ["Selecciona l'alçada"];
    //   }
    //   emptyField = true;
    // }
    // if (selectedGenre == null) {
    //   response["success"] = false;
    //   if (response.containsKey('errors')) {
    //     response['errors'].add("Selecciona el gènere");
    //   } else {
    //     response['errors'] = ["Selecciona el gènere"];
    //   }
    //   emptyField = true;
    // }
    // if (selectedDate == null) {
    //   response["success"] = false;
    //   if (response.containsKey('errors')) {
    //     response['errors'].add("Selecciona la data de naixement");
    //   } else {
    //     response['errors'] = ["Selecciona la data de naixement"];
    //   }
    //   emptyField = true;
    // }

    // if (emptyField) {
    //   setState(() {});
    //   return;
    // }
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FirstReviewPage()),
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
                "Parla'ns sobre tú",
                style: TextStyle(
                  color: Colors.grey[700],
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
                      child: CustomDropdown(
                        title: "Alçada",
                        items: heights,
                        selectedItem: selectedHeight,
                        onItemSelected: (value) {
                          setState(() {
                            selectedHeight = value;
                          });
                        },
                        itemLabel: (height) => "${height.toStringAsFixed(0)} cm",
                        initialOffset: 2700
                      ),
                    ),

                    RelativeSizedBox(width: 2),

                    CustomImagePicker(),
                  ]
                ),
              ),

              const RelativeSizedBox(height: 0.5),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
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
                        color: Colors.grey.shade400,
                        width: 3,
                      ),
                    ),
                    fillColor: Colors.grey.shade200,
                    filled: true,
                    hintText: "Data de neixement",
                    hintStyle: TextStyle(color: Colors.grey[500])
                  ),
                  readOnly: true,
                  onTap: () => pickDate(context),
                ),
              ),

              const RelativeSizedBox(height: 0.5),

              CustomTextfield(
                controller: descriptionController,
                hintText: "Descripció",
                obscureText: false,
                maxLines: 5,
              ),

              const RelativeSizedBox(height:2),

              CustomButton(
                text: "Enviar",
                onTap: () => editUser(context),
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