import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eatnlift/custom_widgets/rotating_logo.dart';
import 'package:eatnlift/pages/user/login.dart';
import 'package:eatnlift/pages/home.dart'; 
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/database_helper.dart';

import 'services/session_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await DatabaseHelper.instance.deleteDatabaseFile();
  await DatabaseHelper.instance.database;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate();
  await initializeDateFormatting('ca', null);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Key _sessionKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((result) { 
      _reloadApp();
    });
  }

  void _reloadApp() {
    setState(() {
      _sessionKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('ca'),
      ],
      debugShowCheckedModeBanner: false,
      home: SessionCheckWrapper(key: _sessionKey),
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
          return const HomePage(initialIndex: 1);
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
