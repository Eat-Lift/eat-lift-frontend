import 'package:connectivity_plus/connectivity_plus.dart';

class InternetChecker {
  static Future<bool> getConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    return connectivityResult == ConnectivityResult.mobile || 
           connectivityResult == ConnectivityResult.wifi;
  }
}