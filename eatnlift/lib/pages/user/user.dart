import 'package:eatnlift/custom_widgets/check_graphs.dart';
import 'package:eatnlift/custom_widgets/checks_container.dart';
import 'package:eatnlift/custom_widgets/rotating_logo.dart';
import 'package:eatnlift/pages/user/check.dart';
import 'package:eatnlift/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../custom_widgets/relative_sizedbox.dart';
import '../../custom_widgets/expandable_text.dart';
import '../../custom_widgets/expandable_image.dart';
import '../../custom_widgets/custom_button.dart';

import '../../services/api_user_service.dart';
import '../../services/session_storage.dart';

import '../../pages/user/edit_user.dart';
import '../../pages/user/login.dart';
import '../../pages/user/personal_info.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final SessionStorage sessionStorage = SessionStorage();
  Map<String, dynamic>? userData;
  bool isLoading = true;
  List<String>? checkDates;
  List<dynamic>? checksSummary;

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    setState(() {
      isLoading = true;
    });
    await _loadUserData();
    await _loadChecks();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadChecks() async {
    final apiService = ApiUserService();
    var result = await apiService.getCheckDates();
    if (result["success"]){
      checkDates = (result["dates"] as List<dynamic>).cast<String>();
    }
    result = await apiService.getChecksSummary();
    if (result["success"]){
      checksSummary = result["checks"];
    }
  }

  Future<void> _loadUserData() async {
    final userId = await sessionStorage.getUserId();
    if (userId == null) {
      return;
    }

    final apiService = ApiUserService();
    final result = await apiService.getUser(userId);
    setState(() {
      userData = result?["user"];
    });
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.black),
              SizedBox(width: 10),
              Text("Tancar sessió"),
            ],
          ),
          content: Text("Estàs segur que vols tancar la sessió?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                logOut(context);
              },
              child: Text("Confirmar"),
            ),
          ],
        );
      },
    );
  }

  void logOut(BuildContext context) async {
    await sessionStorage.clearSession();
    await DatabaseHelper.instance.emptyDatabase();
    if (context.mounted){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final TextEditingController confirmationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red),
                  SizedBox(width: 10),
                  Text("Esborrar compte"),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Escriu 'ESBORRAR COMPTE' per continuar"),
                  RelativeSizedBox(height: 2),
                  TextField(
                    controller: confirmationController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Escriu ESBORRAR COMPTE",
                    ),
                    autofocus: true,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: confirmationController.text.trim() == "ESBORRAR COMPTE"
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("El teu compte s'ha esborrat correctament."),
                            ),
                          );
                          signOut(context);
                        }
                      : null,
                  child: Text("Esborrar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void signOut(BuildContext context) async {
    final apiService = ApiUserService();
    await apiService.signout();
    await sessionStorage.clearSession();
    await DatabaseHelper.instance.emptyDatabase();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isLoading && userData != null) ...[
                  RelativeSizedBox(height: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomButton(
                        text: "",
                        onTap: () => _showLogoutDialog(context),
                        icon: Icons.logout,
                        height: 40,
                        width: 40,
                      ),
                      RelativeSizedBox(width: 2),
                      CustomButton(
                        text: "",
                        onTap: () => _showDeleteAccountDialog(context),
                        icon: Icons.close,
                        height: 40,
                        width: 40,
                      ),
                      RelativeSizedBox(width: 2),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        RelativeSizedBox(height: 1),
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
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const PersonalInfoPage()),
                                  );
                                },
                                icon: Icons.local_fire_department,
                                height: 40,
                              ),
                            ),
                            RelativeSizedBox(width: 0.5),
                            Expanded(
                              child: CustomButton(
                                text: "Revisió",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const CheckPage()),
                                  );
                                },
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
                        RelativeSizedBox(height: 2),
                        if (checksSummary != null) ...[
                          CheckGraphs(checks: checksSummary!),
                          RelativeSizedBox(height: 2),
                          ChecksContainer(checks: checkDates!, height: 295),
                          RelativeSizedBox(height: 5),
                        ]
                        else ...[
                          RelativeSizedBox(height: 300),
                        ]
                      ],
                    ),
                  ),
                ] else ...[
                  Column(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            RelativeSizedBox(height: 4),
                            RotatingImage(),   
                          ],
                        ),
                      ),
                      RelativeSizedBox(height: 10)
                    ]
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}