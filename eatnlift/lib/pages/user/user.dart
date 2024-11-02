import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../custom_widgets/relative_sizedbox.dart';
import '../../custom_widgets/expandable_text.dart';
import '../../custom_widgets/expandable_image.dart';
import '../../custom_widgets/custom_button.dart';

import '../../services/api_user_service.dart';
import '../../services/session_storage.dart';

import '../../pages/user/edit_user.dart';

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

    final userId = await sessionStorage.getUserId();
    if (userId == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

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
                  child: Column(
                    children: [
                      RelativeSizedBox(height: 5),
                      Row(
                        children: [
                          ExpandableImage(
                            initialImageUrl: userData?["picture"],
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
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: "Requeriments",
                              onTap: () {},
                              icon: Icons.local_fire_department,
                              height: 40,
                            ),
                          ),
                          RelativeSizedBox(width: 0.5),
                          Expanded(
                            child: CustomButton(
                              text: "Revisió",
                              onTap: () {},
                              icon: FontAwesomeIcons.chartLine,
                              height: 40,
                            ),
                          ),
                        ],
                      ),
                      RelativeSizedBox(height: 0.5),
                      CustomButton(
                        text: "Editar perfil",
                        onTap: () async {
                          final isUpdated = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditUserPage(userData: userData),
                            ),
                          );

                          if (isUpdated == true) {
                            _loadUserData();
                          }
                        },
                        icon: Icons.edit,
                        height: 40,
                      ),
                      RelativeSizedBox(height: 2),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ExpandableText(
                          text: userData?["description"]?.isEmpty ?? true
                              ? "Això està una mica buit"
                              : userData?["description"],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(color: Colors.grey),
                    ),
                  ],
                )     
              ]
            ],
          ),
        ),
      ),
    );
  }
}