import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadImage(File imageFile, String fileName) async {
    try {
      final storageRef = _storage.ref().child('uploads/$fileName');

      final uploadTask = await storageRef.putFile(imageFile);

      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      return null;
    }
  }
}