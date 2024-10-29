import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CustomImagePicker extends StatefulWidget {
  const CustomImagePicker({super.key});

  @override
  CustomImagePickerState createState() => CustomImagePickerState();
}

class CustomImagePickerState extends State<CustomImagePicker> {
  File? selectedImage;
  final ImagePicker imagePicker = ImagePicker();
  bool isImageSelected = false;

  Future<void> pickImage() async {
    final XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
        isImageSelected = true; // Set to true when an image is selected
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: pickImage,
      child: Container(
        padding: const EdgeInsets.all(3), // Adjust padding for border thickness
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isImageSelected ? Colors.grey.shade400 : Colors.transparent,
            width: 3,
          ),
        ),
        child: CircleAvatar(
          backgroundColor: Colors.grey.shade400,
          radius: 25,
          backgroundImage: selectedImage != null ? FileImage(selectedImage!) : null,
          child: selectedImage == null
              ? Icon(Icons.add_a_photo, size: 25, color: Colors.grey[800])
              : null,
        ),
      ),
    );
  }
}