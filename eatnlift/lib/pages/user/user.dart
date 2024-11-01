import 'package:flutter/material.dart';

import '../../custom_widgets/relative_sizedbox.dart';
import '../../custom_widgets/expandable_text.dart';
import '../../custom_widgets/expandable_image.dart';
import '../../custom_widgets/custom_button.dart';

import '../../services/api_user_service.dart';
import '../../services/session_storage.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {

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
      isLoading = true;
    });

    // Retrieve the user ID from secure storage
    final userId = await sessionStorage.getUserId();
    if (userId == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    // Fetch user data from the API using userId
    final apiService = ApiUserService();
    final result = await apiService.getUser(userId);
    setState(() {
      userData = result?["user"];
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: 
                    Column(
                      children: [
                        RelativeSizedBox(height: 5),

                        Row(
                          children: [

                            ExpandableImage(
                              initialImagePath: null,
                              width: 70,
                              height: 70,
                            ),

                            RelativeSizedBox(width: 3),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userData?["username"],
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 27,
                                  ),
                                ),
                                Text(
                                  userData?["email"],
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        

                        RelativeSizedBox(height: 2),


                        CustomButton(
                          text: "Editar",
                          onTap: () {},
                          icon: Icons.edit,
                          width: 1000,
                          height: 40,
                        ),

                        RelativeSizedBox(height: 2),

                        ExpandableText(
                          text: userData?["description"] ?? "Lorem Ipsum es simplemente el texto de relleno de las imprentas y archivos de texto. Lorem Ipsum ha sido el texto de relleno estándar de las industrias desde el año 1500, cuando un impresor (N. del T. persona que se dedica a la imprenta) desconocido usó una galería de textos y los mezcló de tal manera que logró hacer un libro de textos especimen. No sólo sobrevivió 500 años, sino que tambien ingresó como texto de relleno en documentos electrónicos, quedando esencialmente igual al original. Fue popularizado en los 60s con la creación de las hojas ",
                        ),
                      ]
                    ),
                ),
              ]
              else ...[
                Text(
                  "loading...",
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}