import 'dart:io';
import '../services/database_helper.dart';

class InternetChecker {
  static Future<bool> getConnectivity() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        final databaseHelper = DatabaseHelper.instance;
        await databaseHelper.syncDatabase();
        return true;
      }
    } catch (e) {
      return false;
    }

    return false;
  }
}