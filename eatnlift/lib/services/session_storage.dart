import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionStorage {
  final _storage = const FlutterSecureStorage();

  // Save tokens and user ID
  Future<void> saveSession(String accessToken, String userId) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'user_id', value: userId);
  }

  // Retrieve stored tokens and user ID
  Future<String?> getAccessToken() async => await _storage.read(key: 'access_token');
  Future<String?> getUserId() async => await _storage.read(key: 'user_id');

  // Clear session data
  Future<void> clearSession() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'user_id');
  }
}