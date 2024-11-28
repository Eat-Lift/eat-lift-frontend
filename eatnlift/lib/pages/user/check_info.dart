import 'package:eatnlift/custom_widgets/custom_number_text.dart';
import 'package:eatnlift/custom_widgets/wrapped_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../custom_widgets/relative_sizedbox.dart';


import '../../services/session_storage.dart';
import '../../services/api_user_service.dart';

class CheckInfoPage extends StatefulWidget {
  final String date;

  const CheckInfoPage({
    super.key,
    required this.date
  });

  @override
  CheckInfoPageState createState() => CheckInfoPageState();
}

class CheckInfoPageState extends State<CheckInfoPage> {
  bool isLoading = true;
  final SessionStorage sessionStorage = SessionStorage();
  String? currentUser;
  Map<String, dynamic>? checkInfo;


  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    await _loadUserData();
    await _loadCheck();
    setState((){
      isLoading = false;
    });
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
  }

  Future<void> _loadCheck() async {
    final apiService = ApiUserService();
    final result = await apiService.getCheck(widget.date);

    if (result["success"]){
      checkInfo = result["check"];
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: Text("Revisió ${DateFormat('dd-MM-yyyy').format(DateTime.parse(widget.date))}"),   
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isLoading) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [  
                    Expanded(
                      child: CustomNumberText(
                        title: "Pes:",
                        number: checkInfo?["weight"], 
                        unit: "cm"
                      ),
                    ),
                  ]  
                ),
                RelativeSizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [  
                    Expanded(
                      child: CustomNumberText(
                        number: checkInfo?["neck"], 
                        unit: "cm"
                      ),
                    ),
                    RelativeSizedBox(width: 1),
                    WrappedImage(imageUrl: 'lib/assets/images/Neck.png', size: 50, padding: 0),
                    RelativeSizedBox(width: 4),
                    Expanded(
                      child: CustomNumberText(
                        number: checkInfo?["waist"], 
                        unit: "cm"
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
                      child: CustomNumberText(
                        number: checkInfo?["shoulders"], 
                        unit: "cm"
                      ),
                    ),
                    RelativeSizedBox(width: 1),
                    WrappedImage(imageUrl: 'lib/assets/images/Shoulders.png', size: 50, padding: 0),
                    RelativeSizedBox(width: 4),
                    Expanded(
                      child: CustomNumberText(
                        number: checkInfo?["hip"], 
                        unit: "cm"
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
                      child: CustomNumberText(
                        number: checkInfo?["arm"], 
                        unit: "cm"
                      ),
                    ),
                    RelativeSizedBox(width: 1),
                    WrappedImage(imageUrl: 'lib/assets/images/Arm.png', size: 50, padding: 0),
                    RelativeSizedBox(width: 4),
                    Expanded(
                      child: CustomNumberText(
                        number: checkInfo?["thigh"], 
                        unit: "cm"
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
                      child: CustomNumberText(
                        number: checkInfo?["chest"], 
                        unit: "cm"
                      ),
                    ),
                    RelativeSizedBox(width: 1),
                    WrappedImage(imageUrl: 'lib/assets/images/Chest.png', size: 50, padding: 0),
                    RelativeSizedBox(width: 4),
                    Expanded(
                      child: CustomNumberText(
                        number: checkInfo?["calf"], 
                        unit: "cm"
                      ),
                    ),
                    RelativeSizedBox(width: 1),
                    WrappedImage(imageUrl: 'lib/assets/images/Calf.png', size: 50, padding: 0),
                  ]
                ),
                RelativeSizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [  
                    Expanded(
                      child: CustomNumberText(
                        title: "Percentatge de greix:",
                        number: checkInfo?["bodyfat"], 
                        unit: "%"
                      ),
                    ),
                  ]  
                ),
                RelativeSizedBox(height: 10),
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