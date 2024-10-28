import 'package:flutter/material.dart';

import '../services/api_user_service.dart';
import '../services/session_storage.dart';

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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isLoading && userData != null) ...[
                Text(
                  userData?["id"]?.toString() ?? "ID not available",
                ),
                Text(
                  userData?["username"] ?? "Username not available",
                ),
                Text(
                  userData?["email"] ?? "Email not available",
                ),
                Text(
                  userData?["description"] ?? "Description not available",
                ),
                Text(
                  userData?["birthdate"]?.toString() ?? "Birthdate not available",
                ),
                Text(
                  userData?["height"]?.toString() ?? "Height not available",
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