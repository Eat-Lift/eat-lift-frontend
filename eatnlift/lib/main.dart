import 'package:eatnlift/custom_widgets/rotating_logo.dart';
import 'package:eatnlift/pages/user/login.dart';
import 'package:eatnlift/pages/home.dart'; 
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'services/session_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate();
  await initializeDateFormatting('ca', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SessionCheckWrapper(),
    );
  }
}

class SessionCheckWrapper extends StatelessWidget {
  const SessionCheckWrapper({super.key});

  Future<bool> _isUserLoggedIn() async {
    final sessionStorage = SessionStorage();
    final accessToken = await sessionStorage.getAccessToken();
    return accessToken != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isUserLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: RotatingImage(),
          );
        } else if (snapshot.hasData && snapshot.data == true) {
          return const HomePage(initialIndex: 0);
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
