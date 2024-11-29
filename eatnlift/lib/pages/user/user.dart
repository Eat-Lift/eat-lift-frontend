import 'package:eatnlift/custom_widgets/check_graphs.dart';
import 'package:eatnlift/custom_widgets/checks_container.dart';
import 'package:eatnlift/custom_widgets/rotating_logo.dart';
import 'package:eatnlift/pages/user/check.dart';
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

  void logOut(BuildContext context) async {
    await sessionStorage.clearSession();
    if (context.mounted){
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
                  Align(
                    alignment: Alignment.topRight,
                    child: Transform.translate(
                      offset: Offset(-10, 10),
                      child: CustomButton(
                        text: "",
                        onTap: () => logOut(context),
                        icon: Icons.logout,
                        height: 40,
                        width: 40,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
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
                        CheckGraphs(checks: checksSummary!),
                        RelativeSizedBox(height: 2),
                        ChecksContainer(checks: checkDates!, height: 295),
                        RelativeSizedBox(height: 5),
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
                            RelativeSizedBox(height: 10),
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