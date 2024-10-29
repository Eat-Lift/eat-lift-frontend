import 'package:flutter/material.dart';

import '../custom_widgets/custom_button.dart';
import '../custom_widgets/relative_sizedbox.dart';
import '../custom_widgets/messages_box.dart';
import '../custom_widgets/custom_dropdown.dart';

import '../services/api_user_service.dart';

class FirstReviewPage extends StatefulWidget {
  const FirstReviewPage({super.key});

  @override
  FirstReviewPageState createState() => FirstReviewPageState();
}

class FirstReviewPageState extends State<FirstReviewPage> {

  Map<String, dynamic> response = {};

  double? selectedWeight;

  final List<double> weights = List<double>.generate(
    1110,
    (i) => 40.0 + (i * 0.1),
  ).reversed.toList();

  void editUser(BuildContext context) async {
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
              const RelativeSizedBox(height: 5),
              const Icon(
                Icons.lock,
                size: 100,
              ),

              const RelativeSizedBox(height: 0.5),

              Text(
                "Informació personal",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 24,
                ),
              ),

              const RelativeSizedBox(height: 5),
              
              CustomDropdown(
                title: "Pes",
                items: weights,  
                selectedItem: selectedWeight,
                onItemSelected: (value) {
                  setState(() {
                    selectedWeight = value;
                  });
                },
                itemLabel: (weight) => "${weight.toStringAsFixed(1)} kg",
                initialOffset: (70.0 - 40.0) * 10 * 170.0,
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
                  height: 9,
                  color: Colors.red,
                ),
                RelativeSizedBox(height: 7)
              ]
              else ...[
                RelativeSizedBox(height: 20)
              ]
            ],
          ),
        ),
      ),
    );
  }
}